module github.com/berty/gomobile-ipfs

go 1.12

require (
	berty.tech/go-ipfs-log v0.0.0-20190805145225-165c94541925
	github.com/AndreasBriese/bbloom v0.0.0-20190306092124-e2d15f34fcf9 // indirect
	github.com/dgryski/go-farm v0.0.0-20190423205320-6a90982ecee2 // indirect
	github.com/ipfs/go-datastore v0.0.5
	github.com/ipfs/go-filestore v0.0.2
	github.com/ipfs/go-ipfs v0.4.21
	github.com/ipfs/go-ipfs-config v0.0.3
	github.com/libp2p/go-libp2p v0.3.0
	github.com/libp2p/go-libp2p-core v0.2.0
	github.com/multiformats/go-multiaddr v0.0.4
	github.com/spf13/cobra v0.0.5 // indirect
	golang.org/x/net v0.0.0-20190620200207-3b0461eec859 // indirect
	golang.org/x/sys v0.0.0-20190626221950-04f50cda93cb // indirect
	google.golang.org/appengine v1.4.0 // indirect
)

// @HOTFIX
replace github.com/dgraph-io/badger v2.0.0-rc.2+incompatible => github.com/dgraph-io/badger v2.0.0-rc2+incompatible
