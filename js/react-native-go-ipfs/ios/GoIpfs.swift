import GomobileIPFS

@objc(GoIpfs)
public class GoIpfs: NSObject {
  var instances = Dictionary<String, IPFS>();

  private func rejectWithError(
    e:  NSError,
    r:  RCTPromiseRejectBlock
  ) -> Void {
    r(
      "\(String(describing: e.code))",
      e.userInfo.description,
      e
    );
  }

  @objc(construct:internalStorage:resolve:reject:)
  public func construct(
    repoPath:         String,
    internalStorage:  Bool,
    resolve:          RCTPromiseResolveBlock,
    reject:           RCTPromiseRejectBlock
  ) -> Void {
    let handle = UUID().uuidString
    do {
      instances[handle] = try IPFS(repoPath);
      resolve(handle);
    } catch let error as NSError {
      rejectWithError(e: error, r: reject);
    }
  }

  @objc(start:resolve:reject:)
  public func start(
    handle:           String,
    resolve:          RCTPromiseResolveBlock,
    reject:           RCTPromiseRejectBlock
  ) -> Void {
    do {
      try instances[handle]?.start();
      resolve(nil);
    } catch let error as NSError {
      rejectWithError(e: error, r: reject);
    }
  }

  @objc(command:cmdStr:b64Body:resolve:reject:)
  public func command(
    handle:   String,
    cmdStr:   String,
    b64Body:  String,
    resolve:  RCTPromiseResolveBlock,
    reject:   RCTPromiseRejectBlock
  ) -> Void {
    do {
      var body: Data? = nil
      if b64Body.count > 0 {
        body = Data(base64Encoded: b64Body, options: .ignoreUnknownCharacters)
      }
      let res = try instances[handle]?.command(cmdStr, body: body);
      resolve(res == nil ? res : res?.base64EncodedString());
    } catch let error as NSError {
      rejectWithError(e: error, r: reject);
    }
  }

  @objc(stop:resolve:reject:)
  public func stop(
    handle:           String,
    resolve:          RCTPromiseResolveBlock,
    reject:           RCTPromiseRejectBlock
  ) -> Void {
    do {
      try instances[handle]?.stop();
      resolve(nil);
    } catch let error as NSError {
      rejectWithError(e: error, r: reject);
    }
  }

  @objc(delete:resolve:reject:)
  public func delete(
    handle:           String,
    resolve:          RCTPromiseResolveBlock,
    reject:           RCTPromiseRejectBlock
  ) -> Void {
    instances[handle] = nil
    resolve(nil);
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
}
