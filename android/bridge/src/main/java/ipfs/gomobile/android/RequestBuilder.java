package ipfs.gomobile.android;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Scanner;

import androidx.annotation.NonNull;

public class RequestBuilder {

    private ipfs.RequestBuilder reqb;

    RequestBuilder(@NonNull ipfs.RequestBuilder reqb) {
        this.reqb = reqb;
    }

    public byte[] send() throws RequestBuilderException {
        try {
            return this.reqb.send();
        } catch (Exception err) {
            throw new RequestBuilderException("failed to send request", err);
        }
    }

    public ArrayList<JSONObject> sendToJSONList() throws RequestBuilderException, JSONException {
        String raw = new String(this.send());

        ArrayList<JSONObject> jsonList = new ArrayList<>();
        Scanner scanner = new Scanner(raw);
        while (scanner.hasNextLine()) {
            jsonList.add(new JSONObject(scanner.nextLine()));
        }

        return jsonList;
    }

    public void exec() throws RequestBuilderException {
        try {
            this.reqb.exec();
        } catch (Exception err) {
            throw new RequestBuilderException("failed to send request", err);
        }
    }

    // Arguments
    public RequestBuilder withArgument(String arg) {
        this.reqb.argument(arg);
        return this;
    }

    // Options
    public RequestBuilder withOption(String option, boolean val) {
        this.reqb.boolOptions(option, val);
        return this;
    }
    public RequestBuilder withOption(String option, String val) {
        this.reqb.stringOptions(option, val);
        return this;
    }
    public RequestBuilder withOption(String option, byte[] val) {
        this.reqb.byteOptions(option, val);
        return this;
    }

    // Body
    public RequestBuilder withBody(String body) {
        this.reqb.bodyString(body);
        return this;
    }
    public RequestBuilder withBody(byte[] body) {
        this.reqb.bodyBytes(body);
        return this;
    }

    // Headers
    public RequestBuilder withHeader(String key, String val) {
        this.reqb.header(key, val);
        return this;
    }

    public class RequestBuilderException extends Exception {
        RequestBuilderException(String message) { super(message); }
        RequestBuilderException(String message, Throwable err) { super(message, err); }
    }
}
