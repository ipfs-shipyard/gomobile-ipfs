# react-native-go-ipfs

Embeded go-ipfs instance exposed through a js class with asynchronous methods. Alpha software, use at your own risk.

## Getting started

`$ npm install react-native-go-ipfs --save`

### Android specific

You need to add:
```groovy
maven { url "${rootDir.getPath()}/../node_modules/react-native-go-ipfs/android/local_repo" }
```
to your react native app's `android/build.gradle` `allprojects.repositories` like shown below
```groovy
allprojects {
    repositories {
        maven { url "${rootDir.getPath()}/../node_modules/react-native-go-ipfs/android/local_repo" }
        mavenLocal()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }

        google()
        jcenter()
        maven { url 'https://jitpack.io' }
    }
}
```

This won't be needed as soon as we publish the maven packages.

### iOS specific

You need to add
```
pod 'GomobileIPFS', :path => '../node_modules/react-native-go-ipfs/ios/GomobileIPFS'
```
to your app's `ios/Podfile` like shown below

```
target 'app' do
  # Pods for app
  pod 'GomobileIPFS', :path => '../node_modules/react-native-go-ipfs/ios/GomobileIPFS'
```

## Usage

```javascript
import IPFS from "react-native-go-ipfs";

const ipfs = new IPFS();

await ipfs.start();

const response = await ipfs.command("/id");
console.log(response);

await ipfs.stop();
```
