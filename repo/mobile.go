package repo

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"path/filepath"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_fsrepo "github.com/ipfs/go-ipfs/core/repo/fsrepo"
)

const mobileFile = "mobile"

func (r *MobileRepo) IsInitialized() bool {
	return ipfs_fsrepo.IsInitialized(r.path)
}

func (r *MobileRepo) getPath() string {
	repoPath = filepath.Clean(r.path)
	return filepath.Join(repoPath, mobileFile)
}

func (r *MobileRepo) SetMobileConfig(tmp map[string]interface{}) (err error) {
	// mobilePath := r.getPath()

	// var template interface{}
	// if err = json.Unmarshal(rawcfg, &template); err != nil {
	// 	return
	// }

	if mapcfg, ok := template.(map[string]interface{}); ok {
		var cfg *ipfs_config.Config

		if cfg, err = ipfs_config.FromMap(mapcfg); err == nil {
			r.config = cfg
		}

		return
	}

	err = fmt.Errorf("unable to cast config to map")
	return
}

func (r *MobileRepo) GetMobileConfig() (rawcfg []byte, err error) {
	if r.config == nil {
		err = fmt.Errorf("no config loaded")
		return
	}

	var mapcfg interface{}

	if mapcfg, err = ipfs_config.ToMap(r.config); err != nil {
		return
	}

	rawcfg, err = json.Marshal(mapcfg)
	return
}

func (r *MobileRepo) Init() (err error) {
	if r.config == nil {
		if r.config, err = ipfs_config.Init(ioutil.Discard, 2048); err != nil {
			return
		}
	}

	err = ipfs_fsrepo.Init(r.path, r.config)
	return
}
