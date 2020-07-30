module github.com/ipfs-shipyard/gomobile-ipfs/go

go 1.14

require (
	github.com/ipfs/go-ipfs v0.6.0
	github.com/ipfs/go-ipfs-api v0.1.0
	github.com/ipfs/go-ipfs-config v0.9.0
	github.com/ipfs/interface-go-ipfs-core v0.4.0 // indirect
	github.com/libp2p/go-libp2p v0.10.2
	github.com/libp2p/go-libp2p-core v0.6.1
	github.com/libp2p/go-libp2p-kad-dht v0.8.3 // indirect
	github.com/libp2p/go-libp2p-pubsub v0.3.3 // indirect
	github.com/libp2p/go-mplex v0.1.3 // indirect
	github.com/multiformats/go-multiaddr v0.2.2
	github.com/multiformats/go-multiaddr-net v0.1.5
	github.com/pkg/errors v0.9.1
	github.com/polydawn/refmt v0.0.0-20190807091052-3d65705ee9f1 // indirect
	github.com/whyrusleeping/cbor-gen v0.0.0-20200723185710-6a3894a6352b // indirect
	golang.org/x/crypto v0.0.0-20200728195943-123391ffb6de // indirect
	golang.org/x/sys v0.0.0-20200728102440-3e129f6d46b1 // indirect
)

replace (
	github.com/go-critic/go-critic v0.0.0-20181204210945-ee9bf5809ead => github.com/go-critic/go-critic v0.3.5-0.20190526074819-1df300866540
	github.com/golangci/golangci-lint => github.com/golangci/golangci-lint v1.18.0
)
