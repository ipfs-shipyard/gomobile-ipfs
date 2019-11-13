package node

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"

	host "github.com/berty/gomobile-ipfs/go/host"

	ipfs_config "github.com/ipfs/go-ipfs-config"
	ipfs_oldcmds "github.com/ipfs/go-ipfs/commands"
	ipfs_core "github.com/ipfs/go-ipfs/core"
	ipfs_corehttp "github.com/ipfs/go-ipfs/core/corehttp"
	ipfs_repo "github.com/ipfs/go-ipfs/repo"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr-net"
)

type PathGetter interface {
	GetRootPath() string
}

type MobileRepo interface {
	PathGetter
	ipfs_repo.Repo
}

type IpfsMobile struct {
	listeners   []manet.Listener
	muListeners sync.Mutex

	IpfsNode *ipfs_core.IpfsNode
	repoPath string
}

type repoLocks struct {
	pathsMap   map[string]bool
	muPathsMap sync.Mutex
}

var gRepoLocks = &repoLocks{
	pathsMap: make(map[string]bool),
}

func (im *IpfsMobile) Close() error {
	for _, l := range im.listeners {
		_ = l.Close()
	}

	unlockRepo(im.repoPath)

	return im.IpfsNode.Close()
}

// GetApiAddrs return current api listeners (separate with a comma)
func (im *IpfsMobile) GetApiAddrs() string {
	var addrs []string
	for _, l := range im.listeners {
		a, err := manet.FromNetAddr(l.Addr())
		if err != nil {
			log.Printf("unable to get multiaddr from `%s`: %s", l.Addr().String(), err)
			continue
		}

		addrs = append(addrs, a.String())
	}

	return strings.Join(addrs, ",")
}

func (im *IpfsMobile) SetupListeners(repo ipfs_repo.Repo, repo_path string) error {
	var cfg *ipfs_config.Config
	var err error

	cfg, err = repo.Config()
	if err != nil {
		return fmt.Errorf("config error: %s", err)
	}

	im.muListeners.Lock()
	defer im.muListeners.Unlock()

	// closes previous listeners if any
	for _, l := range im.listeners {
		_ = l.Close()
	}

	// Configure API if needed
	listeners := make([]manet.Listener, len(cfg.Addresses.API))
	for i, addr := range cfg.Addresses.API {
		var listener manet.Listener
		var maddr ma.Multiaddr

		maddr, err = ma.NewMultiaddr(addr)
		if err != nil {
			return fmt.Errorf("failed to parse ma: %s, %s", addr, err)
		}

		ma.ForEach(maddr, func(c ma.Component) bool {
			switch c.Protocol().Code {
			case ma.P_IP4, ma.P_IP6:
				listener, err = manet.Listen(maddr)
			case ma.P_UNIX:
				// convert relative path to absolute path based
				// on repo path
				sockpath := c.Value()
				if !strings.HasPrefix(sockpath, "//") {
					sockpath = filepath.Join(repo_path, sockpath)
					if maddr, err = ma.NewMultiaddr("/unix/" + sockpath); err != nil {
						return true
					}
				}

				// @HOTFIX: try to delete old sock, if exist, before listening.
				// this will happen everytime the app is forced to exist until
				// the node is properly close on the ios/android side.
				if _, serr := os.Stat(sockpath); serr == nil {
					if serr := os.Remove(sockpath); serr != nil {
						log.Printf("unable to delete old sock: %s", serr)
					}
				}

				listener, err = manet.Listen(maddr)
			default:
				return false
			}

			return true
		})

		if err != nil {
			return fmt.Errorf("Listen on `%s` failed: %s", maddr.String(), err)
		}

		if listener == nil {
			return fmt.Errorf("`%s` is not supported", maddr.String())
		}

		listeners[i] = listener
	}

	im.listeners = listeners

	// @TODO: no sure about how to init this, must be another way
	cctx := ipfs_oldcmds.Context{
		ConfigRoot: repo_path,
		ReqLog:     &ipfs_oldcmds.ReqLog{},
		ConstructNode: func() (*ipfs_core.IpfsNode, error) {
			return im.IpfsNode, nil
		},
		LoadConfig: func(_ string) (*ipfs_config.Config, error) {
			cfg, err := repo.Config()
			if err != nil {
				return nil, err
			}
			return cfg.Clone()
		},
	}

	gatewayOpt := ipfs_corehttp.GatewayOption(false, ipfs_corehttp.WebUIPaths...)
	opts := []ipfs_corehttp.ServeOption{
		ipfs_corehttp.WebUIOption,
		gatewayOpt,
		ipfs_corehttp.CommandsOption(cctx),
	}

	for _, ml := range im.listeners {
		l := manet.NetListener(ml)
		go func(l net.Listener) {
			if err := ipfs_corehttp.Serve(im.IpfsNode, l, opts...); err != nil {
				log.Printf("serve error: %s", err)
			}
		}(l)

	}

	return nil
}

func lockRepo(repoPath string) error {
	gRepoLocks.muPathsMap.Lock()
	defer gRepoLocks.muPathsMap.Unlock()

	if gRepoLocks.pathsMap[repoPath] {
		return errors.New("repo is locked by another node")
	}
	gRepoLocks.pathsMap[repoPath] = true

	return nil
}

func unlockRepo(repoPath string) {
	gRepoLocks.muPathsMap.Lock()
	gRepoLocks.pathsMap[repoPath] = false
	gRepoLocks.muPathsMap.Unlock()
}

func NewNode(ctx context.Context, repo ipfs_repo.Repo, repoPath string, mcfg *host.MobileConfig) (*IpfsMobile, error) {
	if err := lockRepo(repoPath); err != nil {
		return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	}

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
		unlockRepo(repoPath)
		return nil, fmt.Errorf("failed to init ipfs node: %s", err)
	}

	return &IpfsMobile{
		listeners: make([]manet.Listener, 0),
		IpfsNode:  inode,
		repoPath:  repoPath,
	}, nil
}
