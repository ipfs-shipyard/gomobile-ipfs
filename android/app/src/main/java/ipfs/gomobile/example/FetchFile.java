package ipfs.gomobile.example;

import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.Random;

import ipfs.gomobile.android.IPFS;

final class FetchFile extends AsyncTask<Void, Void, String> {
    private static final String TAG = "FetchIPFSFile";

    private final WeakReference<MainActivity> activityRef;
    private boolean backgroundError;
    private byte[] fetchedData;
    private String cid;

    FetchFile(MainActivity activity, String cid) {
        activityRef = new WeakReference<>(activity);
        this.cid = cid;
    }

    @Override
    protected void onPreExecute() {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) return;

        activity.displayStatusProgress(activity.getString(R.string.titleImageFetching));
    }

    @Override
    protected String doInBackground(Void... v) {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) {
            cancel(true);
            return null;
        }

        IPFS ipfs = activity.getIpfs();

        try {
            fetchedData = ipfs.newRequest("cat")
                .withArgument(cid)
                .sendToBytes();

//            Log.d(TAG, "fetched file data=" + MainActivity.bytesToHex(fetchedData));
            return activity.getString(R.string.titleFetchedImage);
        } catch (Exception err) {
            backgroundError = true;
            return MainActivity.exceptionToString(err);
        }
    }

    protected void onPostExecute(String result) {
        MainActivity activity = activityRef.get();
        if (activity == null || activity.isFinishing()) return;

        if (backgroundError) {
            activity.displayStatusError(activity.getString(R.string.titleImageFetchingErr), result);
            Log.e(TAG, "Ipfs image fetch error: " + result);
        } else {
            activity.displayStatusSuccess();

            // Put directly data through this way because of size limit with Intend
            DisplayImageActivity.fetchedData = fetchedData;

            Intent intent = new Intent(activity, DisplayImageActivity.class);
            intent.putExtra("Title", result);
            activity.startActivity(intent);
        }
    }
}
