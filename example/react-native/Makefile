ROOT = $(PWD)/../../
BUILD_DIR_IOS = $(PWD)/ios/Frameworks
BUILD_DIR_ANDROID = $(PWD)/android/app/libs/ipfs

build.go: build.go.ios build.go.android

build.go.ios:
	BUILD_DIR_IOS=$(BUILD_DIR_IOS) make -C $(ROOT) build.ios

build.go.android:
	BUILD_DIR_ANDROID=$(BUILD_DIR_ANDROID) make -C $(ROOT) build.android
