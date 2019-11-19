package ipfs

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	mobile_config "github.com/berty/gomobile-ipfs/go/bind/ipfs/config"
	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_common "github.com/ipfs/go-ipfs/repo/common"
)

type Config struct {
	cfg *ipfs_config.Config
}

func NewConfig(raw_json []byte) (cfg *Config, err error) {
	cfg = &Config{}
	err = cfg.Set(raw_json)
	return cfg, err
}

func NewDefaultConfig() (*Config, error) {
	cfg, err := mobile_config.InitConfig(ioutil.Discard, 2048)
	if err != nil {
		return nil, err
	}

	return &Config{cfg}, nil
}

func (c *Config) getConfig() (cfg *ipfs_config.Config) {
	return c.cfg
}

func (c *Config) Set(raw_json []byte) (err error) {
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

func (c *Config) Get() ([]byte, error) {
	return json.Marshal(c.cfg)
}

func (c *Config) SetKey(key string, raw_value []byte) error {
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

	// update Config
	newcfg, err := ipfs_config.FromMap(cfg)
	if err == nil {
		c.cfg = newcfg
	}
	return err
}

func (c *Config) GetKey(key string) ([]byte, error) {
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

// Helpers

// Setup unix domain socket api
func (c *Config) SetupUnixSocketAPI(sockpath string) {
	// add it to our api config
	c.cfg.Addresses.API = append(c.cfg.Addresses.API, "/unix/"+sockpath)
}

// Setup unix domain socket gateway
func (c *Config) SetupUnixSocketGateway(sockpath string) {
	c.cfg.Addresses.Gateway = append(c.cfg.Addresses.Gateway, "/unix/"+sockpath)
}

// Setup tcp api
func (c *Config) SetupTCPAPI(port string) {
	c.cfg.API.HTTPHeaders = map[string][]string{
		"Access-Control-Allow-Credentials": []string{"true"},
		"Access-Control-Allow-Origin":      []string{"http://127.0.0.1:" + port},
		"Access-Control-Allow-Methods":     []string{"GET", "PUT", "POST"},
	}

	c.cfg.Addresses.API = append(c.cfg.Addresses.API, fmt.Sprintf("/ip4/127.0.0.1/tcp/"+port))
}

// Setup tcp gateway
func (c *Config) SetupTCPGateway(port string) {
	c.cfg.Gateway.HTTPHeaders = map[string][]string{
		"Access-Control-Allow-Origin":  []string{"http://127.0.0.1:" + port},
		"Access-Control-Allow-Methods": []string{"GET"},
		"Access-Control-Allow-Headers": []string{"X-Requested-With", "Range", "User-Agent"},
	}

	c.cfg.Addresses.Gateway = append(c.cfg.Addresses.Gateway, fmt.Sprintf("/ip4/127.0.0.1/tcp/"+port))
}
