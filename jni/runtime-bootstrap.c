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
 *
 */
#include <string.h>
#include <stdlib.h>
#include <jni.h>
#include <android/log.h>
#include <stdarg.h>
#include <stdio.h>
#include <pthread.h>
 #include <dlfcn.h>

static jclass       Object_class;
static jmethodID    Object_toString;
static jclass       Integer_class;
static jmethodID    Integer_init_int;
static jclass       Runtime_class;
static jmethodID    Runtime_gc;
static jmethodID    Runtime_getRuntime;
static jclass       WeakReference_class;
static jmethodID    WeakReference_get;
static jmethodID    WeakReference_init_object;

static int log_index;

static void
_log (const char *format, ...)
{
	char buf[100];
  va_list args;
	if (log_index > 0) {
		sprintf (buf, "wref[%i]", log_index);
	} else {
		sprintf (buf, "*wref-tests*");
	}
  va_start (args, format);
  __android_log_vprint (ANDROID_LOG_INFO, buf, format, args);
  va_end (args);
}

typedef int (*g_setenv_fn) (const char *variable, const char *value, int overwrite);

static char file_dir[2048];
static char cache_dir[2048];
static char data_dir[2048];

static void
cpy_str (JNIEnv *env, char *buff, jstring str)
{
	jboolean isCopy = 0;
	const char *copy_buff = (*env)->GetStringUTFChars (env, str, &isCopy);
	strcpy (buff, copy_buff);
	if (isCopy)
		(*env)->ReleaseStringUTFChars (env, str, copy_buff);
}

void
Java_com_example_hellojni_HelloJni_init (JNIEnv* env, jobject esse, jstring path0, jstring path1, jstring path2)
{
	_log ("IN Java_com_example_hellojni_HelloJni_init \n");
	cpy_str (env, file_dir, path0);
	cpy_str (env, cache_dir, path1);
	cpy_str (env, data_dir, path2);
	
	_log ("I GOTS STRING %s\n", file_dir);
	_log ("I GOTS STRING %s\n", cache_dir);
	_log ("I GOTS STRING %s\n", data_dir);
}

jstring
Java_com_example_hellojni_HelloJni_update (JNIEnv* env, jobject thiz, jstring defaultValue)
{
	char *appname = "com.xamarin.android.ArtThreadHandlesTest";
	char buff[1024];
	_log ("****HERE WE GO*\n");

	sprintf (buff, "/data/data/%s/lib/libmonosgen-2.0.so", appname); 
	void *libmono = dlopen (buff, RTLD_LAZY);
	_log ("LIBMONO %p\n", libmono);

	g_setenv_fn g_setenv = (g_setenv_fn)dlsym (libmono, "g_getenv");
	_log ("LIBMONO FUNS: %p\n", g_setenv);

	// g_setenv ("MONO_PATH", assembly_path, 1);

	//
	// orbis_setup ();
	// orbis_register_modules ();
	// mono_jit_set_aot_only (1);
	//
	// //debugger_setup ();
	// mono_jit_init_version ("ORBIS", "v2.0.50727");
	// assembly = mono_assembly_open (main_assembly_name, NULL);
	// result = mono_jit_exec (mono_domain_get (), assembly, argc, argv);

	printf ("Test project complete\n");
	return (*env)->NewStringUTF (env, "oi mundo");
}

