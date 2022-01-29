// ready to use gomobile package for ipfs

// This package intend to only be use with gomobile bind directly if you
// want to use it in your own gomobile project, you may want to use host/node package directly

package core

// Main API exposed to the ios/android

import (
	"bytes"
	"context"
	"encoding/gob"
	"fmt"
	"log"
	"net"
	"sync"

	ble "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ble-driver"
	ipfs_mobile "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ipfsmobile"
	proximity "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/proximitytransport"
	"go.uber.org/zap"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr/net"

	ipfs_bs "github.com/ipfs/go-ipfs/core/bootstrap"
	"github.com/libp2p/go-libp2p"
	p2p "github.com/libp2p/go-libp2p"
	// ipfs_log "github.com/ipfs/go-log"
)

type Node struct {
	listeners   []manet.Listener
	muListeners sync.Mutex

	ipfsMobile *ipfs_mobile.IpfsMobile
}

func NewNode(r *Repo, driver ProximityDriver) (*Node, error) {
	ctx := context.Background()

	if _, err := loadPlugins(r.mr.Path); err != nil {
		return nil, err
	}

	var bleOpt libp2p.Option

	switch {
	// Java embedded driver (android)
	case driver != nil:
		logger := zap.NewExample()
		defer logger.Sync()
		bleOpt = libp2p.Transport(proximity.NewTransport(ctx, logger, driver))
	// Go embedded driver (ios)
	case ble.Supported:
		logger := zap.NewExample()
		defer logger.Sync()
		bleOpt = libp2p.Transport(proximity.NewTransport(ctx, logger, ble.NewDriver(logger)))
	default:
		log.Printf("cannot enable BLE on an unsupported platform")
	}

	ipfscfg := &ipfs_mobile.IpfsConfig{
		HostConfig: &ipfs_mobile.HostConfig{
			Options: []p2p.Option{bleOpt},
		},
		RepoMobile: r.mr,
		ExtraOpts: map[string]bool{
			"pubsub": true, // enable experimental pubsub feature by default
			"ipnsps": true, // Enable IPNS record distribution through pubsub by default
		},
	}

	mnode, err := ipfs_mobile.NewNode(ctx, ipfscfg)
	if err != nil {
		return nil, err
	}

	if err := mnode.IpfsNode.Bootstrap(ipfs_bs.DefaultBootstrapConfig); err != nil {
		log.Printf("failed to bootstrap node: `%s`", err)
	}

	return &Node{
		ipfsMobile: mnode,
	}, nil
}

func (n *Node) Close() error {
	n.muListeners.Lock()
	for _, l := range n.listeners {
		l.Close()
	}
	n.muListeners.Unlock()

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

func getBytes(key interface{}) ([]byte, error) {
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)
	err := enc.Encode(key)
	if err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func init() {
	//      ipfs_log.SetDebugLogging()
}
