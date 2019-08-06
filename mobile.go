// ready to use gomobile package for ipfs

package mobile

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"path/filepath"

	host "github.com/berty/gomobile-ipfs/host"
	node "github.com/berty/gomobile-ipfs/node"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_loader "github.com/ipfs/go-ipfs/plugin/loader"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"
	ipfs_common "github.com/ipfs/go-ipfs/repo/common"
	ipfs_fsrepo "github.com/ipfs/go-ipfs/repo/fsrepo"
)

type Node interface {
	// Close ipfs node
	Close() error
}

func NewNode(r Repo) (Node, error) {
	ctx := context.Background()
	repo := r.getRepo()
	return node.NewNode(ctx, repo, &host.MobileConfig{})
}

type Config interface {
	// Set replace the current config with the given config
	Set(raw_json []byte) error

	// SetKey with the given value
	SetKey(key string, raw_json []byte) error

	// GetKey return the value associated with the given key
	GetKey(key string) (raw_json []byte, err error)

	// Get the current config
	Get() (raw_json []byte, err error)

	// get original config
	getConfig() *ipfs_config.Config
}

type config struct {
	cfg *ipfs_config.Config
}

func NewConfig(raw_json []byte) (cfg Config, err error) {
	cfg = &config{}
	err = cfg.Set(raw_json)
	return cfg, err
}

func NewDefaultConfig() (Config, error) {
	cfg, err := Init(ioutil.Discard, 2048)
	if err != nil {
		return nil, err
	}

	return &config{cfg}, nil
}

func (c *config) getConfig() (cfg *ipfs_config.Config) {
	return c.cfg
}

func (c *config) Set(raw_json []byte) (err error) {
	var mapcfg map[string]interface{}
	if err = json.Unmarshal(raw_json, &mapcfg); err != nil {
		return
	}

	var cfg *ipfs_config.Config

	if cfg, err = ipfs_config.FromMap(mapcfg); err == nil {
		c.cfg = cfg
	}

	return
}

func (c *config) Get() ([]byte, error) {
	return json.Marshal(c.cfg)
}

func (c *config) SetKey(key string, raw_value []byte) error {
	var val interface{}

	if err := json.Unmarshal(raw_value, &val); err != nil {
		return err
	}

	cfg, err := ipfs_config.ToMap(c.cfg)
	if err != nil {
		return err
	}

	if err := ipfs_common.MapSetKV(cfg, key, val); err != nil {
		return err
	}

	// update config
	newcfg, err := ipfs_config.FromMap(cfg)
	if err == nil {
		c.cfg = newcfg
	}
	return err
}

func (c *config) GetKey(key string) ([]byte, error) {
	cfg, err := ipfs_config.ToMap(c.cfg)
	if err != nil {
		return nil, err
	}

	val, err := ipfs_common.MapGetKV(cfg, key)
	if err != nil {
		return nil, err
	}

	return json.Marshal(&val)
}

type Repo interface {
	// return the repo actual path
	GetPath() string

	// SetConfig
	SetConfig(c Config) error

	// GetConfig
	GetConfig() (Config, error)

	// Close
	Close() error

	getRepo() ipfs_repo.Repo
}

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

func RepoIsInitialized(path string) bool {
	return ipfs_fsrepo.IsInitialized(path)
}

func loadPlugins(repoPath string) (plugins *ipfs_loader.PluginLoader, err error) {
	pluginpath := filepath.Join(repoPath, "plugins")

	plugins, err = ipfs_loader.NewPluginLoader(pluginpath)
	if err != nil {
		return nil, err
	}

	if err = plugins.Initialize(); err != nil {
		return
	}

	if err = plugins.Inject(); err != nil {
		return
	}

	return
}

func InitRepo(path string, cfg Config) error {
	_, err := loadPlugins(path)
	if err != nil {
		return err
	}

	return ipfs_fsrepo.Init(path, cfg.getConfig())
}

func OpenRepo(path string) (Repo, error) {
	r, err := ipfs_fsrepo.Open(path)
	if err != nil {
		return nil, err
	}

	return &repo{r, path}, nil
}
