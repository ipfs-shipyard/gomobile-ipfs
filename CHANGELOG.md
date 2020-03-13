# Gomobile-IPFS Global Changelog

# Initial version

## Golang Core

- Provides basic bindings to go-ipfs
- Provides a sockmanager that allows user to create UDS easily
- Only supports simple types as input/output for request (byte[] or string)

## Android/iOS Bridge

- Provides a convenient IPFS Class that wraps underlying go objects:
  - Repo path in configurable
  - (Android) Repo storage is configurable: external or internal
  - Basic methods that start, stop and restart the node
  - NewRequest method that takes a command and returns a RequestBuilder
- Provides a RequestBuilder Class:
  - Simple bindings to the go-ipfs RequestBuilder
  - Provides methods to set headers, options, arguments and body
  - Method `send` returns a byte array
  - (Android) Method `sendToJSONList` returns a JSON list
  - (iOS) Method `sendToDict` returns a dict

## Android/iOS Example Apps

- Starts a node and display its peerID
- Displays the number of connected peers
- Provides a `Random XKCD` button that download a random XKCD from IPFS
and displays it
