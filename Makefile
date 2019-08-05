BUILD_DIR_IOS ?= ./build/ios
BUILD_DIR_ANDROID ?= ./build/android

GOMOBILES_OPT ?=

build: build.android build.ios

build.android:
	@mkdir -p $(BUILD_DIR_IOS)
	gomobile bind -v $(GOMOBILES_OPT) -target=android -o $(BUILD_DIR_IOS)/ipfs.aar github.com/berty/gomobile-ipfs

build.ios:
	@mkdir -p $(BUILD_DIR_IOS)
	gomobile bind -v $(GOMOBILES_OPT) -target=ios -o $(BUILD_DIR_IOS)/ipfs.framework github.com/berty/gomobile-ipfs
