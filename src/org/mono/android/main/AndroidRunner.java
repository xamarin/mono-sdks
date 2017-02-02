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
        tv.setText (update ("foo"));
        setContentView(tv);
    }

	public void setupRuntime (Context context) {
		String filesDir     = context.getFilesDir ().getAbsolutePath ();
		String cacheDir     = context.getCacheDir ().getAbsolutePath ();
		String dataDir      = getNativeLibraryPath (context);	
		init (filesDir, cacheDir, dataDir);
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

    public native void init(String path0, String path1, String path2);
	
    public native String update(String value);

    static {
        System.loadLibrary("hello-jni");
    }
}
