package ipfs.gomobile.android;

import android.content.Context;
import androidx.annotation.NonNull;

import java.io.File;

// Import gomobile-ipfs core
import core.Core;
import core.Config;
import core.Repo;
import core.Node;
import core.Shell;
import core.SockManager;

/**
 * IPFS is a class that wraps a go-ipfs node and its shell over UDS.
 */
public class IPFS {

    // Paths
    private static final String defaultRepoPath = "/ipfs/repo";
    private final String absRepoPath;
    private final String absSockPath;

    // Go objects
    private static SockManager sockmanager;
    private Node node;
    private Shell shell;

    /**
     * Class constructor using defaultRepoPath on internal storage.
     *
     * @param context The application context
     * @throws ConfigCreationException If the creation of the config failed
     * @throws RepoInitException If the initialization of the repo failed
     * @throws SockManagerException If the initialization of SockManager failed
     */
    public IPFS(@NonNull Context context)
        throws ConfigCreationException, RepoInitException, SockManagerException {
        this(context, defaultRepoPath, true);
    }

    /**
     * Class constructor using repoPath passed as parameter on internal storage.
     *
     * @param context The application context
     * @param repoPath The path of the go-ipfs repo
     * @throws ConfigCreationException If the creation of the config failed
     * @throws RepoInitException If the initialization of the repo failed
     * @throws SockManagerException If the initialization of SockManager failed
     */
    public IPFS(@NonNull Context context, @NonNull String repoPath)
        throws ConfigCreationException, RepoInitException, SockManagerException {
        this(context, repoPath, true);
    }

    /**
     * Class constructor using repoPath and storage location passed as parameters.
     *
     * @param context The application context
     * @param repoPath The path of the go-ipfs repo
     * @param internalStorage true, if the desired storage location for the repo path is internal
     *                        false, if the desired storage location for the repo path is external
     * @throws ConfigCreationException If the creation of the config failed
     * @throws RepoInitException If the initialization of the repo failed
     * @throws SockManagerException If the initialization of SockManager failed
     */
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
                    sockmanager = Core.newSockManager(context.getCacheDir().getAbsolutePath());
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

        if (!Core.repoIsInitialized(absRepoPath)) {
            Config config;
            try {
                config = Core.newDefaultConfig();
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
                Core.initRepo(absRepoPath, config);
            } catch (Exception e) {
                throw new RepoInitException("Repo initialization failed", e);
            }
        }
    }

    /**
     * Returns the repo path as a string.
     *
     * @return The repo path
     */
    synchronized public String getRepoPath() {
        return absRepoPath;
    }

    /**
     * Returns true if this IPFS instance is "started" by checking if the underlying go-ipfs node
     * is instantiated.
     *
     * @return true, if this IPFS instance is started
     */
    synchronized public boolean isStarted() {
        return node != null;
    }

    /**
     * Starts this IPFS instance.
     *
     * @throws NodeStartException If the node is already started or if its startup fails
     * @throws RepoOpenException If the opening of the repo failed
     */
    synchronized public void start()
        throws NodeStartException, RepoOpenException {
        if (isStarted()) {
            throw new NodeStartException("Node already started");
        }

        Repo repo;
        try {
            repo = Core.openRepo(absRepoPath);
        } catch (Exception e) {
            throw new RepoOpenException("Repo opening failed", e);
        }

        try {
            node = Core.newNode(repo);
            node.serveUnixSocketAPI(absSockPath);
        } catch (Exception e) {
            throw new NodeStartException("Node start failed", e);
        }

        shell = Core.newUDSShell(absSockPath);
    }

    /**
     * Stops this IPFS instance.
     *
     * @throws NodeStopException If the node is already stopped or if its stop fails
     */
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

    /**
     * Restarts this IPFS instance.
     *
     * @throws NodeStopException If the node is already stopped or if its stop fails
     * @throws RepoOpenException If the opening of the repo failed
     */
    synchronized public void restart()
        throws NodeStopException, RepoOpenException {
        stop();
        try { start(); } catch(NodeStartException ignore) { /* Should never happen */ }
    }

    /**
     * Creates and returns a RequestBuilder associated to this IPFS instance shell.
     *
     * @param command The command of the request
     * @return A RequestBuilder based on the command passed as parameter
     * @throws ShellRequestException If this IPFS instance is not started
     */
    public RequestBuilder newRequest(String command) throws ShellRequestException {
        if (!this.isStarted()) {
            throw new ShellRequestException("Shell request failed: node isn't started");
        }

        core.RequestBuilder reqb = this.shell.newRequest(command);
        return new RequestBuilder(reqb);
    }

    /**
     * Sets the primary and secondary DNS for gomobile (hacky, will be removed in future version)
     *
     * @param primary The primary DNS address in the form {@code <ip4>:<port>}
     * @param secondary The secondary DNS address in the form {@code <ip4>:<port>}
     */
    public static void setDNSPair(String primary, String secondary) {
        Core.setDNSPair(primary, secondary, false);
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

    public class RepoInitException extends Exception {
        RepoInitException(String message) { super(message); }
        RepoInitException(String message, Throwable err) { super(message, err); }
    }

    public class RepoOpenException extends Exception {
        RepoOpenException(String message, Throwable err) { super(message, err); }
    }

    public class ShellRequestException extends Exception {
        ShellRequestException(String message) { super(message); }
    }
}
