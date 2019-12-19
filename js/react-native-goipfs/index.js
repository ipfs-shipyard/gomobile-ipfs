import { NativeModules } from "react-native";

const { Ipfs: IpfsNative } = NativeModules;

export default class IPFS {
  constructor(repoPath = "/ipfs/repo", internalStorage = true) {
    this.cleaned = false;
    this.id = IpfsNative.construct(repoPath, internalStorage);
  }

  assertAlive() {
    if (this.cleaned) throw new Error("leave cleaney alone!");
  }

  start() {
    this.assertAlive();
    IpfsNative.start(this.id);
  }

  command(cmdStr) {
    this.assertAlive();
    return JSON.parse(IpfsNative.command(this.id, cmdStr));
  }

  stop() {
    this.assertAlive();
    IpfsNative.stop(this.id);
  }

  clean() {
    IpfsNative.delete(this.id);
    this.cleaned = true;
  }
}
