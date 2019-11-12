package ipfs.gomobile.example;

import androidx.appcompat.app.AppCompatActivity;

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
    static private final String TAG = "IPFS_Mobile_Example";
    private IPFS bridge;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        bridge = new IPFS(getApplicationContext());

        new AsyncTask<Void, Void, String>() {
            @Override
            protected void onPreExecute() {}

            @Override
            protected String doInBackground(Void... v) {
                if (bridge.start()) {
                    return bridge.fetchShell("/id", "");
                }

                return null;
            }

            protected void onPostExecute(String result) {
                TextView text = findViewById(R.id.textView2);
                ProgressBar progress = findViewById(R.id.progressBar);
                String value;

                if (result != null) {
                    byte[] decodedBytes = Base64.decode(result, Base64.DEFAULT);
                    try {
                        JSONObject reader = new JSONObject(new String(decodedBytes));
                        value = reader.getString("ID");
                    } catch (Exception err) {
                        Log.e(TAG, err.toString());
                        value = "error: can't parse JSON response";
                    }
                } else {
                    value = "error: can't fetch on shell";
                }


                progress.setVisibility(View.INVISIBLE);
                text.setText(value);
            }
        }.execute();
    }
}
