package core

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net"
	"net/http"
	"path/filepath"
	"testing"
	"time"

	ipfs_files "github.com/ipfs/go-ipfs-files"
	ipfs_coreapi "github.com/ipfs/kubo/core/coreapi"

	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr/net"
)

func TestNode(t *testing.T) {
	path, clean := testingTempDir(t, "repo")
	defer clean()

	repo, clean := testingRepo(t, path)
	defer clean()

	node, err := NewNode(repo, nil)
	if err != nil {
		t.Fatal(err)
	}

	if err := node.Close(); err != nil {
		t.Error(err)
	}
}
func TestNodeServeAPI(t *testing.T) {
	t.Run("tpc api", func(t *testing.T) {
		path, clean := testingTempDir(t, "tpc_repo")
		defer clean()

		node, clean := testingNode(t, path)
		defer clean()

		smaddr, err := node.ServeTCPAPI("0")
		if err != nil {
			t.Fatal(err)
		}

		maddr, err := ma.NewMultiaddr(smaddr)
		if err != nil {
			t.Fatal(err)
		}

		addr, err := manet.ToNetAddr(maddr)
		if err != nil {
			t.Fatal(err)
		}

		url := fmt.Sprintf("http://%s/api/v0/id", addr.String())
		client := http.Client{Timeout: 5 * time.Second}

		_, err = client.Get(url)
		if err != nil {
			t.Fatal(err)
		}
	})

	t.Run("uds api", func(t *testing.T) {
		path, clean := testingTempDir(t, "uds_repo")
		defer clean()

		sockdir, clean := testingTempDir(t, "uds_api")
		defer clean()

		node, clean := testingNode(t, path)
		defer clean()

		sock := filepath.Join(sockdir, "sock")

		err := node.ServeUnixSocketAPI(sock)
		if err != nil {
			t.Fatal(err)
		}

		client := http.Client{
			Timeout: 5 * time.Second,
			Transport: &http.Transport{
				DialContext: func(_ context.Context, _, _ string) (net.Conn, error) {
					return net.Dial("unix", sock)
				},
			},
		}

		_, err = client.Get("http://unix/api/v0/id")
		if err != nil {
			t.Fatal(err)
		}
	})
}

func TestNodeServeGateway(t *testing.T) {
	var testcontent = []byte("hello world\n")

	t.Run("tpc gateway", func(t *testing.T) {
		path, clean := testingTempDir(t, "tpc_repo")
		defer clean()

		node, clean := testingNode(t, path)
		defer clean()

		smaddr, err := node.ServeTCPGateway("0", true)
		if err != nil {
			t.Fatal(err)
		}

		maddr, err := ma.NewMultiaddr(smaddr)
		if err != nil {
			t.Fatal(err)
		}

		addr, err := manet.ToNetAddr(maddr)
		if err != nil {
			t.Fatal(err)
		}

		api, err := ipfs_coreapi.NewCoreAPI(node.ipfsMobile.IpfsNode)
		if err != nil {
			t.Fatal(err)
		}

		file := ipfs_files.NewBytesFile(testcontent)
		resolved, err := api.Unixfs().Add(context.Background(), file)
		if err != nil {
			t.Fatal(err)
		}

		cid := resolved.Cid()

		url := fmt.Sprintf("http://%s/ipfs/%s", addr.String(), cid.String())
		client := http.Client{Timeout: 5 * time.Second}

		resp, err := client.Get(url)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close()

		b, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Fatal(err)
		}

		if !bytes.Equal(b, testcontent) {
			t.Fatalf("content `%s` are different from `%s`", b, testcontent)
		}
	})

	t.Run("uds gateway", func(t *testing.T) {
		path, clean := testingTempDir(t, "uds_repo")
		defer clean()

		sockdir, clean := testingTempDir(t, "uds_gateway")
		defer clean()

		node, clean := testingNode(t, path)
		defer clean()

		sock := filepath.Join(sockdir, "sock")
		err := node.ServeUnixSocketGateway(sock, true)
		if err != nil {
			t.Fatal(err)
		}

		client := http.Client{
			Timeout: 5 * time.Second,
			Transport: &http.Transport{
				DialContext: func(_ context.Context, _, _ string) (net.Conn, error) {
					return net.Dial("unix", sock)
				},
			},
		}

		api, err := ipfs_coreapi.NewCoreAPI(node.ipfsMobile.IpfsNode)
		if err != nil {
			t.Fatal(err)
		}

		file := ipfs_files.NewBytesFile(testcontent)
		resolved, err := api.Unixfs().Add(context.Background(), file)
		if err != nil {
			t.Fatal(err)
		}

		cid := resolved.Cid()
		url := fmt.Sprintf("http://unix/ipfs/%s", cid.String())
		resp, err := client.Get(url)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close()

		b, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Fatal(err)
		}

		if !bytes.Equal(b, testcontent) {
			t.Fatalf("content `%s` are different from `%s`", b, testcontent)
		}
	})
}
