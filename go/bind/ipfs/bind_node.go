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

type Node interface {
	// Close ipfs node
	Close() error

	// GetApiAddrs return current api listeners (separate with a comma)
	GetApiAddrs() string

	// Serve api on the given unix socket path
	Serve(sockpath string) error
}

func NewNode(r *Repo) (Node, error) {
	ctx := context.Background()

	if _, err := loadPlugins(r.path); err != nil {
		return nil, err
	}

	repo := &mobile_node.MobileRepo{r.irepo, r.path}
	node, err := mobile_node.NewNode(ctx, repo, &mobile_host.MobileConfig{})
	if err != nil {
		return nil, err
	}

	if err := node.IpfsNode.Bootstrap(ipfs_bs.DefaultBootstrapConfig); err != nil {
		log.Printf("failed to bootstrap node: `%s`", err)
	}

	return node, nil
}

func init() {
	//      ipfs_log.SetDebugLogging()
}
