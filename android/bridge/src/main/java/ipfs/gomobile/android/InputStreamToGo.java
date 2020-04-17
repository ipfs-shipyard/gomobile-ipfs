package ipfs.gomobile.android;

import java.io.InputStream;

import ipfs.Reader;

final class InputStreamToGo implements Reader {
    private final InputStream inputStream;

    InputStreamToGo(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public long read(byte[] p) throws Exception {
        long r = inputStream.read(p);

        if (r == -1) {
            inputStream.close(); // Auto-close inputStream when EOF is reached
            throw new Exception("EOF");
        }

        return r;
    }
}
