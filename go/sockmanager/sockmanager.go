package sockmanager

import (
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strconv"
	"sync"
	"syscall"

	"github.com/pkg/errors"
)

// Filename is base 36 encoded to avoid conflict on case-insensitive filesystems
var maxSockFilename = strconv.FormatUint(math.MaxUint64, 36)
var paddingFormatStr = "%0" + strconv.Itoa(len(maxSockFilename)) + "s"

type SockManager struct {
	mu          sync.Mutex
	sockDirPath string
	counter     uint64
}

func NewSockManager(path string) (*SockManager, error) {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return nil, errors.Wrap(err, "sock parent folder doesn't exist")
	}

	sockDirPath := filepath.Join(path, "/uds")
	maxSockPath := filepath.Join("/unix", sockDirPath, maxSockFilename)
	if len(maxSockPath) > syscall.SizeofSockaddrAny {
		return nil, errors.New("path length exceeded")
	}

	if err := os.Mkdir(sockDirPath, 0600); err != nil {
		return nil, errors.Wrap(err, "can't create sock folder")
	}

	return &SockManager{
		sockDirPath: sockDirPath,
	}, nil
}

func (sm *SockManager) NewSock() (string, error) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	if sm.counter == math.MaxUint32 {
		// FIXME: do something smarter knowing that a socket may have been
		// removed in the meantime
		return "", errors.New("max number of socket exceeded")
	}
	sm.counter++

	sockFilename := fmt.Sprint(paddingFormatStr,
		strconv.FormatUint(uint64(sm.counter), 36))
	sockPath := filepath.Join(sm.sockDirPath, sockFilename)
	_, err := os.Stat(sockPath)
	if os.IsNotExist(err) {
		return sockPath, nil
	}

	return "", errors.Wrap(err, "can't create new sock")
}
