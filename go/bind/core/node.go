// ready to use gomobile package for ipfs

// This package intend to only be use with gomobile bind directly if you
// want to use it in your own gomobile project, you may want to use host/node package directly

package core

// Main API exposed to the ios/android

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"

	ble "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ble-driver"
	ipfs_mobile "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ipfsmobile"
	"github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ipfsutil"
	proximity "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/proximitytransport"
	"go.uber.org/zap"

	p2p_mdns "github.com/libp2p/go-libp2p/p2p/discovery/mdns"
	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr/net"

	ipfs_config "github.com/ipfs/kubo/config"
	ipfs_bs "github.com/ipfs/kubo/core/bootstrap"
	libp2p "github.com/libp2p/go-libp2p"
)

type Node struct {
	listeners   []manet.Listener
	muListeners sync.Mutex
	mdnsLocker  sync.Locker
	mdnsLocked  bool
	mdnsService p2p_mdns.Service

	ipfsMobile *ipfs_mobile.IpfsMobile
}

func NewNode(r *Repo, config *NodeConfig) (*Node, error) {
	if config == nil {
		config = NewNodeConfig()
	}

	var dialer net.Dialer
	net.DefaultResolver = &net.Resolver{
		PreferGo: false,
		Dial: func(context context.Context, _, _ string) (net.Conn, error) {
			conn, err := dialer.DialContext(context, "udp", "84.200.69.80:53")
			if err != nil {
				return nil, err
			}
			return conn, nil
		},
	}

	ctx := context.Background()

	if _, err := loadPlugins(r.mr.Path); err != nil {
		return nil, err
	}

	// Set up netdriver.
	if config.netDriver != nil {
		logger, _ := zap.NewDevelopment()
		inet := &inet{
			net:    config.netDriver,
			logger: logger,
		}
		ipfsutil.SetNetDriver(inet)
		manet.SetNetInterface(inet)
	}

	var bleOpt libp2p.Option

	switch {
	// Java embedded driver (android)
	case config.bleDriver != nil:
		logger := zap.NewExample()
		defer func() {
			if err := logger.Sync(); err != nil {
				fmt.Println(err)
			}
		}()
		bleOpt = libp2p.Transport(proximity.NewTransport(ctx, logger, config.bleDriver))
	// Go embedded driver (ios)
	case ble.Supported:
		logger := zap.NewExample()
		defer func() {
			if err := logger.Sync(); err != nil {
				fmt.Println(err)
			}
		}()
		bleOpt = libp2p.Transport(proximity.NewTransport(ctx, logger, ble.NewDriver(logger)))
	default:
		log.Printf("cannot enable BLE on an unsupported platform")
	}

	ipfscfg := &ipfs_mobile.IpfsConfig{
		HostConfig: &ipfs_mobile.HostConfig{
			Options: []libp2p.Option{bleOpt},
		},
		RepoMobile: r.mr,
		ExtraOpts: map[string]bool{
			"pubsub": true, // enable experimental pubsub feature by default
			"ipnsps": true, // Enable IPNS record distribution through pubsub by default
		},
	}

	cfg, err := r.mr.Config()
	if err != nil {
		panic(err)
	}

	mdnsLocked := false
	if cfg.Discovery.MDNS.Enabled && config.mdnsLockerDriver != nil {
		config.mdnsLockerDriver.Lock()
		mdnsLocked = true

		// Force disable mDNS so that ipfs_mobile.NewNode doesn't start the service.
		err := r.mr.ApplyPatchs(func(cfg *ipfs_config.Config) error {
			cfg.Discovery.MDNS.Enabled = false
			return nil
		})
		if err != nil {
			return nil, fmt.Errorf("unable to ApplyPatchs to disable mDNS: %w", err)
		}
	}
	mnode, err := ipfs_mobile.NewNode(ctx, ipfscfg)
	if err != nil {
		if mdnsLocked {
			config.mdnsLockerDriver.Unlock()
		}
		return nil, err
	}

	var mdnsService p2p_mdns.Service = nil
	if mdnsLocked {
		// Restore.
		err := r.mr.ApplyPatchs(func(cfg *ipfs_config.Config) error {
			cfg.Discovery.MDNS.Enabled = true
			return nil
		})
		if err != nil {
			return nil, fmt.Errorf("unable to ApplyPatchs to enable mDNS: %w", err)
		}

		h := mnode.PeerHost()
		mdnslogger, _ := zap.NewDevelopment()

		dh := ipfsutil.DiscoveryHandler(ctx, mdnslogger, h)
		mdnsService = ipfsutil.NewMdnsService(mdnslogger, h, ipfsutil.MDNSServiceName, dh)

		// Start the mDNS service.
		// Get multicast interfaces.
		ifaces, err := ipfsutil.GetMulticastInterfaces()
		if err != nil {
			if mdnsLocked {
				config.mdnsLockerDriver.Unlock()
			}
			return nil, err
		}

		// If multicast interfaces are found, start the mDNS service.
		if len(ifaces) > 0 {
			mdnslogger.Info("starting mdns")
			if err := mdnsService.Start(); err != nil {
				if mdnsLocked {
					config.mdnsLockerDriver.Unlock()
				}
				return nil, fmt.Errorf("unable to start mdns service: %w", err)
			}
		} else {
			mdnslogger.Error("unable to start mdns service, no multicast interfaces found")
		}
	}

	if err := mnode.IpfsNode.Bootstrap(ipfs_bs.DefaultBootstrapConfig); err != nil {
		log.Printf("failed to bootstrap node: `%s`", err)
	}

	return &Node{
		ipfsMobile:  mnode,
		mdnsLocker:  config.mdnsLockerDriver,
		mdnsLocked:  mdnsLocked,
		mdnsService: mdnsService,
	}, nil
}

