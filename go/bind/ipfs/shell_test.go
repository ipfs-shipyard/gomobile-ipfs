package ipfs

import (
	"encoding/json"
	"strings"
	"testing"
)

func testIDRequest(t *testing.T, raw_json []byte) {
	id := struct {
		PeerID string `json:"id"`
	}{}

	err := json.Unmarshal(raw_json, &id)
	if err != nil {
		t.Fatal(err)
	}

	if !strings.HasPrefix(id.PeerID, "Qm") {
		t.Fatalf("PeerID isn't prefixed by `Qm` got `%.2s` has prefix instead", id.PeerID)
	}
}

// const xkcbURI = "/ipns/xkcd.hacdias.com/latest/info.json"

// func testCatRequest(t *testing.T, raw_json []byte) {
// 	latest := struct {
// 		Num int `json:"num"`
// 	}{}

// 	err := json.Unmarshal(raw_json, &latest)
// 	if err != nil {
// 		t.Fatal(err)
// 	}

// 	if latest.Num == 0 {
// 		t.Fatalf("latest.Num should be > 0, got `%d`", latest.Num)
// 	}
// }

func TestShell(t *testing.T) {
	sm, clean := testingSockmanager(t)
	defer clean()

	sockA, err := sm.NewSockPath()
	if err != nil {
		t.Fatal(err)
	}

	path, clean := testingTempDir(t, "repo")
	defer clean()

	node, clean := testingNode(t, path)
	defer clean()

	/// table cases
	// clients
	casesClient := map[string]struct{ MAddr string }{
		"tcp shell": {"/ip4/127.0.0.1/tcp/0"},
		"uds shell": {"/unix/" + sockA},
	}

	// commands
	casesCommand := map[string]struct {
		Command      string
		Args         []string
		AssertMethod func(t *testing.T, raw_json []byte)
	}{
		"id": {"id", []string{}, testIDRequest},
		// "cat xkcb": {"cat", []string{xkcbURI}, testCatRequest},
	}

	for clientk, clienttc := range casesClient {
		t.Run(clientk, func(t *testing.T) {
			maddr, err := node.ServeMultiaddr(clienttc.MAddr)
			if err != nil {
				t.Fatal(err)
			}

			shell, err := NewShell(maddr)
			if err != nil {
				t.Fatal(err)
			}

			for cmdk, cmdtc := range casesCommand {
				t.Run(cmdk, func(t *testing.T) {
					req := shell.NewRequest(cmdtc.Command)
					for _, arg := range cmdtc.Args {
						req.Argument(arg)
					}

					res, err := req.Send()
					if err != nil {
						t.Error(err)
					}

					cmdtc.AssertMethod(t, res)
				})
			}

		})
	}
}
