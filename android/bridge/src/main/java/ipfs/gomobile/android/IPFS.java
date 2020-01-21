package ipfs.gomobile.android;

import android.content.Context;

import androidx.annotation.NonNull;

import java.io.File;

import ipfs.Ipfs;
import ipfs.Config;
import ipfs.Repo;
import ipfs.Node;
import ipfs.Shell;
import ipfs.SockManager;

public final class IPFS {
    // Paths
    private static final String defaultRepoPath = "/ipfs/repo";
    private final String absRepoPath;
    private final String absSockPath;

    // Go IPFS objects
    private static SockManager sockmanager;
    private Node node;
    private Shell shell;

    public IPFS(@NonNull Context context)
        throws ConfigCreationException, RepoInitException, SockManagerException {
        this(context, defaultRepoPath, true);
    }

    public IPFS(@NonNull Context context, @NonNull String repoPath)
        throws ConfigCreationException, RepoInitException, SockManagerException {
        this(context, repoPath, true);
    }

    public IPFS(@NonNull Context context, @NonNull String repoPath, boolean internalStorage)
        throws ConfigCreationException, RepoInitException, SockManagerException {
        if (internalStorage) {
            absRepoPath = context.getFilesDir().getAbsolutePath() + repoPath;
        } else {
            File externalDir = context.getExternalFilesDir(null);

            if (externalDir == null) {
                throw new RepoInitException("No external storage available");
            }
            absRepoPath = externalDir.getAbsolutePath() + repoPath;
        }

        synchronized (IPFS.class) {
            if (sockmanager == null) {
                try {
                    sockmanager = Ipfs.newSockManager(context.getCacheDir().getAbsolutePath());
                } catch (Exception e) {
                    throw new SockManagerException("Socket manager initialization failed", e);
                }
            }
        }

        try {
            absSockPath = sockmanager.newSockPath();
        } catch (Exception e) {
            throw new SockManagerException("API socket creation failed", e);
        }

        if (!Ipfs.repoIsInitialized(absRepoPath)) {
            Config config;
            try {
                config = Ipfs.newDefaultConfig();
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
                Ipfs.initRepo(absRepoPath, config);
            } catch (Exception e) {
                throw new RepoInitException("Repo initialization failed", e);
            }
        }
    }

    synchronized public String getRepoPath() {
        return absRepoPath;
    }

    synchronized public boolean isStarted() {
        return node != null;
    }

    synchronized public void start()
        throws NodeStartException, RepoOpenException {
        if (isStarted()) {
            throw new NodeStartException("Node already started");
        }

        Repo repo;
        try {
            repo = Ipfs.openRepo(absRepoPath);
        } catch (Exception e) {
            throw new RepoOpenException("Repo opening failed", e);
        }

        try {
            node = Ipfs.newNode(repo);
            node.serveUnixSocketAPI(absSockPath);
        } catch (Exception e) {
            throw new NodeStartException("Node start failed", e);
        }

        shell = Ipfs.newUDSShell(absSockPath);
    }

    synchronized public void stop() throws NodeStopException {
        if (!isStarted()) {
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
        throws NodeStartException, RepoOpenException, NodeStopException {
        stop();
        start();
    }

    public RequestBuilder newRequest(String command) throws ShellRequestException {
        if (!this.isStarted()) {
            throw new ShellRequestException("Shell request failed: node isn't started");
        }

        ipfs.RequestBuilder reqb = this.shell.newRequest(command);
        return new RequestBuilder(reqb);
    }

    public static void setDNSPair(String primary, String secondary, Boolean loadFromSystem) {
        Ipfs.setDNSPair(primary, secondary, loadFromSystem);
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

    public class SockManagerException extends Exception {
        SockManagerException(String message, Throwable err) { super(message, err); }
    }

    public class ShellRequestException extends Exception {
        ShellRequestException(String message) { super(message); }
    }

    public class RepoInitException extends Exception {
        RepoInitException(String message) { super(message); }
        RepoInitException(String message, Throwable err) { super(message, err); }
    }

    public class RepoOpenException extends Exception {
        RepoOpenException(String message, Throwable err) { super(message, err); }
    }
}
