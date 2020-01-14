package ipfs.gomobile.example;

import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.Random;

import ipfs.gomobile.android.IPFS;

final class FetchRandomXKCD extends AsyncTask<Void, Void, String> {
    private static final String TAG = "FetchRandomXKCD";

    private static Random random = new Random();
    private static JSONArray XKCDList;

    private final WeakReference<MainActivity> activityRef;
    private boolean backgroundError;
    private byte[] fetchedData;

    FetchRandomXKCD(MainActivity activity) {
        activityRef = new WeakReference<>(activity);
    }

    @Override
    protected void onPreExecute() {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) return;

        activity.displayFetchProgress();
    }

    @Override
    protected String doInBackground(Void... v) {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) {
            cancel(true);
            return null;
        }

        if (XKCDList == null) {
            InputStream raw = activity.getResources().openRawResource(R.raw.xkcd);
            try {
                byte[] b = new byte[raw.available()];
                if (raw.available() != raw.read(b)) {
                    backgroundError = true;
                    return "Error: reading XKCD list raw file failed";
                }

                JSONObject json = new JSONObject(new String(b));
                XKCDList = json.getJSONArray("xkcd-list");
            } catch (Exception err) {
                backgroundError = true;
                return MainActivity.exceptionToString(err);
            }
        }

        try {
            IPFS ipfs = activity.getIpfs();
            int randomIndex = random.nextInt(XKCDList.length());
            JSONObject randomEntry = XKCDList.getJSONObject(randomIndex);

            String cid = randomEntry.getString("cid");
            String title = randomEntry.getInt("ep") + ". " + randomEntry.getString("name");

            fetchedData = ipfs.newRequest("cat")
                .withArgument(cid)
                .send();

            return title;
        } catch (Exception err) {
            backgroundError = true;
            return MainActivity.exceptionToString(err);
        }
    }

    protected void onPostExecute(String result) {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) return;

        if (backgroundError) {
            activity.displayFetchError(result);
            Log.e(TAG, "XKCD fetch error: " + result);
        } else {
            activity.displayFetchSuccess();

            Intent intent = new Intent(activity, DisplayImageActivity.class);
            intent.putExtra("ImageData", fetchedData);
            intent.putExtra("Title", result);
            activity.startActivity(intent);
        }
    }
}
