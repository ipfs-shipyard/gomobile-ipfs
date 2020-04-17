package ipfs.gomobile.android;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.io.InputStream;

import ipfs.ReadCloser;

final class InputStreamFromGo extends InputStream {
    private final ReadCloser readCloser;
    private boolean closed;

    InputStreamFromGo(ReadCloser readCloser) {
        this.readCloser = readCloser;
    }

    @Override
    public void close() throws IOException {
        if (closed) {
            throw new IOException("InputStream already closed");
        }

        closed = true;

        try {
            readCloser.close();
        } catch (Exception e) {
            throw new IOException(e.getMessage());
        }
    }

    @Override
    public int read() throws IOException {
        byte[] b = new byte[1];

        try {
            readCloser.read(b);
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().equals("EOF")) {
                return -1;
            }
            throw new IOException(e.getMessage());
        }

        return b[0];
    }

    @Override
    public int read(@NonNull byte[] b, int off, int len)
        throws IOException, IndexOutOfBoundsException {
        if (off < 0 || len < 0 || len > b.length - off) {
            throw new IndexOutOfBoundsException();
        }

        try {
            if (b.length == len) {
                return (int)readCloser.read(b);
            }

            byte[] tmp = new byte[len];
            int read;

            read = (int)readCloser.read(tmp);
            System.arraycopy(tmp, 0, b, off, read);

            return read;
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().equals("EOF")) {
                return -1;
            }
            throw new IOException(e.getMessage());
        }
    }
}
