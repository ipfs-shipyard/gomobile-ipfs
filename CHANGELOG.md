# Global Changelog

## [1.2.1](https://github.com/ipfs-shipyard/gomobile-ipfs/compare/v1.2.0...v1.2.1) (2020-09-13)


### Bug Fixes

* race condition in node's closing ([16fa855](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/16fa855aa6228074f50f2c736187c17ed698f53a))

# [1.2.0](https://github.com/ipfs-shipyard/gomobile-ipfs/compare/v1.1.1...v1.2.0) (2020-09-10)


### Bug Fixes

* bump deps ([bb0afcb](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/bb0afcb5d58a68479f2f9fc0ec43e78ac458dd1a))
* remove armv7 from XCode archs config (support dropped by gomobile) ([38476dc](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/38476dcf0e3f50e312a757c807506b70ea04a83c))
* restore plist for unit tests ([1c0d0f4](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/1c0d0f41698fe035c83f7df7a214314ef2fea6c3))
* update & fix go mod ([d6caf1d](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/d6caf1d717d410f88fecc8a1d75f37f055f203db))


### Features

* Add enable pubsub/namesys extra opt ([33af183](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/33af18397c89cf777e1768afc0d97c40f292c015))

## [1.1.1](https://github.com/ipfs-shipyard/gomobile-ipfs/compare/v1.1.0...v1.1.1) (2020-05-15)


### Bug Fixes

* various bug fixes and improvements on ci publish jobs ([95ebb27](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/95ebb27ad29a4f10c6b9d8dfe801b46fcceb1f4f))

# [1.1.0](https://github.com/ipfs-shipyard/gomobile-ipfs/compare/v1.0.0...v1.1.0) (2020-04-20)


### Features

* bind config setters/getters on android ([ccf4b45](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/ccf4b45ce25fdedbf5e4f67848714778909363c1))
* bind config setters/getters on ios ([c4e4ac8](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/c4e4ac85713a20e4500df65b0303538bf318c655))

# 1.0.0 (2020-03-17)


### Bug Fixes

* **ios:** enable tcp shell on ios simulator only ([a9c7cb9](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/a9c7cb937d9ef31b50125c3ab271f95f7c85eb66))
* **ios:** Fix IPNS resolve on iOS ([22d9746](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/22d97462be6fdef44cf509a5f9abf1d92c8d828c))
* **shell:** Remove infinite recursive call method exec ([8d997a9](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/8d997a9ca55c26cca0f72d43dcae68ef372c96ec))
* few fixes and refactor so Android and iOS package API are identical ([3388954](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/3388954abf06f00044d4bf62d08c7b4ae7883da0))
* fix iOS demo application ([106c14e](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/106c14e774054b9a08d1ce5e63d57c2d08fc1198))
* fix sock file creation ([6a83055](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/6a83055716cf978a2f419be7b40843f3bc6a3a13))
* go test wrong path ([4479da1](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/4479da18ace20936692c1a59a1605171c856f584))
* refactor swift API + few fixes on socket manager ([efd89fb](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/efd89fb598cd71b0170b36b76ee8a4edadf21d2b))
* remove obsolete bootstrap fix and reset RSA key size checks to 2048 ([781b0cf](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/781b0cf8e21f5e5db7187b5c910edca55f0deadd))
* **api:** Don't use wildcard for 'Access-Control-Allow-Origin' ([d032373](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/d0323733b00822fc2f19ed4923f156cf0778886a))
* **ios:** Fix ios getApiAddrs method ([2400394](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/2400394f80daff78bde42539060016874c6542f3))
* **ios:** Fix peer counter ([c91e439](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/c91e439bcf1ae10b0d589eeff9a0a40791a94473))
* **sock:** Add static var for sockmanager ([eef3564](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/eef35646d98b82daaf18302722e501246eaf7502))
* **test:** remove convey & update test ([7f66a19](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/7f66a19098f91fb22fd116cc077d1fd6894844a2))
* build ios in release mode ([e43d03c](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/e43d03c38b58bf2df06e001c2fd78a5ba2f55048))
* fixes tests post-refactor ([e15648f](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/e15648fbf8c10fe72778f66f37a01a91599349ff))
* fixes xerrors modules import with go 1.13 + tidy ([dfd6cbf](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/dfd6cbf9462ce618a4ce76cfc818cd619261c99d))
* multiple bug and typo fixes: android, ios, js, etc ([e165d6e](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/e165d6e2100ad67328726deb40dca7acefe85b76))
* quick & dirty fix for functions with multiple return on Darwin ([047addf](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/047addf667be08b32f984660c091ac0d48d8c800))
* rollback to go 1.12 because 1.13 causes go mod errors ([e8d4469](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/e8d4469c6b8b5eb1fb5e9f308dcc0d856958e50d))
* temporary lower minimum RSA key length to allows bootstrap to work ([9196d8b](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/9196d8ba456dd3f42d154d7e7c2e69fce8e57628))
* tmp fix for gomobile build ([e3af32d](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/e3af32d166a064166c3bb94935d730dec1bee396))
* update android network security in release mode ([a2d211d](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/a2d211daf7540c9f66e8ffbfea7a50f60bdd718a))
* **node:** bootstrap peers on new node ([9f9cdef](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/9f9cdef217ca90e1720ab07596f4d4d7421cf8de))
* updated and fixed go mod + tidy ([06b102a](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/06b102a0163a3857738f5470b149a2314803c209))


