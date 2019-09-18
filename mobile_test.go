package mobile

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"strings"
	"testing"

	ipfs_api "github.com/ipfs/go-ipfs-api"
	ipfs_config "github.com/ipfs/go-ipfs-config"

	. "github.com/smartystreets/goconvey/convey"
)

const sampleFakeConfig = `
{
	"Addresses": {
		"API": "/ip4/127.0.0.1/tcp/5001",
		"Swarm": [
			"/ip4/0.0.0.0/tcp/0",
			"/ip6/::/tcp/0"
		]
	},
	"Bootstrap": [
		"/ip4/127.0.0.1/tcp/4001/ipfs/12D3KooWDWJ473M3fXMEcajbaGtqgr6i6SvDdh5Ru9i5ZzoJ9Qy8"
	]
}
`

func TestMobile(t *testing.T) {
	var (
		testCfg  *Config
		testRepo *Repo
		testNode Node
		testID   *ipfs_config.Identity

		err error
	)

	defer func() {
		if testNode != nil {
			_ = testNode.Close()
		}

		if testRepo != nil {
			_ = testRepo.Close()
		}
	}()

	tmpdir, err := ioutil.TempDir("", "gomobile_ipfs_test")
	if err != nil {
		panic(err)
	}

	defer os.RemoveAll(tmpdir)

	Convey("test config", t, FailureHalts, func() {
		Convey("test get/set config", FailureHalts, func() {
			var cfg *Config
			var val []byte
			var apiAddr string
			var bootstrapAddrs []string

			// create a new config
			cfg, err = NewConfig([]byte(sampleFakeConfig))
			So(err, ShouldBeNil)
			So(cfg, ShouldNotBeNil)

			// get the whole config
			raw_cfg, err := cfg.Get()
			So(err, ShouldBeNil)
			So(raw_cfg, ShouldNotBeEmpty)

			// get a fake key
			val, err = cfg.GetKey("FAKEKEY")
			So(err, ShouldNotBeNil)

			// get Api value
			val, err = cfg.GetKey("Addresses.API")
			So(err, ShouldBeNil)

			// check if api value is correct
			err = json.Unmarshal(val, &apiAddr)
			So(err, ShouldBeNil)
			So(apiAddr, ShouldEqual, "/ip4/127.0.0.1/tcp/5001")

			// get bootstrap value
			val, err = cfg.GetKey("Bootstrap")
			So(err, ShouldBeNil)

			// check bootstrap value
			err = json.Unmarshal(val, &bootstrapAddrs)
			So(err, ShouldBeNil)
			So(len(bootstrapAddrs), ShouldBeGreaterThan, 0)

			// update bootstrap value
			err = cfg.SetKey("Bootstrap", []byte("[]"))
			So(err, ShouldBeNil)

			// get bootstrap value again
			val, err = cfg.GetKey("Bootstrap")
			So(err, ShouldBeNil)

			// check bootstrap value again
			err = json.Unmarshal(val, &bootstrapAddrs)
			So(err, ShouldBeNil)
			So(len(bootstrapAddrs), ShouldEqual, 0)

		})

		Convey("test default config", FailureHalts, func() {
			var val []byte

			testCfg, err = NewDefaultConfig()
			So(err, ShouldBeNil)
			So(testCfg, ShouldNotBeNil)

			val, err = testCfg.GetKey("Identity")
			So(err, ShouldBeNil)

			err = json.Unmarshal(val, &testID)
			So(testID.PeerID, ShouldStartWith, "Qm")

			// do not bootstrap
			err = testCfg.SetKey("Bootstrap", []byte("[]"))
			So(err, ShouldBeNil)
		})

		Convey("test repo", FailureHalts, func() {
			var cfg *Config
			var ok bool

			// check if repo is initialized
			ok = RepoIsInitialized(tmpdir)
			So(ok, ShouldBeFalse)

			// init repo
			err = InitRepo(tmpdir, testCfg)
			So(err, ShouldBeNil)

			// open repo
			testRepo, err = OpenRepo(tmpdir)
			So(err, ShouldBeNil)
			So(testRepo, ShouldNotBeNil)

			// get repo config
			cfg, err = testRepo.GetConfig()
			So(err, ShouldBeNil)
			So(testCfg.getConfig(), ShouldResemble, cfg.getConfig())

			// re check if repo is initialized
			ok = RepoIsInitialized(tmpdir)
			So(ok, ShouldBeTrue)
		})

		Convey("test node", FailureHalts, func() {
			var id *ipfs_api.IdOutput

			testNode, err = NewNode(testRepo)
			So(err, ShouldBeNil)

			addrs := strings.Split(testNode.GetApiAddrs(), ",")
			So(len(addrs), ShouldBeGreaterThan, 0)

			shell := ipfs_api.NewShell(addrs[0])
			id, err = shell.ID()
			So(err, ShouldBeNil)
			So(id.ID, ShouldEqual, testID.PeerID)
		})
	})
}
