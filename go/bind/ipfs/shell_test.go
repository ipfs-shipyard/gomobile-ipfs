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
		AssertMethod func(t *testing.T, raw_json []byte)
	}{
		"id": {"id", testIDRequest},
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
					req := shell.NewRequest("id")
					res, err := req.Exec()
					if err != nil {
						t.Error(err)
					}

					cmdtc.AssertMethod(t, res)
				})
			}

		})
	}
}
