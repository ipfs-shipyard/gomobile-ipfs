// CalendarManagerBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GoIpfs, NSObject)

RCT_EXTERN_METHOD(
  construct:        (NSString *)repoPath
  internalStorage:  (BOOL)internalStorage
  resolve:          (RCTPromiseResolveBlock)resolve
  reject:           (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
  start:            (NSString *)handle
  resolve:          (RCTPromiseResolveBlock)resolve
  reject:           (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
  command:          (NSString *)handle
  cmdStr:           (NSString *)cmdStr
  b64Body:          (NSString *)b64Body
  resolve:          (RCTPromiseResolveBlock)resolve
  reject:           (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
  stop:             (NSString *)handle
  resolve:          (RCTPromiseResolveBlock)resolve
  reject:           (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
  delete:            (NSString *)handle
  resolve:          (RCTPromiseResolveBlock)resolve
  reject:           (RCTPromiseRejectBlock)reject
)

@end
