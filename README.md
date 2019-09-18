# gomobile-ipfs

> A collection of tools, libraries, links and discussions about running [IPFS](https://ipfs.io) and [libp2p](https://libp2p.io) on mobile (iOS & Android), using [gomobile](https://godoc.org/golang.org/x/mobile).

One of the methods of running IPFS on mobile is to embed a whole [go-ipfs](https://github.com/ipfs/go-ipfs) instance on mobile using [gomobile](https://godoc.org/golang.org/x/mobile). **It works, and it is beautiful.**

However, the mobile world comes with its problems and limitations that will ask everyone starting this journey to invest some time configuring everything.

This repo aims to provide useful libraries, tools, and pieces of information to help you focus on your app and not on the setup.

_:warning: this repo is planned to be moved on the IPFS organization_

## Problems & limitations of the mobile world

* Network connections through cellular connectivity
* Limited resources (CPU, RAM, Network, ...)
* App killed quite often (quick switch between foreground and background)
* Many operations are by _request_

## Solutions

* Things we've all tried at Berty and Textile
  * Limit the number of goroutines
  * Lower watermarks in conn manager
  * Use QUIC transport to be more resilient in case of switching between wifi/cellular
  * Background uploads & tasks
  * Connections prioritization by assigning them weight depending on their types, the platform, and the connectivity context
* Solutions we'd like to see
  * Native libp2p implementations
  * Better discovery of peers
  * Better cache solutions to avoid a long warm-up that doesn't fit in a short time frame (switch foreground -> background)
* Shared resources for mobile IPFS best practices
  * [**gomobile-ipfs** issues](https://github.com/berty/gomobile-ipfs/issues) _(this repo)_
  * [**go-ipfs** issues](https://github.com/ipfs/go-ipfs/issues)
  * _"Mobile mode"_ with an optimized IPFS config

## Projects using IPFS on mobile

_(alphabetically sorted)_

* [Berty](https://berty.tech/), a secure peer-to-peer messaging app that works with or without internet access, cellular data or trust in the network.
* [Textile](https://textile.io/), a set of tools and trust-less infrastructure for building censorship-resistant and privacy-preserving applications.
* _open a pull request to add your projects here_

## Install

_FIXME: TODO_

## Maintainers

The current maintainers of this repo are (sorted alphabetically):

* Antoine Eddi - [@aeddi](https://github.com/aeddi) - [Berty Technologies](https://github.com/berty)
* Carson Farmer - [@carsonfarmer](https://github.com/carsonfarmer) - [Textile](https://github.com/textileio)
* Guilhem Fanton - [@gfanton](https://github.com/gfanton) - [Berty Technologies](https://github.com/berty)
* Guillaume Louvigny - [@glouvigny](https://github.com/glouvigny) - [Berty Technologies](https://github.com/berty)
* Manfred Touron - [@moul](https://github.com/moul) - [Berty Technologies](https://github.com/berty)

## License


_FIXME: TODO_
