package com.reactlibrary;

import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import android.util.Log;

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

    @ReactMethod(isBlockingSynchronousMethod = true)
    public WritableMap construct() throws Exception {
        IPFS nativeIpfs = new IPFS(this.reactContext);
        this.instances.add(nativeIpfs);

        final WritableMap ipfs = new WritableNativeMap();
        ipfs.putInt("id", this.instances.indexOf(nativeIpfs));

        return ipfs;
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void start(ReadableMap ipfs) throws Exception {
        this.instances.get(ipfs.getInt("id")).start();
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public String command(ReadableMap ipfs, String cmdStr) throws Exception {
        return new String(this.instances.get(ipfs.getInt("id")).command(cmdStr));
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void stop(ReadableMap ipfs) throws Exception {
        this.instances.get(ipfs.getInt("id")).stop();
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public void delete(ReadableMap ipfs) {
        this.instances.remove(ipfs.getInt("id"));
    }

    @ReactMethod
    public void sampleMethod(String stringArgument, int numberArgument, Callback callback) {
        try {
          IPFS ipfs = new IPFS(this.reactContext);
          ipfs.start();
          ipfs.command("/id");
          ipfs.stop();
        }
        catch(Exception e) {
          callback.invoke("Exception: " + e);
          return;
        }
        // TODO: Implement some actually useful functionality
        callback.invoke("Received numberArgument: " + numberArgument + " stringArgument: " + stringArgument);
    }
}
