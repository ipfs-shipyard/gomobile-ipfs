package ipfs.gomobile.example;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import java.nio.charset.StandardCharsets;

import ipfs.gomobile.android.IPFS;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    private IPFS ipfs;

    private TextView ipfsTitle;
    private ProgressBar ipfsStartingProgress;
    private TextView ipfsResult;

    private TextView peerCounter;

    private TextView onlineTitle;
    private TextView offlineTitle;
    private Button xkcdButton;
    private Button shareButton;
    private Button fetchButton;
    private TextView ipfsStatus;
    private ProgressBar ipfsProgress;
    private TextView ipfsError;

    private PeerCounter peerCounterUpdater;

    void setIpfs(IPFS ipfs) {
        this.ipfs = ipfs;
    }

    IPFS getIpfs() {
        return ipfs;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ipfsTitle = findViewById(R.id.ipfsTitle);
        ipfsStartingProgress = findViewById(R.id.ipfsStartingProgress);
        ipfsResult = findViewById(R.id.ipfsResult);

        peerCounter = findViewById(R.id.peerCounter);

        onlineTitle = findViewById(R.id.onlineTitle);
        offlineTitle = findViewById(R.id.offlineTitle);
        xkcdButton = findViewById(R.id.xkcdButton);
        shareButton = findViewById(R.id.shareButton);
        fetchButton = findViewById(R.id.fetchButton);
        ipfsStatus = findViewById(R.id.ipfsStatus);
        ipfsProgress = findViewById(R.id.ipfsProgress);
        ipfsError = findViewById(R.id.ipfsError);

        if (ContextCompat.checkSelfPermission(
            getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED) {
            new StartIPFS(this).execute();
        } else if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
            Toast.makeText(this, R.string.ble_permissions_explain,
                Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 0);
        }

        final MainActivity activity = this;

        ActivityResultLauncher<String[]> selectFileResultLauncher = registerForActivityResult(
            new ActivityResultContracts.OpenDocument(),
            new ActivityResultCallback<Uri>() {
                @Override
                public void onActivityResult(Uri result) {
                    if (result != null) {
                        Log.d(TAG, String.format("onActivityResult: GetContent: Uri=%s", result.toString()));
                        new ShareFile(activity, result).execute();
                    }
                }
            });

        xkcdButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                new FetchRandomXKCD(activity).execute();
            }
        });

        shareButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectFileResultLauncher.launch(new String[] {"image/*"});
            }
        });

        fetchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                IntentIntegrator integrator = new IntentIntegrator(activity);
                integrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE);
                integrator.setPrompt("Scan a QR code");
                integrator.setOrientationLocked(false);
                integrator.setBarcodeImageEnabled(true);
                integrator.initiateScan();
                new IntentIntegrator(activity).initiateScan();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // QR Code scan result
        IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
        if(result != null) {
            if(result.getContents() == null) {
                Toast.makeText(this, "Cancelled", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this, "Scanned: " + result.getContents(), Toast.LENGTH_LONG).show();
                new FetchFile(this, result.getContents()).execute();
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] strPerm,
                                           @NonNull int [] grantResults) {
        super.onRequestPermissionsResult(requestCode, strPerm, grantResults);

        if (grantResults.length > 0
            && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            new StartIPFS(this).execute();
        } else {
            Toast.makeText(this, R.string.ble_permissions_denied,
                Toast.LENGTH_LONG).show();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (peerCounterUpdater != null) {
            peerCounterUpdater.stop();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (peerCounterUpdater != null) {
            peerCounterUpdater.start();
        }
    }

    void displayPeerIDError(String error) {
        ipfsTitle.setTextColor(Color.RED);
        ipfsResult.setTextColor(Color.RED);

        ipfsTitle.setText(getString(R.string.titlePeerIDErr));
        ipfsResult.setText(error);
        ipfsStartingProgress.setVisibility(View.INVISIBLE);
    }

    void displayPeerIDResult(String peerID) {
        ipfsTitle.setText(getString(R.string.titlePeerID));
        ipfsResult.setText(peerID);
        ipfsStartingProgress.setVisibility(View.INVISIBLE);

        updatePeerCount(0);
        peerCounter.setVisibility(View.VISIBLE);
        onlineTitle.setVisibility(View.VISIBLE);
        offlineTitle.setVisibility(View.VISIBLE);
        xkcdButton.setVisibility(View.VISIBLE);
        shareButton.setVisibility(View.VISIBLE);
        fetchButton.setVisibility(View.VISIBLE);

        peerCounterUpdater = new PeerCounter(this, 1000);
        peerCounterUpdater.start();
    }

    void updatePeerCount(int count) {
        peerCounter.setText(getString(R.string.titlePeerCon, count));
    }

    void displayStatusProgress(String text) {
        ipfsStatus.setTextColor(ipfsTitle.getCurrentTextColor());
        ipfsStatus.setText(text);
        ipfsStatus.setVisibility(View.VISIBLE);
        ipfsError.setVisibility(View.INVISIBLE);
        ipfsProgress.setVisibility(View.VISIBLE);

        xkcdButton.setAlpha(0.5f);
        xkcdButton.setClickable(false);
        shareButton.setAlpha(0.5f);
        shareButton.setClickable(false);
        fetchButton.setAlpha(0.5f);
        fetchButton.setClickable(false);
    }

    void displayStatusSuccess() {
        ipfsStatus.setVisibility(View.INVISIBLE);
        ipfsProgress.setVisibility(View.INVISIBLE);

        xkcdButton.setAlpha(1);
        xkcdButton.setClickable(true);
        shareButton.setAlpha(1);
        shareButton.setClickable(true);
        fetchButton.setAlpha(1);
        fetchButton.setClickable(true);
    }

    void displayStatusError(String title, String error) {
        ipfsStatus.setTextColor(Color.RED);
        ipfsStatus.setText(title);

        ipfsProgress.setVisibility(View.INVISIBLE);
        ipfsError.setVisibility(View.VISIBLE);
        ipfsError.setText(error);

        xkcdButton.setAlpha(1);
        xkcdButton.setClickable(true);
        shareButton.setAlpha(1);
        shareButton.setClickable(true);
        fetchButton.setAlpha(1);
        fetchButton.setClickable(true);
    }

    static String exceptionToString(Exception error) {
        String string = error.getMessage();

        if (error.getCause() != null) {
            string += ": " + error.getCause().getMessage();
        }

        return string;
    }

    public static String bytesToHex(byte[] bytes) {
        final byte[] HEX_ARRAY = "0123456789ABCDEF".getBytes(StandardCharsets.US_ASCII);
        byte[] hexChars = new byte[bytes.length * 2];
        for (int j = 0; j < bytes.length; j++) {
            int v = bytes[j] & 0xFF;
            hexChars[j * 2] = HEX_ARRAY[v >>> 4];
            hexChars[j * 2 + 1] = HEX_ARRAY[v & 0x0F];
        }
        return new String(hexChars, StandardCharsets.UTF_8);
    }
}
