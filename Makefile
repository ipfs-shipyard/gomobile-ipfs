GOMOBILE ?= go run golang.org/x/mobile/cmd/gomobile

ANDROID_VERSION ?= 0.0.42-dev

ANDROID_BRIDGE_REPO = $(ANDROID_REPO)/ipfs/gomobile/bridge

ANDROID_LIBS = ./android/libs/gomobile
ANDROID_CORE_AAR = $(ANDROID_LIBS)/core.aar

# ANDROID_CORE_REPO = $(ANDROID_REPO)/ipfs/gomobile/core/$(ANDROID_VERSION)
# ANDROID_CORE_JAR = $(ANDROID_BUILD_DIR_INT)/core-sources.jar

CORE_PACKAGE = github.com/ipfs-shipyard/gomobile-ipfs/go/bind/core
MAVEN_URL ?= https://maven.pkg.github.com/ipfs-shipyard/gomobile-ipfs

go_src = $(shell find go -name '*.go')

all: android.build

# should be run first once
configure:
	go version || echo 'WARN: golang is needed to build the project'
	javac -version || echo 'WARN: java is needed to build the project'

	go mod download
	$(GOMOBILE) init -v

build.ios: $(IOS_CORE)
android.build: android.gomobile.build android.core.repo

android.gomobile.build: $(ANDROID_CORE_AAR)
$(ANDROID_CORE_AAR): $(go_src) go.mod go.sum
	mkdir -p $(ANDROID_LIBS)
	$(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android -o $(ANDROID_CORE_AAR) $(CORE_PACKAGE)

# android core
# javadoc generate javadoc in a jar file
android.core.javadoc: $(ANDROID_CORE_JAVADOC)
$(ANDROID_CORE_JAVADOC): $(ANDROID_CORE_AAR) $(ANDROID_CORE_JAR)
	mvn javadoc:jar

# repo deploy on a local directory
android.core.repo: $(ANDROID_CORE_REPO)
$(ANDROID_CORE_REPO): $(ANDROID_CORE_AAR) $(ANDROID_CORE_JAVADOC)
	MAVEN_URL=file://$(ANDROID_REPO) make android.core.deploy
	@touch $@

# deploy on a remote repository
android.core.deploy: $(ANDROID_CORE_AAR) $(ANDROID_CORE_JAVADOC)
	mvn org.apache.maven.plugins:maven-deploy-plugin:3.0.0-M1:deploy-file \
			-Dversion=$(ANDROID_VERSION) \
			-Djavadoc=$(ANDROID_CORE_JAVADOC) \
			-Durl=$(MAVEN_URL) \
			-DrepositoryId=ipfs.gomobile \
			-Dfile=$(ANDROID_CORE_AAR) \
			-Dpackaging=aar \
			-DpomFile=pom.xml \
			-Dfiles=$(ANDROID_CORE_JAR) \
			-Dclassifiers=sources \
			-DrepositoryId=github \
			-Dtypes=jar

# android bridge ipfs
# publish inside local repository
android.bridge.repo: $(ANDROID_BRIDGE_REPO)
$(ANDROID_BRIDGE_REPO): $(ANDROID_CORE_REPO)
	GOMOBILE_IPFS_VERSION=$(ANDROID_VERSION) ./android/gradlew -p android --info 'publishToLocalRepository'

android.bridge.deploy: $(ANDROID_BRIDGE_REPO)
	GOMOBILE_IPFS_VERSION=$(ANDROID_VERSION) ./android/gradlew -p android --info 'publishToRemoteRepository'

# set-version override the current pom version
# @DEPRECATED(gfanton): do we need this ?
android.core.set-version:
	mvn versions:set -DnewVersion=$(ANDROID_VERSION)

clean:
	rm -rf $(ANDROID_LIBS)
