module github.com/ipfs-shipyard/gomobile-ipfs/packages

go 1.16

require (
	github.com/ipfs-shipyard/gomobile-ipfs/go v0.0.0
	golang.org/x/mobile v0.0.0
)

replace golang.org/x/mobile => github.com/aeddi/mobile v0.0.3-silicon

replace github.com/ipfs-shipyard/gomobile-ipfs/go => ../go
