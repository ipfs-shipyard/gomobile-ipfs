// sockmanager manage sock path to keep it short

package ipfs

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
var maxSockFilename = strconv.FormatUint(math.MaxUint32, 36)
var paddingFormatStr = "u%0" + strconv.Itoa(len(maxSockFilename)) + "s"

// make it short
const UDSDir = "u"

type SockManager struct {
	sockDirPath string

	counter   uint32
	muCounter sync.Mutex
}

func NewSockManager(path string) (*SockManager, error) {
	abspath, err := filepath.Abs(path)
	if err != nil {
		return nil, err
	}
	_, err = os.Stat(abspath)
	if os.IsNotExist(err) {
		return nil, errors.Wrap(err, "sock parent folder doesn't exist")
	}

	// sockDirPath := filepath.Join(abspath, UDSDir)
	sockDirPath := path

	// max length for a unix domain socket path is around 103 char (108 - '/unix')
	maxSockPath := filepath.Join("/unix", sockDirPath, maxSockFilename)
	if len(maxSockPath) > syscall.SizeofSockaddrAny {
		return nil, errors.New("path length exceeded")
	}

	// if err := os.MkdirAll(sockDirPath, 6755); err != nil {
	// 	return nil, errors.Wrap(err, "can't create sock folder")
	// }

	return &SockManager{
		sockDirPath: sockDirPath,
	}, nil
}

func (sm *SockManager) NewSockPath() (string, error) {
	if sm.counter == math.MaxUint32 {
		// FIXME: do something smarter knowing that a socket may have been
		// removed in the meantime
		return "", errors.New("max number of socket exceeded")
	}

	sm.muCounter.Lock()
	sm.counter++
	sockFilename := fmt.Sprintf(paddingFormatStr, strconv.FormatUint(uint64(sm.counter), 36))
	sm.muCounter.Unlock()

	sockPath := filepath.Join(sm.sockDirPath, sockFilename)
	_, err := os.Stat(sockPath)
	if os.IsNotExist(err) {
		return sockPath, nil
	}

	return "", errors.Wrap(err, "can't create new sock")
}
