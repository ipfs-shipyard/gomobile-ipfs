# OBSOLETE - IPFS Mobile React-Native Demo

<p align="center">
  <img src="./img/ipfs-mobile-status.jpg?raw=true" width="160" />
  <img src="./img/ipfs-mobile-files.jpg?raw=true" width="160" />
  <img src="./img/ipfs-mobile-explore.jpg?raw=true" width="160" />
  <img src="./img/ipfs-mobile-peers.jpg?raw=true" width="160" />
</p>

This example is obsolete since the Android and iOS packages have been implemented, it should be rewritten along with a proper React-Native package.

Simple React Native application that launch a gomobile-ipfs node and display its Webui in a webview.

Works on **Android** and **iOS**.

## Install

### Prerequisites

* For Android: you need to install and configure properly the Android SDK/NDK on your machine
* For iOS: you need to install XCode on a macOS machine

_More info [here](https://godoc.org/golang.org/x/mobile/cmd/gomobile#hdr-Build_a_library_for_Android_and_iOS)_

### Build

#### Debug build

* Run `make build.android.debug` or `make.ios.debug`

#### Release build

* Run `make build.android.release` or `make.ios.release`

_Run `make` to display the command list_

## License

Dual [MIT](../../LICENSE-MIT)/[Apache-2.0](../../LICENSE-APACHE) license
