# react-native-goipfs

## Getting started

`$ npm install react-native-goipfs --save`

### Mostly automatic installation

`$ react-native link react-native-goipfs`

## Usage

```javascript
import IPFS from "react-native-goipfs";

const ipfs = new IPFS();

ipfs.start();

const response = ipfs.command("/id");
console.log(response.ID);

ipfs.stop();

// Delete the native instance
ipfs.clean();
```
