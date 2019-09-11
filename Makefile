BUILD_DIR_IOS ?= ./build/ios
BUILD_DIR_ANDROID ?= ./build/android

GOMOBILES_OPT ?=

build: build.android build.ios

deps:
	go mod download
	go mod vendor

build.android: deps
	@mkdir -p $(BUILD_DIR_ANDROID)
	GO111MODULE=off gomobile bind -v $(GOMOBILES_OPT) -target=android -o $(BUILD_DIR_ANDROID)/ipfs.aar github.com/berty/gomobile-ipfs

build.ios: deps
	@mkdir -p $(BUILD_DIR_IOS)
	GO111MODULE=off gomobile bind -v $(GOMOBILES_OPT) -target=ios -o $(BUILD_DIR_IOS)/ipfs.framework github.com/berty/gomobile-ipfs

test:
	go test -v ./...
