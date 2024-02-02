ALL_NODE_MODULES=node_modules $(wildcard */node_modules)
POD_NAME=GomobileIPFS
MODULE_NAME=react-native-go-ipfs
LOCAL_REPO=$(MODULE_NAME)/android/local_repo
BRIDGE_VERSION=0.0.1
GOMOBILE_IPFS_VERSION=0.0.1
LOCAL_BRIDGE_DIR=$(LOCAL_REPO)/ipfs/gomobile/android/$(BRIDGE_VERSION)
LOCAL_GOMOBILE_IPFS_DIR=$(LOCAL_REPO)/ipfs/gomobile/gomobile-ipfs/$(GOMOBILE_IPFS_VERSION)
ARCHIVE=$(MODULE_NAME).tgz
LOCAL_POD=$(MODULE_NAME)/ios/$(POD_NAME)

.PHONY: run.%
run.%:
	cd app && ./node_modules/.bin/react-native run-$*

.PHONY: deps.android
deps.android:
	$(MAKE) -C .. build.android
	cd ../android && ./gradlew bridge:build

	rm -fr $(LOCAL_REPO)
	cp -R ../android/local_repo $(LOCAL_REPO)
	mkdir -p $(LOCAL_BRIDGE_DIR)
	cp ../android/bridge/build/outputs/aar/bridge-debug.aar $(LOCAL_BRIDGE_DIR)/android-$(BRIDGE_VERSION).aar
	cp $(LOCAL_GOMOBILE_IPFS_DIR)/gomobile-ipfs-0.0.1.pom $(LOCAL_BRIDGE_DIR)/android-0.0.1.pom
	sed -i.bak 's/<artifactId>gomobile-ipfs<\/artifactId>/<artifactId>android<\/artifactId>/' $(LOCAL_BRIDGE_DIR)/android-0.0.1.pom

	cd $(MODULE_NAME) && yarn pack --filename ../$(ARCHIVE)
	cd app && yarn remove react-native-go-ipfs || true
	yarn cache clean
	cd app && yarn add file:../$(ARCHIVE)


.PHONY: deps.ios
deps.ios:
	$(MAKE) -C .. build.ios

	rm -fr $(LOCAL_POD)
	mkdir -p $(LOCAL_POD)
	cp -R ../ios/$(POD_NAME) ../ios/Frameworks ../ios/$(POD_NAME).podspec ../ios/LICENSE $(LOCAL_POD)

	cd $(MODULE_NAME) && yarn pack --filename ../$(ARCHIVE)
	cd app && yarn remove react-native-go-ipfs || true
	yarn cache clean
	cd app && yarn add file:../$(ARCHIVE)
	cd app/ios && pod install

.PHONY: clean
clean:
	rm -fr $(LOCAL_REPO) $(LOCAL_POD) $(ALL_NODE_MODULES) $(ARCHIVE)
