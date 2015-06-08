create or replace and compile java source named "SHA256Encoder" as
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;

/**
 * This is a class exclusively created for use in Oracle. This doesn't have any dependencies besides a JVM.
 * com.jReward.security.SHA256EncoderForOracle
 *
 * @author Suneel
 * @version $Revision: 1.1.2.4 $
 * @since Oct 25, 2010 12:05:23 PM
 */
public class SHA256Encoder {
    public static String getSHA256(String pwd) throws Exception {
        MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
        byte[] digest;

        try {
            digest = messageDigest.digest(pwd.getBytes("UTF-8"));
        } catch (Exception e) {
            throw new IllegalStateException("UTF-8 not supported!");
        }
			
        StringBuffer sb = new StringBuffer();

        for (int i =0; i < digest.length; i++) {
             sb.append( Integer.toString( ( digest[i] & 0xff ) + 0x100, 16 ).substring( 1 ) );
         }

        return sb.toString().toUpperCase();

    }
}
/
