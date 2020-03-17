package ipfs.gomobile.android;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Scanner;


/**
 * RequestBuilder is an IPFS command request builder.
 */
public class RequestBuilder {

    private core.RequestBuilder reqb;

    /**
     * Package-Private class constructor using RequestBuilder passed by IPFS.newRequest method.
     * @param reqb
     */
    RequestBuilder(@NonNull core.RequestBuilder reqb) {
        this.reqb = reqb;
    }

    // Send methods
    /**
     * Sends the request to the underlying go-ipfs node.
     *
     * @return A byte array containing the response
     * @throws RequestBuilderException If sending the request failed
     */
    public byte[] send() throws RequestBuilderException {
        try {
            return this.reqb.send();
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
     */
    public ArrayList<JSONObject> sendToJSONList() throws RequestBuilderException, JSONException {
        String raw = new String(this.send());

        ArrayList<JSONObject> jsonList = new ArrayList<>();
        Scanner scanner = new Scanner(raw);
        while (scanner.hasNextLine()) {
            jsonList.add(new JSONObject(scanner.nextLine()));
        }

        return jsonList;
    }

    // Argument method
    /**
     * Adds an argument to the request.
     *
     * @param arg The argument to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withArgument(String arg) {
        this.reqb.argument(arg);
        return this;
    }

    // Option methods
    /**
     * Adds a boolean option to the request.
     *
     * @param option The name of the option to add
     * @param val The boolean value of the option to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withOption(String option, boolean val) {
        this.reqb.boolOptions(option, val);
        return this;
    }
    /**
     * Adds a string option to the request.
     *
     * @param option The name of the option to add
     * @param val The string value of the option to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withOption(String option, String val) {
        this.reqb.stringOptions(option, val);
        return this;
    }
    /**
     * Adds a byte array option to the request.
     *
     * @param option The name of the option to add
     * @param val The byte array value of the option to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withOption(String option, byte[] val) {
        this.reqb.byteOptions(option, val);
        return this;
    }

    // Body methods
    /**
     * Adds a string body to the request.
     *
     * @param body The string value of the body to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withBody(String body) {
        this.reqb.bodyString(body);
        return this;
    }
    /**
     * Adds a byte array body to the request.
     *
     * @param body The byte array value of the body to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withBody(byte[] body) {
        this.reqb.bodyBytes(body);
        return this;
    }

    // Header method
    /**
     * Adds a header to the request.
     *
     * @param key The key of the header to add
     * @param val The value of the header to add
     * @return This instance of RequestBuilder
     */
    public RequestBuilder withHeader(String key, String val) {
        this.reqb.header(key, val);
        return this;
    }

    public class RequestBuilderException extends Exception {
        RequestBuilderException(String message, Throwable err) { super(message, err); }
    }
}
