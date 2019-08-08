package mobile

import (
	"path/filepath"

	ipfs_loader "github.com/ipfs/go-ipfs/plugin/loader"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"
)

var plugins *ipfs_loader.PluginLoader

type repo struct {
	irepo ipfs_repo.Repo
	path  string
}

func (r *repo) GetPath() string {
	return r.path
}

func (r *repo) SetConfig(c Config) error {
	return r.irepo.SetConfig(c.getConfig())
}

func (r *repo) GetConfig() (Config, error) {
	cfg, err := r.irepo.Config()
	if err != nil {
		return nil, err
	}

	return &config{cfg}, nil
}

func (r *repo) Close() error {
	return r.irepo.Close()
}

func (r *repo) getRepo() ipfs_repo.Repo {
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
