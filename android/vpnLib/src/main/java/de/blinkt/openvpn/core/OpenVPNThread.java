/*
 * Copyright (c) 2012-2016 Arne Schwabe
 * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 */

package de.blinkt.openvpn.core;

import android.annotation.SuppressLint;
import android.util.Log;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.blinkt.openvpn.R;

public class OpenVPNThread implements Runnable {
    private static final String DUMP_PATH_STRING = "Dump path: ";
    @SuppressLint("SdCardPath")
    private static final String BROKEN_PIE_SUPPORT = "/data/data/de.blinkt.openvpn/cache/pievpn";
    private final static String BROKEN_PIE_SUPPORT2 = "syntax error";
    private static final String TAG = "OpenVPN";
    // 1380308330.240114 18000002 Send to HTTP proxy: 'X-Online-Host: bla.blabla.com'
    private static final Pattern LOG_PATTERN = Pattern.compile("(\\d+).(\\d+) ([0-9a-f])+ (.*)");
    public static final int M_FATAL = (1 << 4);
    public static final int M_NONFATAL = (1 << 5);
    public static final int M_WARN = (1 << 6);
    public static final int M_DEBUG = (1 << 7);
    private String[] mArgv;
    private static Process mProcess;
    private String mNativeDir;
    private String mTmpDir;
    private static OpenVPNService mService;
    private String mDumpPath;
    private boolean mBrokenPie = false;
    private boolean mNoProcessExitStatus = false;

    public OpenVPNThread(OpenVPNService service, String[] argv, String nativelibdir, String tmpdir) {
        mArgv = argv;
        mNativeDir = nativelibdir;
        mTmpDir = tmpdir;
        mService = service;
    }

    public OpenVPNThread() {
    }

    public void stopProcess() {
        if (mProcess != null) {
            try {
                mProcess.destroy();
            } catch (Exception e) {
                Log.e(TAG, "Error stopping process: " + e.getMessage());
            }
        }
    }

    void setReplaceConnection()
    {
        mNoProcessExitStatus=true;
    }

