// ready to use gomobile package for ipfs

// This package intend to only be use with gomobile bind directly if you
// want to use it in your own gomobile project, you may want to use host/node package directly

package ipfs

// Main API exposed to the ios/android

import (
	"context"
	"log"

	mobile_host "github.com/berty/gomobile-ipfs/go/pkg/host"
	mobile_node "github.com/berty/gomobile-ipfs/go/pkg/node"

	ipfs_bs "github.com/ipfs/go-ipfs/core/bootstrap"
	// ipfs_log "github.com/ipfs/go-log"
)

type Node struct {
	*mobile_node.IpfsMobile
}

func (n *Node) Close() error {
	return n.IpfsMobile.Close()
}

func (n *Node) ServeUnixSocketAPI(sockpath string) error {
	return n.IpfsMobile.Serve("/unix/" + sockpath)
}

func (n *Node) ServeTCPAPI(port string) error {
	return n.IpfsMobile.Serve("/ip4/127.0.0.1/tcp/" + port)
}

func NewNode(r *Repo) (*Node, error) {
	ctx := context.Background()

	if _, err := loadPlugins(r.path); err != nil {
		return nil, err
	}

	repo := &mobile_node.MobileRepo{r.irepo, r.path}
	mnode, err := mobile_node.NewNode(ctx, repo, &mobile_host.MobileConfig{})
	if err != nil {
		return nil, err
	}

	if err := mnode.IpfsNode.Bootstrap(ipfs_bs.DefaultBootstrapConfig); err != nil {
		log.Printf("failed to bootstrap node: `%s`", err)
	}

	return &Node{mnode}, nil
}

func init() {
	//      ipfs_log.SetDebugLogging()
}
