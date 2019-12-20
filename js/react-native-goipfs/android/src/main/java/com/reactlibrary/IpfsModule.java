package com.reactlibrary;

import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;

import android.util.Log;
import android.util.Base64;
import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.Promise;

import ipfs.gomobile.android.IPFS;

public class IpfsModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private final Map<String, IPFS> instances = new HashMap<String, IPFS>();

    public IpfsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "Ipfs";
    }

    @ReactMethod()
    public void construct(@NonNull String repoPath, boolean internalStorage, Promise promise) {
        // react-native seems to not be able to figure out what constructor to call
        // so we only define this one and use default values in javascript
        try {
            promise.resolve(this.register(new IPFS(this.reactContext, repoPath, internalStorage)));
        } catch(Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod()
    public void start(String handle, Promise promise) {
        try {
            this.instances.get(handle).start();
            promise.resolve(null);
        } catch(Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod()
    public void command(String handle, @NonNull String cmdStr, String b64Body, Promise promise) {
        // same overloading problem that for construct()
        try {
            // sadly we can't directly pass byte arrays through the bridge so we have to use base64 strings
            byte[] cmdBody = b64Body == null ? null : Base64.decode(b64Body, Base64.DEFAULT);
            byte[] response = this.instances.get(handle).command(cmdStr, cmdBody);
            String b64Res = response == null ? null : Base64.encodeToString(response, Base64.DEFAULT);
            promise.resolve(b64Res);
        } catch(Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod()
    public void stop(String handle, Promise promise) {
        try {
            this.instances.get(handle).stop();
            promise.resolve(null);
        } catch(Exception e) {
            rejectWithException(promise, e);
        }
    }

    @ReactMethod()
    public void delete(String handle, Promise promise) {
        try {
            this.instances.remove(handle);
            promise.resolve(null);
        } catch(Exception e) {
            rejectWithException(promise, e);
        }
    }

    private String register(@NonNull IPFS instance) {
        String handle = UUID.randomUUID().toString().replaceAll("-", "").toUpperCase();
        this.instances.put(handle, instance);
        return handle;
    }

    private void rejectWithException(Promise promise, Exception e) {
        promise.reject(e.getClass().getCanonicalName(), e);
    }
}
