package com.reactlibrary;

import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;
import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableMap;

import ipfs.gomobile.android.IPFS;

public class IpfsModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private final ArrayList<IPFS> instances = new ArrayList<IPFS>();

    public IpfsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "Ipfs";
    }

    private int register(IPFS instance) {
        this.instances.add(instance);
        return this.instances.indexOf(instance);
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public int construct(@NonNull String repoPath, boolean internalStorage) throws Exception {
        // react-native seems to not be able to figure out what constructor to call
        // so we only define this one and use default values in javascript
        return this.register(new IPFS(this.reactContext, repoPath, internalStorage));
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void start(int id) throws Exception {
        this.instances.get(id).start();
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public String command(int id, String cmdStr) throws Exception {
        return new String(this.instances.get(id).command(cmdStr));
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void stop(int id) throws Exception {
        this.instances.get(id).stop();
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void delete(int id) {
        this.instances.remove(id);
    }
}
