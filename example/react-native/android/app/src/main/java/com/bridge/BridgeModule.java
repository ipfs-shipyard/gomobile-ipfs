package com.bridge;

import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

import java.io.File;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;

import mobile.Mobile;
import mobile.Config;
import mobile.Repo;
import mobile.Node;

public class BridgeModule extends ReactContextBaseJavaModule {
    // path to our ipfs repo
    private String repoPath;

    // go repo object
    private Repo repo = null;

    // go node object
    private Node node = null;

    public BridgeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.repoPath = reactContext.getFilesDir().getAbsolutePath() + "/ipfs/repo";
    }

    @ReactMethod
    public void getApiAddrs(Promise promise) {
        if (this.node != null) {
            promise.resolve(this.node.getApiAddrs());
        } else {
            promise.resolve("");
        }
    }

    @ReactMethod
    public void start(Promise promise) {
        if (this.node != null) {
            promise.resolve(true);
            return;
        }

        if (!Mobile.repoIsInitialized(this.repoPath)) {
            final File folder = new File(this.repoPath);
            if (!folder.exists()) {
                if (!folder.mkdirs()) {
                    promise.reject(new Exception("unable to create repo folder"));
                    return;
                }
            }

            try {
                Config config = Mobile.newDefaultConfig();
                Mobile.initRepo(this.repoPath, config);
            } catch (Exception err) {
                promise.reject(err);
                return;
            }
        }

        try {
            Repo repo = Mobile.openRepo(this.repoPath);
            this.node = Mobile.newNode(repo);
            promise.resolve(true);
        } catch (Exception err) {
            promise.reject(err);
        }
    }


    public String getName() {
        return "BridgeModule";
    }
}

