# react-native-ipfs

## Getting started

`$ npm install react-native-ipfs --save`

### Mostly automatic installation

`$ react-native link react-native-ipfs`

## Usage

```javascript
import IPFS from "react-native-ipfs";

const ipfs = new IPFS();

ipfs.start();

const response = ipfs.command("/id");
console.log(response.ID);

ipfs.stop();

// Delete the native instance
ipfs.clean();
```
