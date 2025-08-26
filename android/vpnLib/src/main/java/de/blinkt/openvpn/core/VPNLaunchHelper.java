/*
 * Copyright (c) 2012-2016 Arne Schwabe
 * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 */

package de.blinkt.openvpn.core;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Vector;

import de.blinkt.openvpn.R;
import de.blinkt.openvpn.VpnProfile;

public class VPNLaunchHelper {
    private static final String MININONPIEVPN = "nopie_openvpn";
    private static final String MINIPIEVPN = "pie_openvpn";
    private static final String OVPNCONFIGFILE = "android.conf";


    private static String writeMiniVPN(Context context) {
        VpnStatus.logError("🔧 VPNLaunchHelper.writeMiniVPN() called");
        String nativeAPI = NativeUtils.getNativeAPI();
        VpnStatus.logError("🔧 Native API: " + nativeAPI);
        VpnStatus.logError("🔧 Android SDK Version: " + Build.VERSION.SDK_INT);
        /* Prefer executing from the app's native library directory on all Android versions.
           Modern Android versions (Android 10+/Q and above) block exec from app-private dirs.
           Using libovpnexec.so from nativeLibraryDir avoids EACCES (permission denied).
        */
        File libovpnexec = new File(context.getApplicationInfo().nativeLibraryDir, "libovpnexec.so");
        VpnStatus.logError("🔧 Checking for libovpnexec.so at: " + libovpnexec.getAbsolutePath());
        VpnStatus.logError("🔧 libovpnexec.so exists: " + libovpnexec.exists());

        if (libovpnexec.exists()) {
            VpnStatus.logError("🔧 libovpnexec.so found! canRead=" + libovpnexec.canRead() + ", canExecute=" + libovpnexec.canExecute() + ", size=" + libovpnexec.length());
            VpnStatus.logError("🔧 Using libovpnexec.so from native library directory");
            return libovpnexec.getPath();
        }

        VpnStatus.logError("🔧 libovpnexec.so not found in native library directory; falling back to assets extraction to files directory");
        String[] abis;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            abis = getSupportedABIsLollipop();
        else
            //noinspection deprecation
            abis = new String[]{Build.CPU_ABI, Build.CPU_ABI2};

        if (!nativeAPI.equals(abis[0])) {
            VpnStatus.logWarning(R.string.abi_mismatch, Arrays.toString(abis), nativeAPI);
            abis = new String[]{nativeAPI};
        }

        for (String abi : abis) {

            // Use getFilesDir() instead of getCacheDir() for better permissions on Android 10+
            File vpnExecutable = new File(context.getFilesDir(), "c_" + getMiniVPNExecutableName() + "." + abi);
            VpnStatus.logError("🔧 Checking binary: " + vpnExecutable.getAbsolutePath());
            VpnStatus.logError("🔧 Binary exists: " + vpnExecutable.exists());
            VpnStatus.logError("🔧 Binary canExecute: " + vpnExecutable.canExecute());
            if ((vpnExecutable.exists() && vpnExecutable.canExecute()) || writeMiniVPNBinary(context, abi, vpnExecutable)) {
                VpnStatus.logError("🔧 Using binary path: " + vpnExecutable.getPath());
                return vpnExecutable.getPath();
            }
        }

        throw new RuntimeException("Cannot find any execulte for this device's ABIs " + abis.toString());
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String[] getSupportedABIsLollipop() {
        return Build.SUPPORTED_ABIS;
    }

    private static String getMiniVPNExecutableName() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
            return MINIPIEVPN;
        else
            return MININONPIEVPN;
    }


    public static String[] replacePieWithNoPie(String[] mArgv) {
        mArgv[0] = mArgv[0].replace(MINIPIEVPN, MININONPIEVPN);
        return mArgv;
    }


    static String[] buildOpenvpnArgv(Context c) {
        VpnStatus.logError("🔧 buildOpenvpnArgv() called");
        Vector<String> args = new Vector<>();

        String binaryName = writeMiniVPN(c);
        VpnStatus.logError("🔧 writeMiniVPN() returned: " + binaryName);
        // Add fixed paramenters
        //args.add("/data/data/de.blinkt.openvpn/lib/openvpn");
        if (binaryName == null) {
            VpnStatus.logError("Error writing minivpn binary");
            return null;
        }

        args.add(binaryName);

        args.add("--config");
        args.add(getConfigFilePath(c));

        return args.toArray(new String[args.size()]);
    }

    private static boolean writeMiniVPNBinary(Context context, String abi, File mvpnout) {
        try {
            InputStream mvpn;

            try {
                mvpn = context.getAssets().open(getMiniVPNExecutableName() + "." + abi);
            } catch (IOException errabi) {
                VpnStatus.logInfo("Failed getting assets for archicture " + abi);
                return false;
            }


            FileOutputStream fout = new FileOutputStream(mvpnout);

            byte buf[] = new byte[4096];

            int lenread = mvpn.read(buf);
            while (lenread > 0) {
                fout.write(buf, 0, lenread);
                lenread = mvpn.read(buf);
            }
            fout.close();

            // Set multiple permission bits for better compatibility
            if (!mvpnout.setExecutable(true, false)) {
                VpnStatus.logError("Failed to make OpenVPN executable");
                return false;
            }
            
            // Also try to set read permissions explicitly
            if (!mvpnout.setReadable(true, false)) {
                VpnStatus.logError("Failed to make OpenVPN readable");
            }

            // Final verification
            VpnStatus.logInfo("OpenVPN binary written to: " + mvpnout.getAbsolutePath());
            VpnStatus.logInfo("Binary executable: " + mvpnout.canExecute());
            VpnStatus.logInfo("Binary readable: " + mvpnout.canRead());
            VpnStatus.logInfo("Binary size: " + mvpnout.length());

            return true;
        } catch (IOException e) {
            VpnStatus.logException(e);
            return false;
        }

    }

    private static boolean createLibovpnexecFromAssets(Context context, String abi) {
        try {
            File nativeLibDir = new File(context.getApplicationInfo().nativeLibraryDir);
            File libovpnexec = new File(nativeLibDir, "libovpnexec.so");
            
            // Check if we can write to the native lib directory
            if (!nativeLibDir.canWrite()) {
                VpnStatus.logError("Cannot write to native library directory: " + nativeLibDir.getAbsolutePath());
                return false;
            }
            
            InputStream assetStream = context.getAssets().open(getMiniVPNExecutableName() + "." + abi);
            FileOutputStream fout = new FileOutputStream(libovpnexec);
            
            byte buf[] = new byte[4096];
            int lenread = assetStream.read(buf);
            while (lenread > 0) {
                fout.write(buf, 0, lenread);
                lenread = assetStream.read(buf);
            }
            fout.close();
            assetStream.close();
            
            // Set executable permissions
            if (!libovpnexec.setExecutable(true, false)) {
                VpnStatus.logError("Failed to make libovpnexec.so executable");
                return false;
            }
            
            VpnStatus.logInfo("Successfully created libovpnexec.so in native library directory");
            return true;
            
        } catch (Exception e) {
            VpnStatus.logError("Error creating libovpnexec.so: " + e.getMessage());
            return false;
        }
    }


    public static void startOpenVpn(VpnProfile startprofile, Context context) {
        Intent startVPN = startprofile.prepareStartService(context);
        if (startVPN != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                //noinspection NewApi
                context.startForegroundService(startVPN);
            else
                context.startService(startVPN);

        }
    }


    public static String getConfigFilePath(Context context) {
        return context.getCacheDir().getAbsolutePath() + "/" + OVPNCONFIGFILE;
    }

}
