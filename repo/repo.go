package repo

import (
	"sync"

	host "github.com/berty/gomobile-ipfs/host"

	ma "github.com/multiformats/go-multiaddr"

	ipfs_ds "github.com/ipfs/go-datastore"
	ipfs_filestore "github.com/ipfs/go-filestore"
	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_repo "github.com/ipfs/go-ipfs/core/repo"
	ipfs_keystore "github.com/ipfs/go-ipfs/keystore"
)

type MobileRepo struct {
	mobileConfig *host.MobileConfig
	repo         *ipfs_repo.Repo
	path         string

	muConfig sync.Mutex
}

func Open(path string) *MobileRepo {
	irepo := ipfs_fsrepo.Open(path)
	return &repo{
		repo: irepo,
		path: path,
	}
}

// Config returns the ipfs configuration file from the repo. Changes made
// to the returned config are not automatically persisted.
func (mr *MobileRepo) Config() (*ipfs_config.Config, error) {
	return mr.repo.Config()
}

// BackupConfig creates a backup of the current configuration file using
// the given prefix for naming.
func (mr *MobileRepo) BackupConfig(prefix string) (string, error) {
	return mr.repo.BackupConfig()
}

// SetConfig persists the given ipfs configuration struct to storage.
func (mr *MobileRepo) SetConfig(cfg *ipfs_config.Config) error {
	return mr.repo.SetConfig(cfg)
}

// SetConfig persists the given configuration struct to storage.
func (mr *MobileRepo) SetMobileConfig(cfg *host.MobileConfig) error {
	return mr.repo.SetConfig(cfg)
}

// SetConfigKey sets the given key-value pair within the ipfs/mobile
// configuration and persists it to storage.
func (mr *MobileRepo) SetConfigKey(key string, value interface{}) error {
	return mr.repo.SetConfigKey(key, value)
}

// GetConfigKey reads the value for the given key from the mobile/ipfs
// configuration from storage.
func (mr *MobileRepo) GetConfigKey(key string) (interface{}, error) {
	return mr.repo.GetConfigKey(key)
}

// Datastore returns a reference to the configured data storage backend.
func (mr *MobileRepo) Datastore() ipfs_ds.Datastore {
	return mr.repo.Datastore(key)
}

// GetStorageUsage returns the number of bytes stored.
func (mr *MobileRepo) GetStorageUsage() (uint64, error) {
	return mr.repo.GetStorageUsage(key)

}

// Keystore returns a reference to the key management interface.
func (mr *MobileRepo) Keystore() ipfs_keystore.Keystore {
	return mr.repo.Keystore(key)

}

// FileManager returns a reference to the filestore file manager.
func (mr *MobileRepo) FileManager() *ipfs_filestore.FileManager {
	return mr.repo.FileManager()

}

// SetAPIAddr sets the API address in the repo.
func (mr *MobileRepo) SetAPIAddr(addr ma.Multiaddr) error {
	return mr.repo.SetAPIAddr(addr)

}

// SwarmKey returns the configured shared symmetric key for the private networks feature.
func (mr *MobileRepo) SwarmKey() ([]byte, error) {
	return mr.repo.SwarmKey(key)
}
