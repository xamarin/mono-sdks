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
import android.content.res.AssetManager;
import android.util.Log;
import android.widget.*;
import android.view.*;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import org.mono.android.AndroidTestRunner.R;

public class AndroidRunner extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

		LayoutInflater inflater = (LayoutInflater)this.getSystemService (Context.LAYOUT_INFLATER_SERVICE);
		View view = inflater.inflate (R.layout.main, null, false);
		
		setContentView (view);
		Button b = (Button)findViewById (R.id.button);
		final TextView tv = (TextView)findViewById (R.id.text);

        b.setOnClickListener(new View.OnClickListener () {
	          public void onClick(View v) {
				  tv.setText (send ("run", "tests"));
	          }
	      });

		setupRuntime (this);
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
		execMain ();
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

    native void init(String path0, String path1, String path2, String path3);
	native int execMain ();
	native String send (String key, String value);

    static {
        System.loadLibrary("runtime-bootstrap");
    }
}
