ALL_NODE_MODULES=node_modules $(wildcard */node_modules)
MODULE_NAME=react-native-goipfs
LOCAL_REPO=$(MODULE_NAME)/android/local_repo
BRIDGE_VERSION=0.0.1
GOMOBILE_IPFS_VERSION=0.0.1
LOCAL_BRIDGE_DIR=$(LOCAL_REPO)/ipfs/gomobile/android/$(BRIDGE_VERSION)
LOCAL_GOMOBILE_IPFS_DIR=$(LOCAL_REPO)/ipfs/gomobile/gomobile-ipfs/$(GOMOBILE_IPFS_VERSION)
ARCHIVE=react-native-goipfs.tgz

.PHONY: run
run: deps
	cd app && ./node_modules/.bin/react-native run-android

.PHONY: deps
deps:
	$(MAKE) -C .. build.android
	cd ../android && ./gradlew bridge:build

	rm -fr $(LOCAL_REPO)
	cp -R ../android/local_repo $(LOCAL_REPO)
	mkdir -p $(LOCAL_BRIDGE_DIR)
	cp ../android/bridge/build/outputs/aar/bridge-debug.aar $(LOCAL_BRIDGE_DIR)/android-$(BRIDGE_VERSION).aar
	cp $(LOCAL_GOMOBILE_IPFS_DIR)/gomobile-ipfs-0.0.1.pom $(LOCAL_BRIDGE_DIR)/android-0.0.1.pom
	sed -i 's/<artifactId>gomobile-ipfs<\/artifactId>/<artifactId>android<\/artifactId>/' $(LOCAL_BRIDGE_DIR)/android-0.0.1.pom

	cd react-native-goipfs && yarn pack --filename ../$(ARCHIVE)
	cd app && yarn


.PHONY: re
re: clean
	$(MAKE) run

.PHONY: clean
clean:
	rm -fr $(LOCAL_REPO) $(ALL_NODE_MODULES) $(ARCHIVE)
