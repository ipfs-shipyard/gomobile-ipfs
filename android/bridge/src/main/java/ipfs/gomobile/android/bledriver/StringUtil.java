package ipfs.gomobile.android.bledriver;

import java.util.Locale;

public class StringUtil {
    /**
    * Return the result of String.format, using Locale.US . This is needed for
    * formats such as "%d" which has locale-specific interpretation.
    */
    public static String format(String format, Object... args) {
        return String.format(Locale.US, format, args);
    }
}
