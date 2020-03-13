MAKEFILE_DIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
MANIFEST_FILE = $(MAKEFILE_DIR)/Manifest.yml
UTILS_DIR = $(MAKEFILE_DIR)/utils
UTIL_MAVEN_FORMAT = $(UTILS_DIR)/maven_format
UTIL_MAVEN_FORMAT_REQ = $(UTIL_MAVEN_FORMAT)/requirements.txt
UTIL_MAVEN_FORMAT_CORE_BIN = $(UTIL_MAVEN_FORMAT)/maven_format_core.py
UTIL_MAVEN_PUBLISH = $(UTILS_DIR)/maven_publish
UTIL_MAVEN_PUBLISH_REQ = $(UTIL_MAVEN_PUBLISH)/requirements.txt
UTIL_MAVEN_PUBLISH_CORE_BIN = $(UTIL_MAVEN_PUBLISH)/maven_publish_core.py
UTIL_COCOAPOD_FORMAT = $(UTILS_DIR)/cocoapod_format
UTIL_COCOAPOD_FORMAT_REQ = $(UTIL_COCOAPOD_FORMAT)/requirements.txt
UTIL_COCOAPOD_FORMAT_BRIDGE_BIN = $(UTIL_COCOAPOD_FORMAT)/cocoapod_format_bridge.py
UTIL_COCOAPOD_FORMAT_CORE_BIN = $(UTIL_COCOAPOD_FORMAT)/cocoapod_format_core.py
UTIL_COCOAPOD_PUBLISH = $(UTILS_DIR)/cocoapod_publish
UTIL_COCOAPOD_PUBLISH_REQ = $(UTIL_COCOAPOD_PUBLISH)/requirements.txt
UTIL_COCOAPOD_PUBLISH_BRIDGE_BIN = $(UTIL_COCOAPOD_PUBLISH)/cocoapod_publish_bridge.py
UTIL_COCOAPOD_PUBLISH_CORE_BIN = $(UTIL_COCOAPOD_PUBLISH)/cocoapod_publish_core.py
BUILD_DIR = $(MAKEFILE_DIR)/build
PIP = pip3

GO_DIR = $(MAKEFILE_DIR)/../go
GO_SRC = $(shell find $(GO_DIR) -not \( -path $(GO_DIR)/vendor -prune \) -name \*.go)
GO_VENDOR = $(GO_DIR)/vendor
GO_MOD_FILES = $(GO_DIR)/go.mod $(GO_DIR)/go.sum

CORE_PACKAGE = github.com/ipfs-shipyard/gomobile-ipfs/go/bind/core
EXT_PACKAGE ?=
GOMOBILE = $(GOPATH)/bin/gomobile
GOMOBILE_OPT ?=
GOMOBILE_TARGET ?=

ANDROID_DIR = $(MAKEFILE_DIR)/../android
ANDROID_BUILD_DIR = $(BUILD_DIR)/android
ANDROID_BUILD_DIR_INT = $(ANDROID_BUILD_DIR)/intermediates
ANDROID_BUILD_DIR_INT_CORE = $(ANDROID_BUILD_DIR_INT)/core
ANDROID_BUILD_DIR_MAV = $(ANDROID_BUILD_DIR)/maven
ANDROID_CORE = $(ANDROID_BUILD_DIR_INT_CORE)/core.aar

IOS_DIR = $(MAKEFILE_DIR)/../ios
IOS_BUILD_DIR = $(BUILD_DIR)/ios
IOS_BUILD_DIR_INT = $(IOS_BUILD_DIR)/intermediates
IOS_BUILD_DIR_INT_CORE = $(IOS_BUILD_DIR_INT)/core
IOS_BUILD_DIR_CCP = $(IOS_BUILD_DIR)/cocoapods
IOS_CORE = $(IOS_BUILD_DIR_INT_CORE)/Core.framework

DOC_DIR = $(MAKEFILE_DIR)/../docs
ANDROID_DOC_DIR = $(DOC_DIR)/android
IOS_DOC_DIR = $(DOC_DIR)/ios


.PHONY: help build_core build_core.android build_core.ios publish publish_core publish_core.android publish_core.ios publish_bridge publish_bridge.android publish_bridge.ios re re.android re.ios test test_bridge test_bridge.android test_bridge.ios test_core clean clean.android clean.ios

help:
	@echo 'Commands:'
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | grep -v / | sed 's/^/	$(HELP_MSG_PREFIX)make /'

# Build core rules
build_core: build_core.android build_core.ios

build_core.android: $(ANDROID_BUILD_DIR_MAV)

