package ipfs.gomobile.android;

import androidx.annotation.NonNull;
import android.os.Build;
import android.os.StatFs;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Objects;
import java.util.Scanner;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Scanner;

/**
* RequestBuilder is an IPFS command request builder.
*/
public class RequestBuilder {

    private final core.RequestBuilder requestBuilder;

    /**
    * Package-Private class constructor using RequestBuilder passed by IPFS.newRequest method.
    * @param requestBuilder A go-ipfs requestBuilder object
    */
    RequestBuilder(@NonNull core.RequestBuilder requestBuilder) {
        Objects.requireNonNull(requestBuilder, "requestBuilder should not be null");

        this.requestBuilder = requestBuilder;
    }

    // Send methods
    /**
    * Sends the request to the underlying go-ipfs node and returns an InputStream.
    *
    * @return An InputStream from which to read the response
    * @throws RequestBuilderException If sending the request failed
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public InputStream send() throws RequestBuilderException {
        try {
            InputStream inputStream = new InputStreamFromGo(requestBuilder.send());
            return inputStream;
        } catch (Exception err) {
            throw new RequestBuilderException("Failed to send request", err);
        }
    }
    /**
    * Sends the request to the underlying go-ipfs node and returns a byte array.
    *
    * @return A byte array containing the response
    * @throws RequestBuilderException If sending the request failed
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public byte[] sendToBytes() throws RequestBuilderException {
        try {
            return requestBuilder.sendToBytes();
        } catch (Exception err) {
            throw new RequestBuilderException("Failed to send request", err);
        }
    }
    /**
    * Sends the request to the underlying go-ipfs node and returns an array of JSONObject.
    *
    * @return An ArrayList of JSONObject generated from the response
    * @throws RequestBuilderException If sending the request failed
    * @throws JSONException If converting the response to JSONObject failed
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public ArrayList<JSONObject> sendToJSONList() throws RequestBuilderException, JSONException {
        String raw = new String(this.sendToBytes());

        ArrayList<JSONObject> jsonList = new ArrayList<>();
        Scanner scanner = new Scanner(raw);
        while (scanner.hasNextLine()) {
            jsonList.add(new JSONObject(scanner.nextLine()));
        }

        return jsonList;
    }
    /**
    * Sends the request to the underlying go-ipfs node and returns a file containing
    * the response.
    *
    * @param output The file in which to output the response
    * @return The file containing the response
    * @throws RequestBuilderException If sending the request failed
    * @throws SecurityException TODO
	* @throws IOException TODO
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public File sendToFile(@NonNull File output)
        throws RequestBuilderException, SecurityException, IOException {
        Objects.requireNonNull(argument, "output should not be null");

        if (!output.exists() && !output.createNewFile()) {
            throw new RequestBuilderException("Can't create file");
        }

        InputStream input = send();
        OutputStream outStream = new FileOutputStream(output);

        try {
            int blockSize;

            try {
                StatFs statfs = new StatFs(output.getPath());
                if (android.os.Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
                    blockSize = statfs.getBlockSize();
                } else {
                    blockSize = (int) statfs.getBlockSizeLong();
                }
            } catch (IllegalArgumentException e) {
                blockSize = 4096;
            }

            byte[] buffer = new byte[blockSize];
            int read;

            while ((read = input.read(buffer)) != -1) {
                outStream.write(buffer, 0, read);
            }

            outStream.flush();
            outStream.close();
            input.close();
        } catch (IOException e) {
            try { input.close(); } catch (IOException ignore) { /* nothing */ }
            try { outStream.close(); } catch (IOException ignore) { /* nothing */ }
            throw e;
        }

        return output;
    }

    // Argument method
    /**
    * Adds an argument to the request.
    *
    * @param argument The argument to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withArgument(@NonNull String argument) {
        Objects.requireNonNull(argument, "argument should not be null");

        requestBuilder.argument(argument);
        return this;
    }

    // Option methods
    /**
    * Adds a boolean option to the request.
    *
    * @param option The name of the option to add
    * @param value The boolean value of the option to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withOption(@NonNull String option, boolean value) {
        Objects.requireNonNull(option, "option should not be null");

        requestBuilder.boolOptions(option, value);
        return this;
    }
    /**
    * Adds a string option to the request.
    *
    * @param option The name of the option to add
    * @param value The string value of the option to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withOption(@NonNull String option, @NonNull String value) {
        Objects.requireNonNull(option, "option should not be null");
        Objects.requireNonNull(value, "value should not be null");

        requestBuilder.stringOptions(option, value);
        return this;
    }
    /**
    * Adds a byte array option to the request.
    *
    * @param option The name of the option to add
    * @param value The byte array value of the option to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withOption(@NonNull String option, @NonNull byte[] value) {
        Objects.requireNonNull(option, "option should not be null");
        Objects.requireNonNull(value, "value should not be null");

        requestBuilder.bytesOptions(option, value);
        return this;
    }

    // Body methods
    /**
    * Adds an InputStream body to the request.
    *
    * @param body The InputStream from which to read the body
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withBody(@NonNull InputStream body) {
        Objects.requireNonNull(body, "body should not be null");

        requestBuilder.body(new InputStreamToGo(body));
        return this;
    }
    /**
    * Adds a string body to the request.
    *
    * @param body The string value of the body to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withBody(@NonNull String body) {
        Objects.requireNonNull(body, "body should not be null");

        requestBuilder.bodyString(body);
        return this;
    }
    /**
    * Adds a byte array body to the request.
    *
    * @param body The byte array value of the body to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withBody(@NonNull byte[] body) {
        Objects.requireNonNull(body, "body should not be null");

        requestBuilder.bodyBytes(body);
        return this;
    }
    /**
     * Adds a file as a body to the request.
     *
     * @param body The file to add as a body
     * @return This instance of RequestBuilder
     * @throws FileNotFoundException If the file is inaccessible
     * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
     */
    public RequestBuilder withBody(@NonNull File body) throws FileNotFoundException {
        Objects.requireNonNull(body, "body should not be null");

        FileInputStream fis = new FileInputStream(body);
        requestBuilder.fileBody(body.getName(), new InputStreamToGo(fis));
        return this;
    }

    // Header method
    /**
    * Adds a header to the request.
    *
    * @param key The key of the header to add
    * @param value The value of the header to add
    * @return This instance of RequestBuilder
    * @see <a href="https://docs.ipfs.io/reference/api/http/">IPFS API Doc</a>
    */
    public RequestBuilder withHeader(@NonNull String key, @NonNull String value) {
        Objects.requireNonNull(key, "key should not be null");
        Objects.requireNonNull(value, "value should not be null");

        requestBuilder.header(key, value);
        return this;
    }

    public static class RequestBuilderException extends Exception {
        RequestBuilderException(String message, Throwable err) { super(message, err); }
    }
}