    @Override
    public void run() {
        try {
            Log.i(TAG, "Starting openvpn");
            Log.d(TAG, "OpenVPN arguments: " + java.util.Arrays.toString(mArgv));
            Log.d(TAG, "Native library directory: " + mNativeDir);
            Log.d(TAG, "Temp directory: " + mTmpDir);
            startOpenVPNThreadArgs(mArgv);
            Log.i(TAG, "OpenVPN process exited");
        } catch (Exception e) {
            VpnStatus.logException("Starting OpenVPN Thread", e);
            Log.e(TAG, "OpenVPNThread Got " + e.toString());
        } finally {
            int exitvalue = 0;
            try {
                if (mProcess != null) {
                    exitvalue = mProcess.waitFor();
                    Log.d(TAG, "OpenVPN process exit code: " + exitvalue);
                }
            } catch (IllegalThreadStateException ite) {
                VpnStatus.logError("Illegal Thread state: " + ite.getLocalizedMessage());
                Log.e(TAG, "Illegal Thread state: " + ite.getLocalizedMessage());
            } catch (InterruptedException ie) {
                VpnStatus.logError("InterruptedException: " + ie.getLocalizedMessage());
                Log.e(TAG, "InterruptedException: " + ie.getLocalizedMessage());
            }
            if (exitvalue != 0) {
                VpnStatus.logError("Process exited with exit value " + exitvalue);
                Log.e(TAG, "Process exited with exit value " + exitvalue);
                if (mBrokenPie) {
                    /* This will probably fail since the NoPIE binary is probably not written */
                    String[] noPieArgv = VPNLaunchHelper.replacePieWithNoPie(mArgv);

                    // We are already noPIE, nothing to gain
                    if (!noPieArgv.equals(mArgv)) {
                        mArgv = noPieArgv;
                        VpnStatus.logInfo("PIE Version could not be executed. Trying no PIE version");
                        run();
                    }

                }

            }

            if (!mNoProcessExitStatus)
                VpnStatus.updateStateString("NOPROCESS", "No process running.", R.string.state_noprocess, ConnectionStatus.LEVEL_NOTCONNECTED);

            if (mDumpPath != null) {
                try {
                    BufferedWriter logout = new BufferedWriter(new FileWriter(mDumpPath + ".log"));
                    SimpleDateFormat timeformat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.GERMAN);
                    for (LogItem li : VpnStatus.getlogbuffer()) {
                        String time = timeformat.format(new Date(li.getLogtime()));
                        logout.write(time + " " + li.getString(mService) + "\n");
                    }
                    logout.close();
                    VpnStatus.logError(R.string.minidump_generated);
                } catch (IOException e) {
                    VpnStatus.logError("Writing minidump log: " + e.getLocalizedMessage());
                }
            }

            if (!mNoProcessExitStatus)
                mService.openvpnStopped();
            Log.i(TAG, "Exiting");
        }
    }

    public static boolean stop(){
        if (mService != null) {
            mService.openvpnStopped();
        }
        if (mProcess != null) {
            try {
                mProcess.destroy();
            } catch (Exception e) {
                Log.e(TAG, "Error stopping process: " + e.getMessage());
            }
        }
        return true;
    }

    private void startOpenVPNThreadArgs(String[] argv) {
        LinkedList<String> argvlist = new LinkedList<String>();

        Collections.addAll(argvlist, argv);

        Log.d(TAG, "OpenVPN command line: " + argvlist.toString());

        ProcessBuilder pb = new ProcessBuilder(argvlist);
        // Ensure we always execute from native lib dir if helper exists
        try {
            String helperPath = mNativeDir + "/libovpnexec.so";
            java.io.File helper = new java.io.File(helperPath);
            if (helper.exists() && !argvlist.get(0).equals(helperPath)) {
                Log.d(TAG, "Switching executable to native helper: " + helperPath);
                argvlist.set(0, helperPath);
                pb.command(argvlist); // update command
            }
        } catch (Exception ignored) { }

        String lbpath = genLibraryPath(argv, pb);

        pb.environment().put("LD_LIBRARY_PATH", lbpath);
        pb.environment().put("TMPDIR", mTmpDir);

        Log.d(TAG, "LD_LIBRARY_PATH: " + lbpath);
        Log.d(TAG, "TMPDIR: " + mTmpDir);

        pb.redirectErrorStream(true);
        try {
            Log.d(TAG, "Starting process...");
            
            // Check if the OpenVPN binary exists and get info about it
            String binaryPath = argvlist.get(0);
            java.io.File binaryFile = new java.io.File(binaryPath);
            Log.d(TAG, "Binary path: " + binaryPath);
            Log.d(TAG, "Binary exists: " + binaryFile.exists());
            Log.d(TAG, "Binary canRead: " + binaryFile.canRead());
            Log.d(TAG, "Binary canExecute: " + binaryFile.canExecute());
            Log.d(TAG, "Binary length: " + binaryFile.length());
            
            Log.d(TAG, "About to call pb.start()...");
            mProcess = pb.start();
            Log.d(TAG, "pb.start() returned successfully");
            if (mProcess == null) {
                VpnStatus.logError("Failed to start OpenVPN process - process is null");
                Log.e(TAG, "Failed to start OpenVPN process - process is null");
                return;
            }
            Log.d(TAG, "Process started successfully");
            
            // Check if process is immediately alive
            try {
                Thread.sleep(100); // Wait 100ms for process to initialize
                if (!mProcess.isAlive()) {
                    int exitCode = mProcess.exitValue();
                    Log.e(TAG, "Process died immediately with exit code: " + exitCode);
                    VpnStatus.logError("OpenVPN process died immediately with exit code: " + exitCode);
                    return;
                }
                Log.d(TAG, "Process confirmed alive after 100ms");
            } catch (Exception e) {
                Log.e(TAG, "Error checking process status: " + e.getMessage());
            }
            
            // Close the output, since we don't need it
            mProcess.getOutputStream().close();
            InputStream in = mProcess.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(in));

            while (true) {
                String logline = br.readLine();
                if (logline == null) {
                    Log.d(TAG, "OpenVPN process output stream ended");
                    
                    // Try to get exit code
                    try {
                        if (mProcess != null) {
                            int exitCode = mProcess.exitValue();
                            Log.d(TAG, "OpenVPN process exit code: " + exitCode);
                            VpnStatus.logInfo("OpenVPN process exited with code: " + exitCode);
                        }
                    } catch (Exception e) {
                        Log.d(TAG, "Could not get exit code: " + e.getMessage());
                    }
                    
                    return;
                }

                Log.d(TAG, "OpenVPN: " + logline);

                if (logline.startsWith(DUMP_PATH_STRING))
                    mDumpPath = logline.substring(DUMP_PATH_STRING.length());

                if (logline.startsWith(BROKEN_PIE_SUPPORT) || logline.contains(BROKEN_PIE_SUPPORT2))
                    mBrokenPie = true;

                Matcher m = LOG_PATTERN.matcher(logline);
                int logerror = 0;
                if (m.matches()) {
                    int flags = Integer.parseInt(m.group(3), 16);
                    String msg = m.group(4);
                    int logLevel = flags & 0x0F;

                    VpnStatus.LogLevel logStatus = VpnStatus.LogLevel.INFO;

                    if ((flags & M_FATAL) != 0)
                        logStatus = VpnStatus.LogLevel.ERROR;
                    else if ((flags & M_NONFATAL) != 0)
                        logStatus = VpnStatus.LogLevel.WARNING;
                    else if ((flags & M_WARN) != 0)
                        logStatus = VpnStatus.LogLevel.WARNING;
                    else if ((flags & M_DEBUG) != 0)
                        logStatus = VpnStatus.LogLevel.VERBOSE;

                    if (msg.startsWith("MANAGEMENT: CMD"))
                        logLevel = Math.max(4, logLevel);

                    if ((msg.endsWith("md too weak") && msg.startsWith("OpenSSL: error")) || msg.contains("error:140AB18E"))
                        logerror = 1;

                    VpnStatus.logMessageOpenVPN(logStatus, logLevel, msg);
                    if (logerror==1)
                        VpnStatus.logError("OpenSSL reported a certificate with a weak hash, please the in app FAQ about weak hashes");

                } else {
                    VpnStatus.logInfo("P:" + logline);
                }

                if (Thread.interrupted()) {
                    throw new InterruptedException("OpenVpn process was killed form java code");
                }
            }
        } catch (InterruptedException | IOException e) {
            Log.e(TAG, "Exception in OpenVPN thread: " + e.getClass().getSimpleName());
            Log.e(TAG, "Exception message: " + e.getMessage());
            Log.e(TAG, "Exception details: " + e.toString());

            // If execution from files dir is blocked (EACCES), try native lib directory helper once
            boolean retried = false;
            if (e instanceof IOException && e.getMessage() != null && e.getMessage().contains("Permission denied")) {
                try {
                    String helperPath = mNativeDir + "/libovpnexec.so";
                    java.io.File helperFile = new java.io.File(helperPath);
                    Log.e(TAG, "Permission denied running: " + mArgv[0] + ". Checking native helper: " + helperPath);
                    Log.e(TAG, "helper exists=" + helperFile.exists() + ", canExec=" + helperFile.canExecute() + ", size=" + helperFile.length());
                    if (helperFile.exists()) {
                        // Build new argv replacing binary path
                        String[] newArgv = mArgv.clone();
                        newArgv[0] = helperPath;
                        Log.e(TAG, "Retrying with native helper: " + newArgv[0]);
                        retried = true;
                        startOpenVPNThreadArgs(newArgv);
                        return; // Handled by the recursive call
                    }
                } catch (Exception retryEx) {
                    Log.e(TAG, "Retry via native helper failed: " + retryEx.getMessage());
                }
            }

            if (!retried) {
                VpnStatus.logException("Error reading from output of OpenVPN process", e);
                e.printStackTrace();
                try {
                    stopProcess();
                } catch (Exception ex) {
                    Log.e(TAG, "Error in stopProcess during exception handling: " + ex.getMessage());
                }
            }
        }


    }

    private String genLibraryPath(String[] argv, ProcessBuilder pb) {
        // Prefer the real native library directory to avoid adding file paths to LD_LIBRARY_PATH
        String base = mNativeDir;

        String existing = pb.environment().get("LD_LIBRARY_PATH");
        if (existing == null || existing.isEmpty()) {
            return base;
        } else {
            return base + ":" + existing;
        }
    }
}
