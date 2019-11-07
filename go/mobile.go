// ready to use gomobile package for ipfs

// This package intend to only be use with gomobile bind directly if you
// want to use it in your own gomobile project, use host/node package directly

package mobile

// Main API exposed to the ios/android

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	host "github.com/berty/gomobile-ipfs/go/host"
	node "github.com/berty/gomobile-ipfs/go/node"

	ipfs_bs "github.com/ipfs/go-ipfs/core/bootstrap"
	// ipfs_log "github.com/ipfs/go-log"
)

type Node interface {
	// Close ipfs node
	Close() error

	// GetApiAddrs return current api listeners (separate with a comma)
	GetApiAddrs() string
}

func NewNode(r *Repo) (Node, error) {
	if _, err := loadPlugins(r.GetRootPath()); err != nil {
		return nil, err
	}

	ctx := context.Background()
	repo := r.getRepo()
	node, err := node.NewNode(ctx, repo, &host.MobileConfig{})
	if err != nil {
		return nil, err
	}

	if err := node.SetupListeners(r.getRepo(), r.GetRootPath()); err != nil {
		_ = node.Close()
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
