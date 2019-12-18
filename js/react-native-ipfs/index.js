import { NativeModules } from "react-native";

const { Ipfs: IpfsNative } = NativeModules;

export default class IPFS {
  instance = IpfsNative.construct();
  cleaned = false;

  assertAlive() {
    if (this.cleaned) throw new Error("leave cleaney alone!");
  }
  clean() {
    IpfsNative.delete(this.instance);
    this.cleaned = true;
  }

  // For all this we could use a Proxy but then we would loose the "const ipfs = new IPFS()" syntax
  start() {
    IpfsNative.start(this.instance);
  }
  command(cmdStr) {
    return JSON.parse(IpfsNative.command(this.instance, cmdStr));
  }
  stop() {
    IpfsNative.stop(this.instance);
  }
}
