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

func (im *IpfsMobile) ServeOnUDS(sockpath string) error {
	var cfg *ipfs_config.Config
	var err error

	cfg, err = im.Repo.Config()
	if err != nil {
		return fmt.Errorf("config error: %s", err)
	}

	im.muListeners.Lock()
	defer im.muListeners.Unlock()

	// closes previous listeners if any
	for _, l := range im.listeners {
		_ = l.Close()
	}

	addrs := append(cfg.Addresses.API, "/unix/"+sockpath)

	// Configure API if needed
	listeners := make([]manet.Listener, len(addrs))
	for i, addr := range addrs {
		var listener manet.Listener
		var maddr ma.Multiaddr

		maddr, err = ma.NewMultiaddr(addr)
		if err != nil {
			return fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		listener, err = manet.Listen(maddr)
		// ma.ForEach(maddr, func(c ma.Component) bool {
		// 	switch c.Protocol().Code {
		// 	case ma.P_IP4, ma.P_IP6:
		// 		listener, err = manet.Listen(maddr)
		// 	case ma.P_UNIX:
		// 		// sockpath := c.Value()
		// 		// if !strings.HasPrefix(sockpath, "//") {
		// 		// 	sockpath = filepath.Join(im.Repo.Path, sockpath)
		// 		// 	if maddr, err = ma.NewMultiaddr("/unix/" + sockpath); err != nil {
		// 		// 		return true
		// 		// 	}
		// 		// }

		// 		// // @HOTFIX: if api sock already exists, delete it before listening.
		// 		// // This will happen everytime the app is killed and
		// 		// // the node isn't properly closed on the ios/android side.
		// 		// if _, serr := os.Stat(sockpath); serr == nil {
		// 		// 	if serr := os.Remove(sockpath); serr != nil {
		// 		// 		log.Printf("unable to delete old sock: %s", serr)
		// 		// 	}
		// 		// }

		// 		listener, err = manet.Listen(maddr)
		// 	default:
		// 		return false
		// 	}

		// 	return true
		// })

		if err != nil {
			return fmt.Errorf("Listen on `%s` failed: %s", maddr.String(), err)
		}

		if listener == nil {
			return fmt.Errorf("`%s` is not supported", maddr.String())
		}

		listeners[i] = listener
	}

	im.listeners = listeners

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
