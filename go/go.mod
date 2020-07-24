module github.com/ipfs-shipyard/gomobile-ipfs/go

go 1.14

require (
	github.com/ipfs/go-ipfs v0.4.22-0.20200131155003-6e6cb2e53590
	github.com/ipfs/go-ipfs-api v0.0.3
	github.com/ipfs/go-ipfs-config v0.2.0
	github.com/ipfs/go-ipfs-files v0.0.6
	github.com/libp2p/go-libp2p v0.5.1
	github.com/libp2p/go-libp2p-core v0.3.0
	github.com/multiformats/go-multiaddr v0.2.0
	github.com/multiformats/go-multiaddr-net v0.1.1
	github.com/pkg/errors v0.9.1
	golang.org/x/crypto v0.0.0-20200115085410-6d4e4cb37c7d // indirect
	golang.org/x/net v0.0.0-20190628185345-da137c7871d7 // indirect
)

replace (
	github.com/go-critic/go-critic v0.0.0-20181204210945-ee9bf5809ead => github.com/go-critic/go-critic v0.3.5-0.20190526074819-1df300866540
	github.com/golangci/golangci-lint => github.com/golangci/golangci-lint v1.18.0
)
