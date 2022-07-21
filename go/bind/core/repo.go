package core

import (
	"path/filepath"
	"sync"

	ipfs_mobile "github.com/ipfs-shipyard/gomobile-ipfs/go/pkg/ipfsmobile"
	ipfs_loader "github.com/ipfs/kubo/plugin/loader"
	ipfs_repo "github.com/ipfs/kubo/repo"
	ipfs_fsrepo "github.com/ipfs/kubo/repo/fsrepo"
)

var (
	muPlugins sync.Mutex
	plugins   *ipfs_loader.PluginLoader
)

type Repo struct {
	mr *ipfs_mobile.RepoMobile
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

	irepo, err := ipfs_fsrepo.Open(path)
	if err != nil {
		return nil, err
	}

	mRepo := ipfs_mobile.NewRepoMobile(path, irepo)
	return &Repo{mRepo}, nil
}

func (r *Repo) GetRootPath() string {
	return r.mr.Path
}

func (r *Repo) SetConfig(c *Config) error {
	return r.mr.Repo.SetConfig(c.getConfig())
}

func (r *Repo) GetConfig() (*Config, error) {
	cfg, err := r.mr.Repo.Config()
	if err != nil {
		return nil, err
	}

	return &Config{cfg}, nil
}

func (r *Repo) Close() error {
	return r.mr.Close()
}

func (r *Repo) getRepo() ipfs_repo.Repo {
	return r.mr
}

func loadPlugins(repoPath string) (*ipfs_loader.PluginLoader, error) {
	muPlugins.Lock()
	defer muPlugins.Unlock()

	if plugins != nil {
		return plugins, nil
	}

	pluginpath := filepath.Join(repoPath, "plugins")

	lp, err := ipfs_loader.NewPluginLoader(pluginpath)
	if err != nil {
		return nil, err
	}

	if err = lp.Initialize(); err != nil {
		return nil, err
	}

	if err = lp.Inject(); err != nil {
		return nil, err
	}

	plugins = lp
	return lp, nil
}
