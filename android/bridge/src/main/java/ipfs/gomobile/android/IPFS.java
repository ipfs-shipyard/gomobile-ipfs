package ipfs.gomobile.android;

import android.content.Context;
import android.util.Base64;

import androidx.annotation.NonNull;

import java.io.File;

import mobile.Mobile;
import mobile.Config;
import mobile.Repo;
import mobile.Node;
import mobile.Shell;

public final class IPFS {
    // Default paths
    private static final String defaultRepoPath = "/ipfs/repo";
    private static final String apiSockFilename = "api.sock";

    // Absolute repo path
    private final String absRepoPath;

    // Go IPFS objects
    private Node node;
    private Shell shell;

    public IPFS(@NonNull Context context)
            throws ConfigCreationException, RepoInitException {
        this(context, defaultRepoPath);
    }

    public IPFS(@NonNull Context context, @NonNull String repoPath)
            throws ConfigCreationException, RepoInitException {
        absRepoPath = context.getFilesDir().getAbsolutePath() + repoPath;

        if (!Mobile.repoIsInitialized(absRepoPath)) {
            Config config;
            try {
                config = Mobile.newDefaultConfig();
                config.setupUnixSocketAPI(apiSockFilename);
            } catch (Exception e) {
                throw new ConfigCreationException("Config creation failed", e);
            }

            final File repoDir = new File(absRepoPath);
            if (!repoDir.exists()) {
                if (!repoDir.mkdirs()) {
                    throw new RepoInitException("Repo directory creation failed");
                }
            }
            try {
                Mobile.initRepo(absRepoPath, config);
            } catch (Exception e) {
                throw new RepoInitException("Repo initialization failed", e);
            }
        }
    }

    synchronized public String getRepoPath() {
        return absRepoPath;
    }

    synchronized public void start()
            throws NodeStartException, RepoOpenException, ShellInitException {
        if (node != null) {
            throw new NodeStartException("Node already started");
        }


        Repo repo;
        try {
            repo = Mobile.openRepo(absRepoPath);
        } catch (Exception e) {
            throw new RepoOpenException("Repo opening failed", e);
        }

        try {
            node = Mobile.newNode(repo);
        } catch (Exception e) {
            throw new NodeStartException("Node start failed", e);
        }

        try {
            shell = Mobile.newUDSShell(absRepoPath + "/" + apiSockFilename);
        } catch (Exception e) {
            throw new ShellInitException("Shell init failed", e);
        }
    }

    synchronized public void stop() throws NodeStopException {
        if (node == null) {
            throw new NodeStopException("Node not started yet");
        }

        try {
            node.close();
            node = null;
        } catch (Exception e) {
            throw new NodeStopException("Node stop failed", e);
        }
    }

    synchronized public void restart()
            throws NodeStartException, RepoOpenException, ShellInitException, NodeStopException {
        stop();
        start();
    }

    synchronized public String shellRequest(String command, String b64Body)
            throws ShellRequestException {
        if (node == null) {
            throw new ShellRequestException("Shell request failed: node isn't started");
        }

        try {
            byte[] req = new byte[0];

            if (b64Body.length() > 0) {
                req = Base64.decode(b64Body, Base64.DEFAULT);
            }

            byte[] res = shell.request(command, req);

            return Base64.encodeToString(res, Base64.DEFAULT);
        } catch (Exception err) {
            throw new ShellRequestException("Shell request failed", err);
        }
    }

    public class ConfigCreationException extends Exception {
        ConfigCreationException(String message, Throwable err) { super(message, err); }
    }

    public class NodeStartException extends Exception {
        NodeStartException(String message) { super(message); }
        NodeStartException(String message, Throwable err) { super(message, err); }
    }

    public class NodeStopException extends Exception {
        NodeStopException(String message) { super(message); }
        NodeStopException(String message, Throwable err) { super(message, err); }
    }

    public class ShellInitException extends Exception {
        ShellInitException(String message, Throwable err) { super(message, err); }
    }

    public class ShellRequestException extends Exception {
        ShellRequestException(String message) { super(message); }
        ShellRequestException(String message, Throwable err) { super(message, err); }
    }

    public class RepoInitException extends Exception {
        RepoInitException(String message) { super(message); }
        RepoInitException(String message, Throwable err) { super(message, err); }
    }

    public class RepoOpenException extends Exception {
        RepoOpenException(String message, Throwable err) { super(message, err); }
    }
}