$(ANDROID_BUILD_DIR_MAV): $(ANDROID_CORE) $(MANIFEST_FILE)
	@echo '------------------------------------'
	@echo '   Android Core: Maven formatting   '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_MAVEN_FORMAT_REQ) | wc -l)" != "$$(wc -l < $(UTIL_MAVEN_FORMAT_REQ))" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_MAVEN_FORMAT_REQ); echo; \
	fi
	@$(UTIL_MAVEN_FORMAT_CORE_BIN) && touch $(ANDROID_BUILD_DIR_MAV)
	@echo 'Done!'

$(ANDROID_CORE): $(ANDROID_BUILD_DIR_INT_CORE) $(GO_SRC) $(GO_VENDOR) | $(GOMOBILE)
	@echo '------------------------------------'
	@echo '   Android Core: Gomobile binding   '
	@echo '------------------------------------'
	@GO111MODULE=off $(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android$(GOMOBILE_TARGET) -o $(ANDROID_CORE) $(CORE_PACKAGE) $(EXT_PACKAGE)
	@echo 'Done!'

$(ANDROID_BUILD_DIR_INT_CORE):
	@mkdir -p $(ANDROID_BUILD_DIR_INT_CORE)

build_core.ios: $(IOS_BUILD_DIR_CCP)

$(IOS_BUILD_DIR_CCP): $(IOS_CORE) $(MANIFEST_FILE)
	@echo '------------------------------------'
	@echo '   iOS Core: CocoaPod formatting   '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_COCOAPOD_FORMAT_REQ) | wc -l)" != "$$(wc -l < $(UTIL_COCOAPOD_FORMAT_REQ))" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_COCOAPOD_FORMAT_REQ); echo; \
	fi
	@$(UTIL_COCOAPOD_FORMAT_CORE_BIN) && touch $(IOS_BUILD_DIR_CCP)
	@echo 'Done!'

$(IOS_CORE): $(IOS_BUILD_DIR_INT_CORE) $(GO_SRC) $(GO_VENDOR) | $(GOMOBILE)
	@echo '------------------------------------'
	@echo '     iOS Core: Gomobile binding     '
	@echo '------------------------------------'
	@GO111MODULE=off $(GOMOBILE) bind $(GOMOBILE_OPT) -target=ios$(GOMOBILE_TARGET) -o $(IOS_CORE) $(CORE_PACKAGE) $(EXT_PACKAGE)
	@echo 'Done!'

$(IOS_BUILD_DIR_INT_CORE):
	@mkdir -p $(IOS_BUILD_DIR_INT_CORE)

# Publish rules
publish: publish_core publish_bridge

publish_core: publish_core.android publish_core.ios

publish_core.android: build_core.android
	@echo '------------------------------------'
	@echo '   Android Core: Maven publishing   '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_MAVEN_PUBLISH_REQ) | wc -l)" != "$$(wc -l < $(UTIL_MAVEN_PUBLISH_REQ))" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_MAVEN_PUBLISH_REQ); echo; \
	fi
	@$(UTIL_MAVEN_PUBLISH_CORE_BIN)
	@echo 'Done!'

publish_core.ios: build_core.ios
	@echo '------------------------------------'
	@echo '   iOS Core: CocoaPod publishing   '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_COCOAPOD_PUBLISH_REQ) | wc -l)" != "$$(wc -l < $(UTIL_COCOAPOD_PUBLISH_REQ))" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_COCOAPOD_PUBLISH_REQ); echo; \
	fi
	@$(UTIL_COCOAPOD_PUBLISH_CORE_BIN)
	@echo 'Done!'

publish_bridge: publish_bridge.android publish_bridge.ios

publish_bridge.android:
	@echo '------------------------------------'
	@echo '  Android Bridge: Maven publishing  '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_MAVEN_FORMAT_REQ) -f $(UTIL_MAVEN_PUBLISH_REQ) | wc -l)" != "$$(cat $(UTIL_MAVEN_FORMAT_REQ) $(UTIL_MAVEN_PUBLISH_REQ) | sort | uniq | wc -l )" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_MAVEN_FORMAT_REQ) -r $(UTIL_MAVEN_PUBLISH_REQ); echo; \
	fi
	@cd $(ANDROID_DIR) && ./gradlew bridge:bintrayUpload
	@echo 'Done!'

publish_bridge.ios:
	@echo '------------------------------------'
	@echo '  iOS Bridge: CocoaPod publishing   '
	@echo '------------------------------------'
	@if [ "$$($(PIP) freeze | grep -f $(UTIL_COCOAPOD_FORMAT_REQ) -f $(UTIL_COCOAPOD_PUBLISH_REQ) | wc -l)" != "$$(cat $(UTIL_COCOAPOD_FORMAT_REQ) $(UTIL_COCOAPOD_PUBLISH_REQ) | sort | uniq | wc -l )" ]; then \
		echo 'Installing pip dependencies:'; $(PIP) install -r $(UTIL_COCOAPOD_FORMAT_REQ) -r $(UTIL_COCOAPOD_PUBLISH_REQ); echo; \
	fi
	@$(UTIL_COCOAPOD_FORMAT_BRIDGE_BIN) && $(UTIL_COCOAPOD_PUBLISH_BRIDGE_BIN)
	@echo 'Done!'

