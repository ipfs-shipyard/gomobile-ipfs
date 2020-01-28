module github.com/ipfs-shipyard/gomobile-ipfs/go

go 1.13

require (
	github.com/AndreasBriese/bbloom v0.0.0-20190825152654-46b345b51c96 // indirect
	github.com/ipfs/go-ipfs v0.4.22-0.20200103222221-2b9a2d5eda90
	github.com/ipfs/go-ipfs-api v0.0.3
	github.com/ipfs/go-ipfs-config v0.2.0
	github.com/libp2p/go-libp2p v0.5.0
	github.com/libp2p/go-libp2p-core v0.3.0
	github.com/multiformats/go-multiaddr v0.2.0
	github.com/multiformats/go-multiaddr-net v0.1.1
	github.com/pkg/errors v0.8.1
	golang.org/x/net v0.0.0-20190628185345-da137c7871d7 // indirect
)

replace (
	github.com/go-critic/go-critic v0.0.0-20181204210945-ee9bf5809ead => github.com/go-critic/go-critic v0.3.5-0.20190526074819-1df300866540
	github.com/golangci/golangci-lint => github.com/golangci/golangci-lint v1.18.0
)
