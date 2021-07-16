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

all: android.build

# should be run first once
configure:
	mvn --version || echo 'WARN: maven is needed to build the project'
	go version || echo 'WARN: golang is needed to build the project'
	javac -version || echo 'WARN: java is needed to build the project'

	go mod download
	$(GOMOBILE) init -v

build.ios: $(IOS_CORE)
android.build: $(ANDROID_CORE) $(ANDROID_REPO)

$(ANDROID_CORE): $(go_src) go.mod go.sum
	mkdir -p $(ANDROID_BUILD_DIR_INT)
	$(GOMOBILE) bind -v $(GOMOBILE_OPT) -target=android -o $(ANDROID_CORE) $(CORE_PACKAGE)
	# extract source for javadoc
	mkdir -p $(ANDROID_BUILD_DIR_INT)/src
	unzip -o $(ANDROID_JAR) -d $(ANDROID_BUILD_DIR_INT)/src

# android core
# javadoc generate javadoc in a jar file
android.core.javadoc: $(ANDROID_JAVADOC)
$(ANDROID_JAVADOC): $(ANDROID_CORE) $(ANDROID_JAR)
	mvn javadoc:jar

# repo deploy on a local directory
android.core.repo: $(ANDROID_REPO)
$(ANDROID_REPO): $(ANDROID_CORE) $(ANDROID_JAVADOC)
	MAVEN_URL=file://$(ANDROID_REPO) make android.core.deploy
	@touch $@

# deploy on a remote repository
android.core.deploy: $(ANDROID_CORE) $(ANDROID_JAVADOC)
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

# set-version override the current pom version
# @DEPRECATED(gfanton): do we need this ?
android.core.set-version:
	mvn versions:set -DnewVersion=$(ANDROID_VERSION)


# android gomobile ipfs



clean:
	rm -rf repo build target
