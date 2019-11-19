package node

import (
	"context"
	"fmt"
	"log"
	"strings"
	"sync"

	host "github.com/berty/gomobile-ipfs/go/pkg/host"

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

	// unlockRepo(im.repoPath)

	return err
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

func NewNode(ctx context.Context, repo *MobileRepo, mcfg *host.MobileConfig) (*IpfsMobile, error) {
	// if err := lockRepo(repoPath); err != nil {
	//      return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	// }

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

	return &IpfsMobile{
		listeners: make([]manet.Listener, 0),
		IpfsNode:  inode,
		Repo:      repo,
	}, nil
}
