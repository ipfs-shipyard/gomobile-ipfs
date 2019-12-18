ALL_NODE_MODULES=node_modules $(wildcard */node_modules)
MODULE_NAME=react-native-ipfs
LOCAL_REPO=$(MODULE_NAME)/android/local_repo
LOCAL_BRIDGE_DIR=$(LOCAL_REPO)/ipfs/gomobile/android

.PHONY: clean
clean:
	#rm -fr $(LOCAL_REPO)
	rm -fr $(ALL_NODE_MODULES)

.PHONY: deps
deps:
	yarn
	$(MAKE) -C .. build.android
	cp -R ../android/local_repo $(LOCAL_REPO)
	cd ../android && ./gradlew bridge:build
	mkdir -p $(LOCAL_BRIDGE_DIR)
	cp ../android/bridge/build/outputs/aar/bridge-debug.aar $(LOCAL_BRIDGE_DIR)/android.aar

.PHONY: run
run:
	cd app && ./node_modules/.bin/react-native run-android
