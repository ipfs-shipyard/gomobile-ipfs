GOMOBILE ?= go run golang.org/x/mobile/cmd/gomobile

ANDROID_BUILD_DIR_INT = ./build/android/intermediates
ANDROID_REPO = repo
ANDROID_CORE = $(ANDROID_BUILD_DIR_INT)/core.aar
ANDROID_JAR = $(ANDROID_BUILD_DIR_INT)/core-sources.jar

CORE_PACKAGE = github.com/ipfs-shipyard/gomobile-ipfs/go/bind/core
MAVEN_URL ?= file://repo
MAVEN_REPO ?= https://maven.pkg.github.com/ipfs-shipyard/gomobile-ipfs
ANDROID_VERSION ?= 0.0.42-dev

go_src = $(shell find go -name '*.go')
go_mod_files = go.mod go.sum

build.ios: $(IOS_CORE)

android.build: $(ANDROID_CORE) android.repo

$(ANDROID_BUILD_DIR_INT):
	mkdir -p $@
$(ANDROID_CORE): $(ANDROID_BUILD_DIR_INT) $(go_src) $(go_mod_files) gomobile_install
	$(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android -o $(ANDROID_CORE) $(CORE_PACKAGE)
	# test for javadoc
	mkdir -p $(ANDROID_BUILD_DIR_INT)/src
	unzip -o $(ANDROID_JAR) -d $(ANDROID_BUILD_DIR_INT)/src


android.set-version:
	mvn versions:set -DnewVersion=$(ANDROID_VERSION)

android.repo:
	MAVEN_URL=file://$(ANDROID_REPO) make android.deploy
android.deploy: android.set-version
	mvn \
		org.apache.maven.plugins:maven-deploy-plugin:3.0.0-M1:deploy-file \
			-Dversion=$(ANDROID_VERSION)
			-Durl=$(MAVEN_URL) \
			-DrepositoryId=ipfs.gomobile \
			-Dfile=$(ANDROID_CORE) \
			-Dpackaging=aar \
			-DpomFile=pom.xml \
			-Dfiles=$(ANDROID_JAR) \
			-Dclassifiers=sources \
			-DrepositoryId=github \
			-Dtypes=jar

# testing
android.javadoc:
	mvn javadoc:javadoc -DlocalRepositoryPath=./repo

gomobile_install:
	go mod download
	$(GOMOBILE) init -v
