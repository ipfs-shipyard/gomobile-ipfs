package ipfs.gomobile.example;

import androidx.appcompat.app.AppCompatActivity;

import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import android.util.Base64;

import org.json.JSONObject;

import ipfs.gomobile.android.IPFS;

public class MainActivity extends AppCompatActivity {
    static private final String TAG = "IPFSMobileExample";
    private IPFS bridge;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        try {
            bridge = new IPFS(getApplicationContext());
        } catch (Exception err) {
            displayError(exceptionToString(err));
        } finally {
            new AsyncTask<Void, Void, String>() {
                private boolean backgroundError;

                @Override
                protected void onPreExecute() {}

                @Override
                protected String doInBackground(Void... v) {
                    try {
                        bridge.start();
                        return bridge.shellRequest("/id", "");
                    } catch (Exception err) {
                        backgroundError = true;
                        return exceptionToString(err);
                    }
                }

                protected void onPostExecute(String result) {
                    if (backgroundError) {
                        displayError(result);
                    } else {
                        byte[] decodedBytes = Base64.decode(result, Base64.DEFAULT);
                        try {
                            JSONObject reader = new JSONObject(new String(decodedBytes));
                            displayMessage(reader.getString("ID"));
                        } catch (Exception err) {
                            displayError(exceptionToString(err));
                        }
                    }
                }
            }.execute();
        }
    }

    private String exceptionToString(Exception error) {
        String string = error.getMessage();

        if (error.getCause() != null) {
            string += ": " + error.getCause().getMessage();
        }

        return string;
    }

    private void displayError(String error) {
        TextView title = findViewById(R.id.textViewTitle);
        TextView result = findViewById(R.id.textViewResult);

        title.setTextColor(Color.RED);
        title.setText(getString(R.string.titleErr));
        result.setTextColor(Color.RED);

        displayMessage(error);
        Log.e(TAG, error);
    }

    private void displayMessage(String message) {
        TextView result = findViewById(R.id.textViewResult);
        ProgressBar progress = findViewById(R.id.progressBar);

        progress.setVisibility(View.INVISIBLE);
        result.setText(message);
    }
}
