package node

import (
	"context"

	mobile_host "github.com/berty/gomobile-ipfs/host"
	ipfs_core "github.com/ipfs/go-ipfs/core"
	ipfs_repo "github.com/ipfs/go-ipfs/core/repo"
)

// type Node interface {
// 	// Close ipfs node
// 	Close() error
// }

type IpfsMobile struct {
	ipfsNode *ipfs_core.IpfsNode
}

func (im *IpfsMobile) Close() error {
	return im.ipfsNode.Close()
}

func NewNode(ctx context.Context, repo *ipfs_repo.Repo) (*IpfsMobile, error) {
	mcfg := mobile_host.NewMobileConfigFromRepo(repo)
	cfg := &ipfs_core.BuildCfg{
		Online:                      true,
		Permanent:                   false,
		DisableEncryptedConnections: false,
		NilRepo:                     false,
		Repo:                        ipfsrepo,
		Host:                        mobile_host.NewMobileHostOption(mcfg),
	}

	inode, err := ipfs_core.NewNode(context.Background(), cfg)
	if err != nil {
		return nil, err
	}

	return &IpfsMobile{
		ipfsNode: inode,
	}, nil
}
