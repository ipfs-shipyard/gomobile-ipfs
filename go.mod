module github.com/berty/gomobile-ipfs

go 1.13

require (
	github.com/AndreasBriese/bbloom v0.0.0-20190825152654-46b345b51c96 // indirect
	github.com/gopherjs/gopherjs v0.0.0-20190430165422-3e4dfb77656c // indirect
	github.com/ipfs/go-ipfs v0.4.21
	github.com/ipfs/go-ipfs-api v0.0.2
	github.com/ipfs/go-ipfs-config v0.0.3
	github.com/ipfs/go-merkledag v0.1.0 // indirect
	github.com/jtolds/gls v4.2.2-0.20181110203027-b4936e06046b+incompatible // indirect
	github.com/libp2p/go-libp2p v0.3.0
	github.com/libp2p/go-libp2p-connmgr v0.1.0 // indirect
	github.com/libp2p/go-libp2p-core v0.2.0
	github.com/libp2p/go-libp2p-host v0.1.0 // indirect
	github.com/libp2p/go-libp2p-interface-connmgr v0.1.0 // indirect
	github.com/libp2p/go-libp2p-kad-dht v0.1.0 // indirect
	github.com/libp2p/go-libp2p-metrics v0.1.0 // indirect
	github.com/libp2p/go-libp2p-net v0.1.0 // indirect
	github.com/libp2p/go-libp2p-pnet v0.1.0 // indirect
	github.com/libp2p/go-libp2p-protocol v0.1.0 // indirect
	github.com/libp2p/go-libp2p-quic-transport v0.1.2-0.20190813044021-61a9a79cbf2e // indirect
	github.com/libp2p/go-stream-muxer v0.1.0 // indirect
	github.com/multiformats/go-multiaddr v0.0.4
	github.com/multiformats/go-multiaddr-net v0.0.1
	github.com/smartystreets/assertions v0.0.0-20190401211740-f487f9de1cd3 // indirect
	github.com/smartystreets/goconvey v0.0.0-20190222223459-a17d461953aa
	go.opencensus.io v0.22.0 // indirect
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4 // indirect
	golang.org/x/net v0.0.0-20190628185345-da137c7871d7 // indirect
	golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7 // indirect
)

// @HOTFIX
replace (
	github.com/dgraph-io/badger v2.0.0-rc.2+incompatible => github.com/dgraph-io/badger v2.0.0-rc2+incompatible
	github.com/libp2p/go-libp2p-quic-transport => github.com/libp2p/go-libp2p-quic-transport v0.1.2-0.20190830164807-17543aa14ed2
)
