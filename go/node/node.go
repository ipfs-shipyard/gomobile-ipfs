package node

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"
	"strings"
	"sync"

	host "github.com/berty/gomobile-ipfs/go/host"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_oldcmds "github.com/ipfs/go-ipfs/commands"
	ipfs_core "github.com/ipfs/go-ipfs/core"
	ipfs_corehttp "github.com/ipfs/go-ipfs/core/corehttp"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr-net"
)

type PathGetter interface {
	GetRootPath() string
}

type MobileRepo interface {
	PathGetter
	ipfs_repo.Repo
}

type IpfsMobile struct {
	listeners   []manet.Listener
	muListeners sync.Mutex

	IpfsNode *ipfs_core.IpfsNode
}

func (im *IpfsMobile) Close() error {
	for _, l := range im.listeners {
		_ = l.Close()
	}

	return im.IpfsNode.Close()
}

// GetApiAddrs return current api listeners (separate with a comma)
func (im *IpfsMobile) GetApiAddrs() string {
	var addrs []string
	for _, l := range im.listeners {
		a, err := manet.FromNetAddr(l.Addr())
		if err != nil {
			log.Printf("unable to get multiaddr from `%s`: %s", l.Addr().String(), err)
			continue
		}

		addrs = append(addrs, a.String())
	}

	return strings.Join(addrs, ",")
}

func (im *IpfsMobile) SetupListeners(repo ipfs_repo.Repo, repo_path string) error {
	cfg, err := repo.Config()
	if err != nil {
		return fmt.Errorf("config error: %s", err)
	}

	im.muListeners.Lock()
	defer im.muListeners.Unlock()

	// closes previous listeners if any
	for _, l := range im.listeners {
		_ = l.Close()
	}

	// Configure API if needed
	im.listeners = make([]manet.Listener, len(cfg.Addresses.API))
	for i, addr := range cfg.Addresses.API {
		maddr, err := ma.NewMultiaddr(addr)
		if err != nil {
			return fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		// @HOTFIX: try to delete old sock, if exist, before listening.
		// this will happen everytime the app is forced to exist until
		// the node is properly close on the ios/android side.
		addr, err := manet.ToNetAddr(maddr)
		if addr.Network() == "unix" {
			sockpath := addr.String()
			if _, err := os.Stat(sockpath); err == nil {
				if err = os.Remove(sockpath); err != nil {
					log.Printf("unable to delete old sock: %s", err)
				}
			}
		}

		l, err := manet.Listen(maddr)
		if err != nil {
			return fmt.Errorf("API: manet.Listen(%s) failed: %s", addr, err)
		}

		im.listeners[i] = l
	}

	// @TODO: no sure about how to init this, must be another way
	cctx := ipfs_oldcmds.Context{
		ConfigRoot: repo_path,
		ReqLog:     &ipfs_oldcmds.ReqLog{},
		ConstructNode: func() (*ipfs_core.IpfsNode, error) {
			return im.IpfsNode, nil
		},
		LoadConfig: func(_ string) (*ipfs_config.Config, error) {
			cfg, err := repo.Config()
			if err != nil {
				return nil, err
			}
			return cfg.Clone()
		},
	}

	gatewayOpt := ipfs_corehttp.GatewayOption(false, ipfs_corehttp.WebUIPaths...)
	opts := []ipfs_corehttp.ServeOption{
		ipfs_corehttp.WebUIOption,
		gatewayOpt,
		ipfs_corehttp.CommandsOption(cctx),
	}

	for _, ml := range im.listeners {
		l := manet.NetListener(ml)
		go func(l net.Listener) {
			if err := ipfs_corehttp.Serve(im.IpfsNode, l, opts...); err != nil {
				log.Printf("serve error: %s", err)
			}
		}(l)

	}

	return nil
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
	listeners := make([]manet.Listener, len(cfg.Addresses.API))
	for i, addr := range cfg.Addresses.API {
		maddr, err := ma.NewMultiaddr(addr)
		if err != nil {
			return nil, fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		// @HOTFIX: try to delete old sock, if exist, before listening.
		// this will happen everytime the app is forced to exist until
		// the node is properly close on the ios/android side.
		addr, err := manet.ToNetAddr(maddr)
		if addr.Network() == "unix" {
			sockpath := addr.String()
			if _, err := os.Stat(sockpath); err == nil {
				if err = os.Remove(sockpath); err != nil {
					log.Printf("unable to delete old sock: %s", err)
				}
			}
		}

		l, err := manet.Listen(maddr)
		if err != nil {
			return nil, fmt.Errorf("API: manet.Listen(%s) failed: %s", addr, err)
		}

		listeners[i] = l
	}

	// create ipfs node
	inode, err := ipfs_core.NewNode(context.Background(), buildcfg)
	if err != nil {
		return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	}

	return &IpfsMobile{
		listeners: listeners,
		IpfsNode:  inode,
	}, nil
}
