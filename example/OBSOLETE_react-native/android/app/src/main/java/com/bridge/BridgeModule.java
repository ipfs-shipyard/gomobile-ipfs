package com.bridge;

import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.util.Base64;

import java.io.File;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;

import mobile.Mobile;
import mobile.Config;
import mobile.Repo;
import mobile.Node;
import mobile.Shell;

public class BridgeModule extends ReactContextBaseJavaModule {
    // go node object
    static private Node node = null;

    // path for unix domain socket
    private String apiSockPath;
    private String gatewaySockPath;

    // path to our ipfs repo
    private String repoPath;

    // go shell object
    private Shell shell = null;

    public BridgeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.repoPath = reactContext.getFilesDir().getAbsolutePath() + "/ipfs/repo";
        this.apiSockPath = reactContext.getFilesDir().getAbsolutePath() + "/ipfs/api.sock";
        this.gatewaySockPath = reactContext.getFilesDir().getAbsolutePath() + "/ipfs/gateway.sock";
    }

    @ReactMethod
    public void start(Promise promise) {
        if (BridgeModule.node != null) {
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

                // setup tcp api for webui.
                // this is not secure, and only use for the sake of this
                // example since its required by the webui
                // @FIXME: use a random port
                config.setupTCPAPI("45987");

                // setup unix socket api
                config.setupUnixSocketAPI(this.apiSockPath);

                Mobile.initRepo(this.repoPath, config);
            } catch (Exception err) {
                promise.reject(err);
                return;
            }
        }

        try {
            Repo repo = Mobile.openRepo(this.repoPath);
            BridgeModule.node = Mobile.newNode(repo);
            promise.resolve(true);
        } catch (Exception err) {
            promise.reject(err);
        }
    }


    private Shell getShell() throws Exception {
        if (this.shell == null) {
            this.shell = Mobile.newUDSShell(this.apiSockPath);
        }

        return this.shell;
    }

    @ReactMethod
    public void fetchShell(String command, String b64Body, Promise promise) {
        try {
            final Shell shell = this.getShell();
            byte[] req = new byte[0];

            if (b64Body.length() > 0) {
                req = Base64.decode(b64Body, Base64.DEFAULT);
            }

            // send the request
            byte[] res = shell.request(command, req);
            String data = Base64.encodeToString(res, Base64.DEFAULT);
            promise.resolve(data);
            return;
        } catch (Exception err) {
            promise.reject(err);
            return;
        }
    }

    public String getName() {
        return "BridgeModule";
    }
}

