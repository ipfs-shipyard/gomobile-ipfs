package ipfs.gomobile.example;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;

import androidx.appcompat.app.AppCompatActivity;

public class DisplayImageActivity extends AppCompatActivity {
    private static final String TAG = "DisplayImageActivity";

    public static byte[] fetchedData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_image);

        Intent intent = getIntent();

        try {
            String title = intent.getExtras().getString("Title");
            getSupportActionBar().setTitle(title);
        } catch (NullPointerException err) {
            Log.e(TAG, "Error: can't set title");
        }

        try {
            Bitmap bitmap = BitmapFactory.decodeByteArray(fetchedData, 0, fetchedData.length);

            ImageView imageView = findViewById(R.id.imageView);
            imageView.setImageBitmap(bitmap);
        } catch (Exception err) {
            Log.e(TAG, "Error: can't display image");
        }
    }
}