func (n *Node) Close() error {
	n.muListeners.Lock()
	for _, l := range n.listeners {
		l.Close()
	}
	n.muListeners.Unlock()

	if n.mdnsLocked {
		n.mdnsService.Close()
		n.mdnsLocker.Unlock()
		n.mdnsLocked = false
	}

	return n.ipfsMobile.Close()
}

func (n *Node) ServeUnixSocketAPI(sockpath string) (err error) {
	_, err = n.ServeAPIMultiaddr("/unix/" + sockpath)
	return
}

// ServeTCPAPI on the given port and return the current listening maddr
func (n *Node) ServeTCPAPI(port string) (string, error) {
	return n.ServeAPIMultiaddr("/ip4/127.0.0.1/tcp/" + port)
}

func (n *Node) ServeConfig() error {
	cfg, err := n.ipfsMobile.Repo.Config()
	if err != nil {
		return fmt.Errorf("unable to get config: %s", err.Error())
	}

	if len(cfg.Addresses.API) > 0 {
		for _, maddr := range cfg.Addresses.API {
			if _, err := n.ServeAPIMultiaddr(maddr); err != nil {
				return fmt.Errorf("cannot serve `%s`: %s", maddr, err.Error())
			}
		}
	}

	if len(cfg.Addresses.Gateway) > 0 {
		for _, maddr := range cfg.Addresses.Gateway {
			// public gateway should be readonly by default
			if _, err := n.ServeGatewayMultiaddr(maddr, false); err != nil {
				return fmt.Errorf("cannot serve `%s`: %s", maddr, err.Error())
			}
		}
	}

	return nil
}

func (n *Node) ServeUnixSocketGateway(sockpath string, writable bool) (err error) {
	_, err = n.ServeGatewayMultiaddr("/unix/"+sockpath, writable)
	return
}

func (n *Node) ServeTCPGateway(port string, writable bool) (string, error) {
	return n.ServeGatewayMultiaddr("/ip4/127.0.0.1/tcp/"+port, writable)
}

func (n *Node) ServeGatewayMultiaddr(smaddr string, writable bool) (string, error) {
	maddr, err := ma.NewMultiaddr(smaddr)
	if err != nil {
		return "", err
	}

	ml, err := manet.Listen(maddr)
	if err != nil {
		return "", err
	}

	n.muListeners.Lock()
	n.listeners = append(n.listeners, ml)
	n.muListeners.Unlock()

	go func(l net.Listener) {
		if err := n.ipfsMobile.ServeGateway(l, writable); err != nil {
			log.Printf("serve error: %s", err.Error())
		}
	}(manet.NetListener(ml))

	return ml.Multiaddr().String(), nil
}

func (n *Node) ServeAPIMultiaddr(smaddr string) (string, error) {
	maddr, err := ma.NewMultiaddr(smaddr)
	if err != nil {
		return "", err
	}

	ml, err := manet.Listen(maddr)
	if err != nil {
		return "", err
	}

	n.muListeners.Lock()
	n.listeners = append(n.listeners, ml)
	n.muListeners.Unlock()

	go func(l net.Listener) {
		if err := n.ipfsMobile.ServeCoreHTTP(l); err != nil {
			log.Printf("serve error: %s", err.Error())
		}
	}(manet.NetListener(ml))

	return ml.Multiaddr().String(), nil
}

func init() {
	//      ipfs_log.SetDebugLogging()
}
