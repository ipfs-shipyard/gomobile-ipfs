GOMOBILE ?= go run golang.org/x/mobile/cmd/gomobile

ANDROID_VERSION ?= 0.0.42-dev

ANDROID_BUILD_DIR_INT = ./build/android/intermediates
ANDROID_REPO = repo
ANDROID_JAVADOC = $(ANDROID_BUILD_DIR_INT)/core-javadoc.jar
ANDROID_CORE = $(ANDROID_BUILD_DIR_INT)/core.aar
ANDROID_JAR = $(ANDROID_BUILD_DIR_INT)/core-sources.jar

CORE_PACKAGE = github.com/ipfs-shipyard/gomobile-ipfs/go/bind/core
MAVEN_URL ?= https://maven.pkg.github.com/ipfs-shipyard/gomobile-ipfs

go_src = $(shell find go -name '*.go')
go_mod_files = go.mod go.sum

build.ios: $(IOS_CORE)

android.build: $(ANDROID_CORE) android.core.repo

$(ANDROID_BUILD_DIR_INT):
	mkdir -p $@
$(ANDROID_CORE): $(ANDROID_BUILD_DIR_INT) $(go_src) $(go_mod_files) gomobile_install
	$(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android -o $(ANDROID_CORE) $(CORE_PACKAGE)
	# extract source for javadoc
	mkdir -p $(ANDROID_BUILD_DIR_INT)/src
	unzip -o $(ANDROID_JAR) -d $(ANDROID_BUILD_DIR_INT)/src

# android core
# set-version override the current pom version
android.core.set-version:
	mvn versions:set -DnewVersion=$(ANDROID_VERSION)

# javadoc generate javadoc in a jar file
android.core.javadoc: $(ANDROID_JAVADOC)
$(ANDROID_JAVADOC): $(ANDROID_CORE) $(ANDROID_JAR)
	mvn javadoc:jar

# repo deploy on a local directory
android.core.repo: MAVEN_URL=file://$(ANDROID_REPO)
android.core.repo: android.core.deploy

# deploy on a remote repository
android.core.deploy: android.core.javadoc
	mvn org.apache.maven.plugins:maven-deploy-plugin:3.0.0-M1:deploy-file \
			-Dversion=$(ANDROID_VERSION) \
			-Djavadoc=$(ANDROID_JAVADOC) \
			-Durl=$(MAVEN_URL) \
			-DrepositoryId=ipfs.gomobile \
			-Dfile=$(ANDROID_CORE) \
			-Dpackaging=aar \
			-DpomFile=pom.xml \
			-Dfiles=$(ANDROID_JAR) \
			-Dclassifiers=sources \
			-DrepositoryId=github \
			-Dtypes=jar

android.clean:
	rm -rf repo build

gomobile_install:
	go mod download
	$(GOMOBILE) init -v
