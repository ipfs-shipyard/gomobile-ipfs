package node

import (
	"context"
	"fmt"
	"log"
	"net"

	host "github.com/berty/gomobile-ipfs/host"
	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_oldcmds "github.com/ipfs/go-ipfs/commands"
	ipfs_core "github.com/ipfs/go-ipfs/core"
	ipfs_corehttp "github.com/ipfs/go-ipfs/core/corehttp"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr-net"
)

type IpfsMobile struct {
	lapi     []manet.Listener
	IpfsNode *ipfs_core.IpfsNode
}

func (im *IpfsMobile) Close() error {
	for _, l := range im.lapi {
		_ = l.Close()
	}

	return im.IpfsNode.Close()
}

func NewNode(ctx context.Context, repo ipfs_repo.Repo, mcfg *host.MobileConfig) (*IpfsMobile, error) {
	cfg, err := repo.Config()
	if err != nil {
		return nil, fmt.Errorf("config error: %s", err)
	}

	// build config
	buildcfg := &ipfs_core.BuildCfg{
		Online:                      true,
		Permanent:                   false,
		DisableEncryptedConnections: false,
		NilRepo:                     false,
		Repo:                        repo,
		Host:                        host.NewMobileHostOption(mcfg),
	}

	// Configure API if needed
	lapi := make([]manet.Listener, len(cfg.Addresses.API))
	for i, addr := range cfg.Addresses.API {
		maddr, err := ma.NewMultiaddr(addr)
		if err != nil {
			return nil, fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		l, err := manet.Listen(maddr)
		if err != nil {
			return nil, fmt.Errorf("API: manet.Listen(%s) failed: %s", addr, err)
		}

		lapi[i] = l
	}

	// create ipfs node
	inode, err := ipfs_core.NewNode(context.Background(), buildcfg)
	if err != nil {
		return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	}

	// @TODO: no sure about how to init this, must be another way
	cctx := ipfs_oldcmds.Context{
		ReqLog: &ipfs_oldcmds.ReqLog{},
		ConstructNode: func() (*ipfs_core.IpfsNode, error) {
			return inode, nil
		},
		LoadConfig: func(_ string) (*ipfs_config.Config, error) {
			return cfg.Clone()
		},
	}

	gatewayOpt := ipfs_corehttp.GatewayOption(false, ipfs_corehttp.WebUIPaths...)
	opts := []ipfs_corehttp.ServeOption{
		ipfs_corehttp.WebUIOption,
		gatewayOpt,
		ipfs_corehttp.CommandsOption(cctx),
	}

	for _, ml := range lapi {
		l := manet.NetListener(ml)
		go func(l net.Listener) {
			if err := ipfs_corehttp.Serve(inode, l, opts...); err != nil {
				log.Printf("serve error: `%s`", err)
			}
		}(l)

	}

	return &IpfsMobile{
		lapi:     lapi,
		IpfsNode: inode,
	}, nil
}
