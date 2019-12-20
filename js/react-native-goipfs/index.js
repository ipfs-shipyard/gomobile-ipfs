import { NativeModules } from "react-native";
import base64 from "base-64";

const { Ipfs: IpfsNative } = NativeModules;

export default class IPFS {
  constructor(repoPath = "/ipfs/repo", internalStorage = true) {
    this.repoPath = repoPath;
    this.internalStorage = internalStorage;
    this.nativeHandle = null;
  }

  async start() {
    if (this._isDeleted())
      this.nativeHandle = await IpfsNative.construct(
        this.repoPath,
        this.internalStorage
      );
    this._assertAlive();
    await IpfsNative.start(this.nativeHandle);
  }

  async command(cmdStr, cmdBody = null) {
    this._assertAlive();
    const b64Body = cmdBody === null ? cmdBody : base64.encode(cmdBody);
    const b64Res = await IpfsNative.command(this.nativeHandle, cmdStr, b64Body);
    return b64Res === null ? b64Res : base64.decode(b64Res);
  }

  async stop() {
    this._assertAlive();
    await IpfsNative.stop(this.nativeHandle);
    await IpfsNative.delete(this.nativeHandle);
    this.nativeHandle = null;
  }

  _isDeleted() {
    return this.nativeHandle === null;
  }

  _assertAlive() {
    if (this._isDeleted())
      throw new Error(
        "Tried to call a function on a non-existent native IPFS instance"
      );
  }
}