### Features

* **android:** get XKCD cIDs using IPNS/IPFS instead of local json ([804bbce](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/804bbceab46542a8eb7257a96ac9c6cf46ffb76d))
* **android:** Replace command method by RequestBuilder ([3d19c65](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/3d19c65d4831847f733895f4a7f9cd39c61af206))
* **go:** Add send command to shell ([b2f7611](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/b2f7611edc86a9628a27ecb748f9965bcdd7fa19))
* **go:** Update to go 1.13 ([3b75ba0](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/3b75ba0253f3368082306ff17406d39f46b8ef5d))
* **go:** Update to go-ipfs-api v0.0.3 ([efdf0d2](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/efdf0d24b1b374564741e73d112fced6daefbaa0))
* **ios:** get XKCD cIDs using IPNS/IPFS instead of local json ([1461ac1](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/1461ac1b2b026762270a4f019cf523f434ae75bf))
* **ios:** Replace commands methods by RequestBuilder ([ebc2ccc](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/ebc2ccca0e876c8998123475e92d1781d9bc9189))
* **mod:** update to ipfs last commit ([c6198c3](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/c6198c3ae77968b569cb320729268134bd970c87))
* adapt demo application to new Android bridge ([9729af3](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/9729af36afc8453cf22b348340345ed339263d7e))
* add Makefile and implem build commands ([281c7b4](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/281c7b450d1b5b81eb1310fd0f761c465b658e96))
* add repo in-memory lock for NewNode / node.Close() ([29de656](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/29de6561a51ee276fadce002966cabbe0f8ad06a))
* add repo in-memory lock for NewNode / node.Close() ([714f38d](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/714f38d107868d5c2a310d1a3e70dce394c1c935))
* add variable for additionnal go package in Makefile ([f0f6a52](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/f0f6a52b29cf87ccf679d05fe8a57b6c0251e85a))
* basic implemen of android example app ([ee57dd3](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/ee57dd35965f5cf4beeb9ed32639e1b219a410fe))
* better swift error ([b15261d](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/b15261de1776d3e4a06011d28b18bef97a3fd7cf))
* clean Android: access, typo, asyncTask in activity, etc ([c6b632f](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/c6b632f8946671ac23a7fa42cd1e8b24ac3a0b99))
* clean Android: access, typo, asyncTask in activity, etc ([65d5a88](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/65d5a88acb261d37777294680ea15cf29927ac76))
* implement Android IPFS class ([aef1689](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/aef168904414274f4ee52c0a44060c878631ae4a))
* improve Android example app ([4304e27](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/4304e27fee0730a1b778c512fa4a0958cc2d3973))
* improve iOS example app ([eb08c5a](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/eb08c5a14ac6c30cd39b1eae88da9b2b018cebf0))
* **api:** handle unix socket domain ([ffb051e](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/ffb051eb8ab78c877dcc38c09b1950246bad4ba0))
* **ios:** create base classes for ios ([05e2672](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/05e2672d57ef679da5d161323997d3f6fe8d5bb0))
* **ipfs:** use tcp shell on simulator ([3e4f7ef](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/3e4f7efe84d74748c4c5784e1adf753ad91c176a))
* setup android local/remote dependency retrieval and version number ([334fa13](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/334fa13dd2a39a68f03efec62bc827a42b7d19e8))
* wip basic sockmanager (untested/unbridged) ([2c16356](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/2c163561638d044b12da7c7ad27ae74b6d15e957))
* **ios:** Add ipfs bridge on ios ([6b08685](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/6b08685b4d0d82abe7e569957bb211a74ca96c7e))
* **mobile:** Add base mobile ipfs node ([d91426f](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/d91426fd98cfc4b70bce0effc9672024a46729cb))
* **node:** Use random port for api ([709a6a4](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/709a6a4c346370f2b97e4a6afda4397f20226567))
* **react:** Add react native example for android ([df8188b](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/df8188b8251061a6c38f46f8c9ab4851a05303a3))
* **test:** Add mobile test ([1daa641](https://github.com/ipfs-shipyard/gomobile-ipfs/commit/1daa6419d289ef23d98701f9d837b4f36cf02e23))


# Initial version

## Golang Core

- Provides basic bindings to go-ipfs
- Provides a sockmanager that allows user to create UDS easily
- Only supports simple types as input/output for request (byte[] or string)

## Android/iOS Bridge

- Provides a convenient IPFS Class that wraps underlying go objects:
  - Repo path in configurable
  - (Android) Repo storage is configurable: external or internal
  - Basic methods that start, stop and restart the node
  - NewRequest method that takes a command and returns a RequestBuilder
- Provides a RequestBuilder Class:
  - Simple bindings to the go-ipfs RequestBuilder
  - Provides methods to set headers, options, arguments and body
  - Method `send` returns a byte array
  - (Android) Method `sendToJSONList` returns a JSON list
  - (iOS) Method `sendToDict` returns a dict

## Android/iOS Example Apps

- Starts a node and display its peerID
- Displays the number of connected peers
- Provides a `Random XKCD` button that download a random XKCD from IPFS
and displays it
