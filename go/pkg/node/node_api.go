package node

import (
	"fmt"
	"log"
	"net"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_oldcmds "github.com/ipfs/go-ipfs/commands"
	ipfs_core "github.com/ipfs/go-ipfs/core"
	ipfs_corehttp "github.com/ipfs/go-ipfs/core/corehttp"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr-net"
)

func (im *IpfsMobile) Serve(maddrs ...string) error {
	var err error

	// @TODO: no sure about how to init this, must be another way
	cctx := ipfs_oldcmds.Context{
		ConfigRoot: im.Repo.Path,
		ReqLog:     &ipfs_oldcmds.ReqLog{},
		ConstructNode: func() (*ipfs_core.IpfsNode, error) {
			return im.IpfsNode, nil
		},
		LoadConfig: func(_ string) (*ipfs_config.Config, error) {
			cfg, err := im.Repo.Config()
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

	im.muListeners.Lock()
	defer im.muListeners.Unlock()

	for _, addr := range maddrs {
		var ml manet.Listener
		var maddr ma.Multiaddr

		maddr, err = ma.NewMultiaddr(addr)
		if err != nil {
			return fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		ml, err = manet.Listen(maddr)
		if err != nil {
			return fmt.Errorf("Listen on `%s` failed: %s", maddr.String(), err)
		}

		l := manet.NetListener(ml)
		go func(l net.Listener) {
			if err := ipfs_corehttp.Serve(im.IpfsNode, l, opts...); err != nil {
				log.Printf("serve error: %s", err)
			}
		}(l)

		im.listeners = append(im.listeners, ml)
	}

	return nil
}
