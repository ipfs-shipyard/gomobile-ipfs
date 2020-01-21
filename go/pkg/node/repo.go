package node

import (
	ipfs_repo "github.com/ipfs/go-ipfs/repo"
)

var _ ipfs_repo.Repo = (*MobileRepo)(nil)

type MobileRepo struct {
	ipfs_repo.Repo
	Path string
}

func NewMobileRepo(repo ipfs_repo.Repo, path string) *MobileRepo {
	return &MobileRepo{repo, path}
}
