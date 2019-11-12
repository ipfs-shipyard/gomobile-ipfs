package mobile

import (
	"path/filepath"

	ipfs_loader "github.com/ipfs/go-ipfs/plugin/loader"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"
	ipfs_fsrepo "github.com/ipfs/go-ipfs/repo/fsrepo"
)

var plugins *ipfs_loader.PluginLoader

type Repo struct {
	irepo ipfs_repo.Repo
	path  string
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

	return &Repo{irepo, path}, nil
}

func (r *Repo) GetRootPath() string {
	return r.path
}

func (r *Repo) SetConfig(c *Config) error {
	return r.irepo.SetConfig(c.getConfig())
}

func (r *Repo) GetConfig() (*Config, error) {
	cfg, err := r.irepo.Config()
	if err != nil {
		return nil, err
	}

	return &Config{cfg}, nil
}

func (r *Repo) Close() error {
	return r.irepo.Close()
}

func (r *Repo) getRepo() ipfs_repo.Repo {
	return r.irepo
}

func loadPlugins(repoPath string) (*ipfs_loader.PluginLoader, error) {
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
