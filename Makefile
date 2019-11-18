MAKEFILE_DIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
GO_DIR = $(MAKEFILE_DIR)/go
ANDROID_DIR = $(MAKEFILE_DIR)/android
IOS_DIR = $(MAKEFILE_DIR)/ios
GO_SRC = $(shell find $(GO_DIR) -not \( -path $(GO_DIR)/vendor -prune \) -name \*.go)

GOMOBILE = $(GOPATH)/bin/gomobile
GOMOBILE_OPT ?=
ADDITIONAL_GO_PKG ?=

VERSION_FILE = $(MAKEFILE_DIR)/version
LIB_VERSION = $(shell cat $(VERSION_FILE))

VENDOR = $(GO_DIR)/vendor
MOD_FILES = $(GO_DIR)/go.mod $(GO_DIR)/go.sum

BUILD_DIR_IOS = $(IOS_DIR)/Frameworks
BUILD_LIB_IOS = $(BUILD_DIR_IOS)/Mobile.framework
BUILD_DIR_ANDROID = $(ANDROID_DIR)/local_repo/ipfs/gomobile/gomobile-ipfs/$(LIB_VERSION)
BUILD_LIB_ANDROID = $(BUILD_DIR_ANDROID)/gomobile-ipfs-$(LIB_VERSION).aar
BUILD_POM_ANDROID = $(BUILD_DIR_ANDROID)/gomobile-ipfs-$(LIB_VERSION).pom
POM_TEMPLATE = $(ANDROID_DIR)/pom_template

.PHONY: help build build.android build.ios test deps clean clean.android clean.ios re re.ios re.android

help:
	@echo "Commands:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | grep -v / | sed 's/^/	$(HELP_MSG_PREFIX)make /'

build: build.android build.ios

build.android: $(BUILD_LIB_ANDROID) $(BUILD_POM_ANDROID)

$(BUILD_LIB_ANDROID): $(BUILD_DIR_ANDROID) $(GO_SRC) $(VENDOR) | $(GOMOBILE)
	GO111MODULE=off $(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android -o $(BUILD_LIB_ANDROID) github.com/berty/gomobile-ipfs/go $(ADDITIONAL_GO_PKG)

$(BUILD_DIR_ANDROID):
	mkdir -p $(BUILD_DIR_ANDROID)

$(BUILD_POM_ANDROID):
	sed -e 's/{{LIB_VERSION}}/$(LIB_VERSION)/g' $(POM_TEMPLATE) > $(BUILD_POM_ANDROID)

build.ios: $(BUILD_LIB_IOS)

$(BUILD_LIB_IOS): $(BUILD_DIR_IOS) $(GO_SRC) $(VENDOR) | $(GOMOBILE)
	GO111MODULE=off $(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=ios -o $(BUILD_LIB_IOS) github.com/berty/gomobile-ipfs/go $(ADDITIONAL_GO_PKG)

$(BUILD_DIR_IOS):
	mkdir -p $(BUILD_DIR_IOS)

test: $(VENDOR)
	cd $(GO_DIR) && go test -v ./...

deps: $(VENDOR)

$(GOMOBILE):
	GO111MODULE=off	go get golang.org/x/mobile/cmd/gomobile
	gomobile init -v

$(VENDOR): $(MOD_FILES)
ifneq ($(wildcard /bin/bash),)
	@bash -c 'echo "GO111MODULE=on go mod vendor" && cd $(GO_DIR) && GO111MODULE=on go mod vendor 2> >(grep -v "warning: ignoring symlink" 1>&2)'
else
	cd $(GO_DIR) && GO111MODULE=on go mod vendor
endif

clean: clean.android clean.ios

clean.android:
	rm -rf $(BUILD_DIR_ANDROID)

clean.ios:
	rm -rf $(BUILD_DIR_IOS)

re: re.android re.ios

re.android: clean.android build.android

re.ios: clean.ios build.ios