# Doc generation rules
docgen: docgen.android docgen.ios

docgen.android: $(ANDROID_DOC_DIR)
	@echo '------------------------------------'
	@echo '   Android Bridge: Doc generation   '
	@echo '------------------------------------'
	@cd $(ANDROID_DIR) && ./gradlew bridge:javadoc
	@cp -rf $(ANDROID_DIR)/bridge/javadoc/* $(ANDROID_DOC_DIR)
	@echo 'Done!'

$(ANDROID_DOC_DIR):
	@mkdir -p $(ANDROID_DOC_DIR)

docgen.ios: $(IOS_DOC_DIR)
	@echo '------------------------------------'
	@echo '     iOS Bridge: Doc generation     '
	@echo '------------------------------------'
	@cd $(IOS_DIR)/Bridge && jazzy -o $(IOS_DOC_DIR)
	@echo 'Done!'

$(IOS_DOC_DIR):
	@mkdir -p $(IOS_DOC_DIR)

test: test_core test_bridge

test_bridge: test_bridge.android test_bridge.ios

test_bridge.android: build_core.android
	@echo '------------------------------------'
	@echo '   Android Bridge: running test     '
	@echo '------------------------------------'
	@cd $(ANDROID_DIR) && ./gradlew bridge:test && \
	EMULATOR=$$(emulator -avd -list-avds | tail -n1); \
	if [ -z "$$EMULATOR" ]; then \
		>&2 echo "No emulator found to run the test";	\
		exit 1;	\
	fi;	\
	emulator -avd $$EMULATOR -no-boot-anim -no-window -no-snapshot-save -gpu swiftshader_indirect -noaudio & EMULATOR_PID=$$!; \
	adb wait-for-device shell 'while [[ -z $$(getprop sys.boot_completed) ]]; do sleep 1; done;'; \
	(cd $(ANDROID_DIR) && ./gradlew bridge:connectedAndroidTest); \
	kill $$EMULATOR_PID
	@echo 'Done!'

test_bridge.ios: build_core.ios
	@echo '------------------------------------'
	@echo '     iOS Bridge: running test       '
	@echo '------------------------------------'
	@DESTINATION=$$(xcodebuild -showdestinations -project $(IOS_DIR)/Bridge/GomobileIPFS.xcodeproj -scheme GomobileIPFSTests | awk '/Ineligible destinations for/ {exit} {print}' | grep 'platform:iOS Simulator' | awk -F 'id:' '{print $$2}' | cut -d',' -f1 | tail -n1); \
	if [ -z "$$DESTINATION" ]; then \
		>&2 echo "No compatible simulator found to run the test";	\
		exit 1;	\
	fi;	\
	xcodebuild test -project $(IOS_DIR)/Bridge/GomobileIPFS.xcodeproj -scheme GomobileIPFSTests -sdk iphonesimulator -destination "platform=iOS Simulator,id=$$DESTINATION"
	@echo 'Done!'

test_core: $(GO_VENDOR)
	@echo '------------------------------------'
	@echo '       Go Core: running test        '
	@echo '------------------------------------'
	@cd $(GO_DIR) && go test -v ./...
	@echo 'Done!'

$(GOMOBILE):
	@echo '------------------------------------'
	@echo '      Go: installing Gomobile       '
	@echo '------------------------------------'
	@GO111MODULE=off go get golang.org/x/mobile/cmd/gomobile
	@$(GOMOBILE) init -v
	@echo 'Done!'

$(GO_VENDOR): $(GO_MOD_FILES)
	@echo '------------------------------------'
	@echo '       Go: installing vendor        '
	@echo '------------------------------------'
	@cd $(GO_DIR) && GO111MODULE=on go mod vendor
	@echo 'Done!'

# Clean rules
clean: clean.android clean.ios

clean.android:
	@echo '------------------------------------'
	@echo '  Android Core: removing build dir  '
	@echo '------------------------------------'
	@rm -rf $(ANDROID_BUILD_DIR)
	@echo 'Done!'

clean.ios:
	@echo '------------------------------------'
	@echo '    iOS Core: removing build dir    '
	@echo '------------------------------------'
	@rm -rf $(IOS_BUILD_DIR)
	@echo 'Done!'
