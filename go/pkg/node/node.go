package node

import (
	"context"
	"fmt"
	"log"
	"sync"

	host "github.com/berty/gomobile-ipfs/go/pkg/host"
	"github.com/pkg/errors"

	ipfs_core "github.com/ipfs/go-ipfs/core"

	manet "github.com/multiformats/go-multiaddr-net"
)

type IpfsMobile struct {
	listeners   []manet.Listener
	muListeners sync.Mutex

	IpfsNode *ipfs_core.IpfsNode
	Repo     *MobileRepo
}

func (im *IpfsMobile) Close() error {
	err := im.IpfsNode.Close()

	for _, l := range im.listeners {
		_ = l.Close()
	}

	return err
}

func NewNode(ctx context.Context, repo *MobileRepo, mcfg *host.MobileConfig) (*IpfsMobile, error) {
	cfg, err := repo.Config()
	if err != nil {
		return nil, errors.Wrap(err, "cant get config")
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

	// create ipfs node
	inode, err := ipfs_core.NewNode(context.Background(), buildcfg)
	if err != nil {
		// unlockRepo(repoPath)
		return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	}

	node := &IpfsMobile{
		listeners: make([]manet.Listener, 0),
		IpfsNode:  inode,
		Repo:      repo,
	}

	if len(cfg.Addresses.API) > 0 {
		if err = node.Serve(cfg.Addresses.API...); err != nil {
			log.Printf("unable to serve config API")
		}
	}

	return node, nil
}
