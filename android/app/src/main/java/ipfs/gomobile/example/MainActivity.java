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

import java.lang.ref.WeakReference;

import ipfs.gomobile.android.IPFS;

public class MainActivity extends AppCompatActivity {
    static private final String TAG = "IPFSMobileExample";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        new DisplayPeerIDTask(this).execute();
    }

    private static class DisplayPeerIDTask extends AsyncTask<Void, Void, String> {
        private WeakReference<MainActivity> activityRef;
        private boolean backgroundError;

        DisplayPeerIDTask(MainActivity activity) {
            activityRef = new WeakReference<>(activity);
        }

        @Override
        protected void onPreExecute() {}

        @Override
        protected String doInBackground(Void... v) {
            MainActivity activity = activityRef.get();
            if (activity == null || activity.isFinishing()) {
                cancel(true);
                return null;
            }

            try {
                IPFS ipfs = new IPFS(activity.getApplicationContext());
                ipfs.start();
                return ipfs.shellRequest("/id", "");
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
                    String peerID = reader.getString("ID");
                    displayMessage(peerID);
                } catch (Exception err) {
                    displayError(exceptionToString(err));
                }
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
            MainActivity activity = activityRef.get();
            if (activity == null || activity.isFinishing()) return;

            TextView title = activity.findViewById(R.id.textViewTitle);
            TextView result = activity.findViewById(R.id.textViewResult);

            title.setTextColor(Color.RED);
            title.setText(activity.getString(R.string.titleErr));
            result.setTextColor(Color.RED);

            displayMessage(error);
            Log.e(TAG, error);
        }

        private void displayMessage(String message) {
            MainActivity activity = activityRef.get();
            if (activity == null || activity.isFinishing()) return;

            TextView result = activity.findViewById(R.id.textViewResult);
            ProgressBar progress = activity.findViewById(R.id.progressBar);

            progress.setVisibility(View.INVISIBLE);
            result.setText(message);
        }
    }
}
