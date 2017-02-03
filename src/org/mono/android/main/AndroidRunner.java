/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.mono.android;

import android.content.pm.ApplicationInfo;
import android.content.Context;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class AndroidRunner extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
		setupRuntime (this);

        /* Create a TextView and set its content.
         * the text is retrieved by calling a native
         * function.
         */
        TextView  tv = new TextView(this);
        tv.setText ("whatever");
        setContentView(tv);
    }

	void copy (InputStream in, OutputStream out) throws IOException {
		byte[] buff = new byte [1024];
		int len = in.read (buff);
		while (len != -1) {
		    out.write (buff, 0, len);
		    len = in.read (buff);
		}
		in.close ();
		out.close ();
	}

	void copyAssetDir (AssetManager am, String path, String outpath) {
		Log.w ("MONO", "EXTRACTING: " + path);
		try {
			String[] res = am.list (path);
			for (int i = 0; i < res.length; ++i) {
				String fromFile = path + "/" + res [i];
				String toFile = outpath + "/" + res [i];
				Log.w ("MONO", "\tCOPYING " + fromFile + " to " + toFile);
				copy (am.open (fromFile), new FileOutputStream (toFile));
			}
		} catch (Exception e) {
			Log.w ("MONO", "WTF", e);
		}
	}
	public void setupRuntime (Context context) {
		String filesDir     = context.getFilesDir ().getAbsolutePath ();
		String cacheDir     = context.getCacheDir ().getAbsolutePath ();
		String dataDir      = getNativeLibraryPath (context);

		String assemblyDir = filesDir + "/" + "assemblies";

		//XXX copy stuff
		Log.w ("MONO", "DOING THE COPYING!2");

		AssetManager am = context.getAssets ();
		new File (assemblyDir).mkdir ();

		copyAssetDir (am, "asm", assemblyDir);


		init (filesDir, cacheDir, dataDir, assemblyDir);
		update ("foo");
	}

	static String getNativeLibraryPath (Context context)
	{
	    return getNativeLibraryPath (context.getApplicationInfo ());
	}

	static String getNativeLibraryPath (ApplicationInfo ainfo)
	{
		if (android.os.Build.VERSION.SDK_INT >= 9)
			return ainfo.nativeLibraryDir;
		return ainfo.dataDir + "/lib";
	}

    public native void init(String path0, String path1, String path2, String path3);
	
    public native String update(String value);

    static {
        System.loadLibrary("runtime-bootstrap");
    }
}
