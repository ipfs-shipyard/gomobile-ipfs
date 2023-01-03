package ipfs.gomobile.android;

import java.io.InputStream;
import java.util.Arrays;

final class InputStreamToGo implements core.NativeReader {
    private final InputStream inputStream;

    InputStreamToGo(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public byte[] nativeRead(long size) throws Exception {
        byte[] b = new byte[(int)size];
        while (true) {
            int n = inputStream.read(b);
            if (n == -1) {
                inputStream.close(); // Auto-close inputStream when EOF is reached
                // The Swift/Go interface converts this to nil.
                return new byte[0];
            }
            if (n > 0) {
                if (n == b.length)
                    return b;
                else
                    return Arrays.copyOf(b, n);
            }

            // Iterate to read more than zero bytes.
        }
    }
}
