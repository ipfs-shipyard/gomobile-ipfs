MAKEFILE_DIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR = $(MAKEFILE_DIR)/../..

NODE_MODULES = $(MAKEFILE_DIR)/node_modules
MOD_FILES = $(MAKEFILE_DIR)/package.json $(MAKEFILE_DIR)/yarn.lock
PODS = $(MAKEFILE_DIR)/ios/Pods
POD_FILES = $(MAKEFILE_DIR)/ios/Podfile $(MAKEFILE_DIR)/ios/Podfile.lock

ROOT_BUILD_DIR = $(ROOT_DIR)/build
LIB_ANDROID_NEED_REBUILD = $(if $(shell $(MAKE) -C $(ROOT_DIR) -n build.android | grep 'Nothing to be done'),,build.android.lib)
BUILD_LIB_ANDROID = $(ROOT_BUILD_DIR)/android/ipfs.aar
INCLUDE_LIB_ANDROID = $(MAKEFILE_DIR)/android/app/libs/ipfs/ipfs.aar
LIB_IOS_NEED_REBUILD = $(if $(shell $(MAKE) -C $(ROOT_DIR) -n build.ios | grep 'Nothing to be done'),,build.ios.lib)
BUILD_LIB_IOS = $(ROOT_BUILD_DIR)/ios/Mobile.framework
INCLUDE_LIB_IOS = $(MAKEFILE_DIR)/ios/Mobile.framework

ANDROID_KEYSTORE = $(MAKEFILE_DIR)/android/app/debug.keystore
TEMPLATE_ANDROID_KEYSTORE = $(NODE_MODULES)/react-native/template/android/app/debug.keystore

RN = react-native
CONCURRENTLY = $(NODE_MODULES)/concurrently/bin/concurrently.js
IOS_UDID ?=

.PHONY: help build.android.debug build.android.release build.ios.debug build.ios.release build.android.lib build.ios.lib deps.android deps.ios clean.android fclean.ios clean.ios

help:
	@echo "Commands:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | grep -v / | sed 's/^/	$(HELP_MSG_PREFIX)make /'

build.android.debug: deps.android $(INCLUDE_LIB_ANDROID) $(ANDROID_KEYSTORE)
	$(CONCURRENTLY) \
		'$(RN) start --reset-cache' \
		'$(RN) run-android --no-packager --variant=debug'

build.android.release: deps.android $(INCLUDE_LIB_ANDROID) $(ANDROID_KEYSTORE)
	$(RN) run-android --no-packager --variant=release

build.ios.debug: deps.ios $(INCLUDE_LIB_IOS)
	$(CONCURRENTLY) \
		'$(RN) start --reset-cache' \
		'$(RN) run-ios --no-packager --configuration=Debug --scheme=IPFSMobileDemo $(IOS_UDID)'

build.ios.release: deps.ios $(INCLUDE_LIB_IOS)
	$(RN) run-ios --no-packager --configuration=Release --scheme=IPFSMobileDemo $(IOS_UDID)

$(INCLUDE_LIB_ANDROID): $(LIB_ANDROID_NEED_REBUILD) $(BUILD_LIB_ANDROID)
	cp $(BUILD_LIB_ANDROID) $(INCLUDE_LIB_ANDROID)

build.android.lib:
	$(MAKE) -C $(ROOT_DIR) build.android

$(INCLUDE_LIB_IOS): $(LIB_IOS_NEED_REBUILD) $(BUILD_LIB_IOS)
	cp -rf $(BUILD_LIB_IOS) $(INCLUDE_LIB_IOS)

build.ios.lib:
	$(MAKE) -C $(ROOT_DIR) build.ios

deps.android: $(NODE_MODULES)

deps.ios: $(NODE_MODULES) $(PODS)

$(NODE_MODULES): $(MOD_FILES)
	yarn install
	@touch $@

$(PODS): $(POD_FILES)
	cd $(MAKEFILE_DIR)/ios && pod install
	@touch $@

clean.android:
	$(MAKE) -C $(ROOT_DIR) clean.android
	cd $(MAKEFILE_DIR)/android \
		&& ./gradlew clean \
		&& ./gradlew cleanBuildCache

fclean.ios: clean.ios
	rm -rf $(HOME)/Library/Developer/Xcode/DerivedData

clean.ios:
	$(MAKE) -C $(ROOT_DIR) clean.ios
	cd $(MAKEFILE_DIR)/ios \
		&& xcodebuild clean \
		&& rm -rf build \
		&& rm -rf Pods
