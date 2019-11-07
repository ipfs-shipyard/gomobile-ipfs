package ipfs.gomobile.android;

import android.content.Context;
import android.util.Base64;
import android.util.Log;

import java.io.File;

import mobile.Mobile;
import mobile.Config;
import mobile.Repo;
import mobile.Node;
import mobile.Shell;

public final class Bridge {
    static private final String TAG = "Bridge_IPFS_Mobile";
    // go node object
    static private Node node;

    // path for unix domain socket
    private String apiSockPath;

    // path to our ipfs repo
    private String repoPath;

    // go shell object
    private Shell shell;

    public Bridge(Context context) {
        String absPath = context.getFilesDir().getAbsolutePath();
        this.repoPath = absPath + "/ipfs/repo";
        this.apiSockPath = absPath + "/ipfs/api.sock";
    }

    public boolean start() {
        if (Bridge.node != null) {
            return true;
        }

        if (!Mobile.repoIsInitialized(this.repoPath)) {
            final File folder = new File(this.repoPath);
            if (!folder.exists()) {
                if (!folder.mkdirs()) {
                    Log.e(TAG, "unable to create repo folder");
                    return false;
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
                Log.e(TAG, err.toString());
                return false;
            }
        }

        try {
            Repo repo = Mobile.openRepo(this.repoPath);
            Bridge.node = Mobile.newNode(repo);
        } catch (Exception err) {
            Log.e(TAG, err.toString());
            return false;
        }

        return true;
    }


    private Shell getShell() throws Exception {
        if (this.shell == null) {
            this.shell = Mobile.newUDSShell(this.apiSockPath);
        }

        return this.shell;
    }

    public String fetchShell(String command, String b64Body) {
        try {
            byte[] req = new byte[0];

            if (b64Body.length() > 0) {
                req = Base64.decode(b64Body, Base64.DEFAULT);
            }

            // send the request
            byte[] res = this.getShell().request(command, req);

            String data = Base64.encodeToString(res, Base64.DEFAULT);
            return data;
        } catch (Exception err) {
            Log.e(TAG, err.toString());
            return null;
        }
    }
}
