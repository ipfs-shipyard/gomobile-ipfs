// ready to use gomobile package for ipfs

// This package intend to only be use with gomobile bind directly if you
// want to use it in your own gomobile project, use host/node package directly

package mobile

// Main API exposed to the ios/android

import (
	"context"
	"io/ioutil"
	"log"

	host "github.com/berty/gomobile-ipfs/host"
	node "github.com/berty/gomobile-ipfs/node"

	ipfs_bs "github.com/ipfs/go-ipfs/core/bootstrap"
	ipfs_fsrepo "github.com/ipfs/go-ipfs/repo/fsrepo"
	ipfs_log "github.com/ipfs/go-log"
)

type Node interface {
	// Close ipfs node
	Close() error

	// GetApiAddrs return current api listeners (separate with a comma)
	GetApiAddrs() string
}

func NewNode(r *Repo) (Node, error) {
	if _, err := loadPlugins(r.GetPath()); err != nil {
		return nil, err
	}

	ctx := context.Background()
	repo := r.getRepo()
	node, err := node.NewNode(ctx, repo, &host.MobileConfig{})
	if err != nil {
		return nil, err
	}

	if err := node.IpfsNode.Bootstrap(ipfs_bs.DefaultBootstrapConfig); err != nil {
		log.Printf("unable to start node: `%s`", err)
	}

	return node, nil
}

func NewConfig(raw_json []byte) (cfg *Config, err error) {
	cfg = &Config{}
	err = cfg.Set(raw_json)
	return cfg, err
}

func NewDefaultConfig() (*Config, error) {
	cfg, err := initConfig(ioutil.Discard, 2048)
	if err != nil {
		return nil, err
	}

	return &Config{cfg}, nil
}

func RepoIsInitialized(path string) bool {
	return ipfs_fsrepo.IsInitialized(path)
}

func InitRepo(path string, cfg *Config) error {
	if _, err := loadPlugins(path); err != nil {
		return err
	}

	return ipfs_fsrepo.Init(path, cfg.getConfig())
}

func OpenRepo(path string) (*Repo, error) {
	if _, err := loadPlugins(path); err != nil {
		return nil, err
	}

	r, err := ipfs_fsrepo.Open(path)
	if err != nil {
		return nil, err
	}

	return &Repo{r, path}, nil
}

func init() {
	ipfs_log.SetDebugLogging()
}
