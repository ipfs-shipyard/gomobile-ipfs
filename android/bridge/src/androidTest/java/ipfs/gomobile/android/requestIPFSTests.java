package ipfs.gomobile.android;

import android.content.Context;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import org.json.JSONObject;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.Timeout;
import org.junit.runner.RunWith;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;

import static org.junit.Assert.*;

/**
* Instrumented test, which will execute on an Android device.
*
* @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
*/
@RunWith(AndroidJUnit4.class)
public class requestIPFSTests {
    private IPFS ipfs;
    // This CID is the IPFS logo in the Wikipedia mirror. It should exist for a long time.
    private String fileUri = "/ipfs/bafkreifxaqwd63x4bhjj33sfm3pmny2codycx27jo77it33hkexzrawyma";
    private int expectedFileLength = 2940;
    private byte[] expectedFileSha256 = new byte[] {
        (byte)0xb7, (byte)0x04, (byte)0x2c, (byte)0x3f, (byte)0x6e, (byte)0xfc, (byte)0x09, (byte)0xd2,
        (byte)0x9d, (byte)0xee, (byte)0x45, (byte)0x66, (byte)0xde, (byte)0xc6, (byte)0xe3, (byte)0x42,
        (byte)0x70, (byte)0xf0, (byte)0x2b, (byte)0xeb, (byte)0xe9, (byte)0x77, (byte)0xfe, (byte)0x89,
        (byte)0xef, (byte)0x67, (byte)0x51, (byte)0x2f, (byte)0x98, (byte)0x82, (byte)0xd8, (byte)0x60        
    };
    // The boundary for a multipart message is a unique string. See https://en.wikipedia.org/wiki/MIME#Multipart_messages
    private static String boundary = "------------------------f33e457ed9f80969";
    private byte[] addRequestBody =
        ("--" + boundary + "\r\n" +
        "Content-Disposition: form-data; name=\"file\"\r\n" +
        "Content-Type: application/octet-stream\r\n\r\n" +
        "hello" +
        "\r\n--" + boundary + "--\r\n").getBytes();
    private String addRequestExpectedHash = "QmWfVY9y3xjsixTgbd9AorQxH7VtMpzfx2HaWtsoUYecaX";

    @Rule
    public Timeout globalTimeout = Timeout.seconds(600);

    @Before
    public void setup() throws Exception {
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        ipfs = new IPFS(appContext);
        ipfs.start();
    }

    @Test
    public void testDNSRequest() throws Exception {
        String domain = "website.ipfs.io";

        JSONObject resolveResp = ipfs.newRequest("resolve")
                .withArgument("/ipns/" + domain)
                .sendToJSONList()
                .get(0);
        JSONObject dnsResp = ipfs.newRequest("dns")
                .withArgument(domain)
                .sendToJSONList()
                .get(0);

        String resolvePath = resolveResp.getString("Path");
        String dnsPath = dnsResp.getString("Path");

        assertEquals(
            "resolve and dns request should return the same result",
            resolvePath,
            dnsPath
        );

        assertEquals(
            "response should start with \"/ipfs/\"",
            dnsPath.substring(0, 6),
            "/ipfs/"
        );
    }

    @Test
    public void testCatFile() throws Exception {
        byte[] response = ipfs.newRequest("cat")
                .withArgument(fileUri)
                .sendToBytes();

        assertEquals(
            "response should have the correct length",
            expectedFileLength,
            response.length
        );
        MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
        sha256.update(response);
        assertTrue(
            "response should have the correct SHA256",
            Arrays.equals(sha256.digest(), expectedFileSha256)
        );
    }

    @Test
    public void testCatFileStream() throws Exception {
        try (InputStream stream = ipfs.newRequest("cat")
                .withArgument(fileUri)
                .send()) {
            byte[] buffer = new byte[1000];
            int count = 0;
            MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
            int n;
            while ((n = stream.read(buffer)) != -1) {
                count += n;
                sha256.update(buffer, 0, n);
            }

            assertEquals(
                "streamed response should have the correct length",
                expectedFileLength,
                count
            );
            assertTrue(
                "response should have the correct SHA256",
                Arrays.equals(sha256.digest(), expectedFileSha256)
            );
        }
    }

    @Test
    public void testAddWithBytesBody() throws Exception {
        ArrayList<JSONObject> response = ipfs.newRequest("add")
            .withHeader("Content-Type",
                        "multipart/form-data; boundary=" + boundary)
            .withBody(addRequestBody)
            .sendToJSONList();

        assertEquals("Added file should have the correct CID",
                        addRequestExpectedHash,
                        response.get(0).getString("Hash"));
    }

    @Test
    public void testAddWithStreamBody() throws Exception {
        ArrayList<JSONObject> response = ipfs.newRequest("add")
            .withHeader("Content-Type",
                        "multipart/form-data; boundary=" + boundary)
            .withBody(new ByteArrayInputStream(addRequestBody))
            .sendToJSONList();

        assertEquals("Added file should have the correct CID",
            addRequestExpectedHash,
            response.get(0).getString("Hash"));
    }
}
