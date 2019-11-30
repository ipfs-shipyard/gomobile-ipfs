package node

import (
	"context"
	"fmt"

	host "github.com/berty/gomobile-ipfs/go/pkg/host"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_oldcmds "github.com/ipfs/go-ipfs/commands"
	ipfs_core "github.com/ipfs/go-ipfs/core"
)

type IpfsMobile struct {
	commandCtx ipfs_oldcmds.Context
	// listeners   []manet.Listener
	// muListeners sync.Mutex

	IpfsNode *ipfs_core.IpfsNode
	Repo     *MobileRepo
}

func (im *IpfsMobile) Close() error {
	// for _, l := range im.listeners {
	// 	_ = l.Close()
	// }

	return im.IpfsNode.Close()
}

func NewNode(ctx context.Context, repo *MobileRepo, mcfg *host.MobileConfig) (*IpfsMobile, error) {
	// cfg, err := repo.Config()
	// if err != nil {
	// 	return nil, errors.Wrap(err, "cant get config")
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

	// @TODO: no sure about how to init this, must be another way
	cctx := ipfs_oldcmds.Context{
		ConfigRoot: repo.Path,
		ReqLog:     &ipfs_oldcmds.ReqLog{},
		ConstructNode: func() (*ipfs_core.IpfsNode, error) {
			return inode, nil
		},
		LoadConfig: func(_ string) (*ipfs_config.Config, error) {
			cfg, err := repo.Config()
			if err != nil {
				return nil, err
			}
			return cfg.Clone()
		},
	}

	return &IpfsMobile{
		commandCtx: cctx,
		IpfsNode:   inode,
		Repo:       repo,
	}, nil
}
