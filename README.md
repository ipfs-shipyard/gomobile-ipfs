# gomobile-ipfs

This repo aims to provide packages for Android, iOS and React-Native that
allow one to run and use an IPFS node on mobile devices. It is also a place
to discuss the constraints of running IPFS on mobile in order to find
solutions and exchange tips.

:warning: _this repo is still experimental, contributions are very welcome_

You can check the packages documentation [here](https://ipfs-shipyard.github.io/gomobile-ipfs/).

## Roadmap

* [x] Basic Java/Swift <-> go-ipfs bindings
* [x] Packages built and published using CI
* [x] Unit tests using Android/iOS testing frameworks
* [x] Bind node config setters and getters
* [ ] InputStream as request body and request response (in progress)
* [ ] React-Native module (in progress)
* [ ] `SetStreamHandler(protocolID, handler)` and
`NewStream(peerID, protocolID)` bindings
* [ ] Android/iOS lifecycle management
* [ ] Improve this README

## Build

TODO

## Code example

TODO

## Lead Maintainers

* [Antoine Eddi](https://github.com/aeddi)
* [Guilhem Fanton](https://github.com/gfanton)
* [Guillaume Louvigny](https://github.com/glouvigny)
* [Manfred Touron](https://github.com/moul)

## License

Dual [MIT](./LICENSE-MIT)/[Apache-2.0](./LICENSE-APACHE) license
