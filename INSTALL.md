# Build gomobile-ipfs

These are instructions to build gomobile-ipfs.

<!-- markdownlint-disable MD034 -->

## Prerequisites

* Required: Python pip3 version >= 19.2
* Required: Go version 1.18 or 1.19 (Go 1.17 not supported)
* Required on macOS: Command Line Developer Tools
* Required to build for Android: Android Studio
* Required to build on macOS: Xcode
* Required to build for iOS: cocoapods

Following are the steps to install each prerequisite (if it's needed for your
build target).

### macOS 11 and macOS 12

To install the Command Line Developer Tools, in a terminal enter:

    xcode-select --install

After the Developer Tools is installed, we need to make sure it is updated. In
System Preferences, click Software Update and update it if needed.

Install Go 1.18 or 1.19 with a package manager, or follow instructions at
https://go.dev/dl .

To install Android Studio, download and install the latest
android-studio-{version}-mac.dmg from https://developer.android.com/studio .
(Tested with Chipmunk 2021.2.1 .)

To install cocoapods, we need brew. To install brew, follow the instructions at
https://brew.sh . To install cocoapods, in a terminal enter:

    brew install cocoapods

### Ubuntu 18.04, 20.04 and 22.04

Install Go 1.18 or 1.19 with a package manager, or follow instructions at
https://go.dev/dl.

To install Python pip3, in a terminal enter:

    sudo apt install python3-pip

To install Android Studio, download the latest
android-studio-{version}-linux.tar.gz from
https://developer.android.com/studio . (Tested with Chipmunk 2021.2.1 .)
In a terminal, enter the following with the correct {version}:

    sudo tar -C /usr/local -xzf android-studio-{version}-linux.tar.gz

To launch Android Studio, in a terminal enter:

    /usr/local/android-studio/bin/studio.sh &

## Build for Android

* Launch Android Studio and accept the default startup options. Create a new
  default project (so that we get the main screen).
* On the Tools menu, open the SDK Manager.
* In the "SDK Platforms" tab, check "Android 11.0 (R)".
* In the "SDK Tools" tab, click "Show Package Details". Expand
  "NDK (Side by side)" and check "23.1.7779620".
* Click OK to install and close the SDK Manager.
* If you are not plugging in a real phone, on the Tools menu open the Device
  Manager and create an Android 10 device.

Open a new terminal to get the setup from the installers. To set the environment
variables, enter the following, depending on your platform. (You must do this
each time you start a new terminal, or put the commands in ~/.bash_profile .)

macOS:

    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/23.1.7779620"
    export PATH="$PATH:$ANDROID_HOME/emulator"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/Contents/Home"

Ubuntu:

    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    export PATH="$PATH:/usr/local/go/bin"
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/23.1.7779620"
    export PATH="$PATH:$ANDROID_HOME/emulator"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export JAVA_HOME="/usr/local/android-studio/jre"
    export PATH="$PATH:$JAVA_HOME/bin"

In a terminal, enter:

    git clone https://github.com/ipfs-shipyard/gomobile-ipfs
    cd gomobile-ipfs

To build the core, enter:

    make build_core.android

Or you can make other Android targets which also build the core. See:

    make help

## Build for iOS (macOS only)

Open a new terminal to get the setup from the installers. To set the environment
variables, enter the following. (You must do this each time you start a new
terminal, or put the commands in ~/.bash_profile.)

    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"

In a terminal, enter:

    git clone https://github.com/ipfs-shipyard/gomobile-ipfs
    cd gomobile-ipfs

To build the core, enter:

    make build_core.ios

Or you can make other iOS targets which also build the core. See:

    make help
