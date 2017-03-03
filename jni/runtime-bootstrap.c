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
#include <stdarg.h>
#include <stdio.h>
#include <pthread.h>
 #include <dlfcn.h>

#include <android/log.h>
#include <sys/system_properties.h>

typedef enum {
        MONO_IMAGE_OK,
        MONO_IMAGE_ERROR_ERRNO,
        MONO_IMAGE_MISSING_ASSEMBLYREF,
        MONO_IMAGE_IMAGE_INVALID
} MonoImageOpenStatus;

enum {
        MONO_DL_EAGER = 0,
        MONO_DL_LAZY  = 1,
        MONO_DL_LOCAL = 2,
        MONO_DL_MASK  = 3
};

typedef struct MonoDomain_ MonoDomain;
typedef struct MonoAssembly_ MonoAssembly;
typedef struct MonoMethod_ MonoMethod;
typedef struct MonoException_ MonoException;
typedef struct MonoString_ MonoString;
typedef struct MonoClass_ MonoClass;
typedef struct MonoImage_ MonoImage;
typedef struct MonoObject_ MonoObject;
typedef struct MonoThread_ MonoThread;

/*
 * The "err" variable contents must be allocated using g_malloc or g_strdup
 */
typedef void* (*MonoDlFallbackLoad) (const char *name, int flags, char **err, void *user_data);
typedef void* (*MonoDlFallbackSymbol) (void *handle, const char *name, char **err, void *user_data);
typedef void* (*MonoDlFallbackClose) (void *handle, void *user_data);

typedef void *(*mono_dl_fallback_register_fn) (MonoDlFallbackLoad load_func, MonoDlFallbackSymbol symbol_func, MonoDlFallbackClose close_func, void *user_data);

typedef MonoDomain* (*mono_jit_init_version_fn) (const char *root_domain_name, const char *runtime_version);
typedef int (*mono_jit_exec_fn) (MonoDomain *domain, MonoAssembly *assembly, int argc, char *argv[]);
typedef MonoDomain* (*mono_domain_get_fn) (void);
typedef MonoAssembly* (*mono_assembly_open_fn) (const char *filename, MonoImageOpenStatus *status);
typedef void (*mono_set_assemblies_path_fn) (const char* path);
typedef MonoString* (*mono_string_new_fn) (MonoDomain *domain, const char *text);
typedef MonoClass* (*mono_class_from_name_case_fn) (MonoImage *image, const char* name_space, const char *name);
typedef MonoImage* (*mono_assembly_get_image_fn) (MonoAssembly *assembly);
typedef MonoClass* (*mono_class_from_name_fn) (MonoImage *image, const char* name_space, const char *name);
typedef MonoMethod* (*mono_class_get_method_from_name_fn) (MonoClass *klass, const char *name, int param_count);
typedef MonoString* (*mono_object_to_string_fn) (MonoObject *obj, MonoObject **exc);
typedef char* (*mono_string_to_utf8_fn) (MonoString *string_obj);
typedef MonoObject* (*mono_runtime_invoke_fn) (MonoMethod *method, void *obj, void **params, MonoObject **exc);
typedef void (*mono_free_fn) (void*);
typedef void (*mono_set_crash_chaining_fn) (int);
typedef void (*mono_set_signal_chaining_fn) (int);
typedef MonoThread *(*mono_thread_attach_fn) (MonoDomain *domain);


static mono_jit_init_version_fn mono_jit_init_version;
static mono_assembly_open_fn mono_assembly_open;
static mono_domain_get_fn mono_domain_get;
static mono_jit_exec_fn mono_jit_exec;
static mono_set_assemblies_path_fn mono_set_assemblies_path;
static mono_string_new_fn mono_string_new;
static mono_class_from_name_case_fn mono_class_from_name_case;
static mono_assembly_get_image_fn mono_assembly_get_image;
static mono_class_from_name_fn mono_class_from_name;
static mono_class_get_method_from_name_fn mono_class_get_method_from_name;
static mono_object_to_string_fn mono_object_to_string;
static mono_string_to_utf8_fn mono_string_to_utf8;
static mono_runtime_invoke_fn mono_runtime_invoke;
static mono_free_fn mono_free;
static mono_set_crash_chaining_fn mono_set_crash_chaining;
static mono_set_signal_chaining_fn mono_set_signal_chaining;
static mono_dl_fallback_register_fn mono_dl_fallback_register;
static mono_thread_attach_fn mono_thread_attach;


static char file_dir[2048];
static char cache_dir[2048];
static char data_dir[2048];
static char assemblies_dir[2048];

static MonoAssembly *main_assembly;

//forward decls

static void* my_dlsym (void *handle, const char *name, char **err, void *user_data);
static void* my_dlopen (const char *name, int flags, char **err, void *user_data);


//stuff
static void
_log (const char *format, ...)
{
	char buf[100];
	va_list args;
	sprintf (buf, "MONO");
	va_start (args, format);
	__android_log_vprint (ANDROID_LOG_INFO, buf, format, args);
	va_end (args);
}

static void
cpy_str (JNIEnv *env, char *buff, jstring str)
{
	jboolean isCopy = 0;
	const char *copy_buff = (*env)->GetStringUTFChars (env, str, &isCopy);
	strcpy (buff, copy_buff);
	if (isCopy)
		(*env)->ReleaseStringUTFChars (env, str, copy_buff);
}

static char *
m_strdup_printf (const char *format, ...)
{
        char *ret;
        va_list args;
        int n;

        va_start (args, format);
        n = vasprintf (&ret, format, args);
        va_end (args);
        if (n == -1)
                return NULL;

        return ret;
}

static MonoDomain *root_domain;
//jni funcs
void
Java_org_mono_android_AndroidRunner_init (JNIEnv* env, jobject _this, jstring path0, jstring path1, jstring path2, jstring path3)
{
	char buff[1024];

	_log ("IN Java_com_example_hellojni_HelloJni_init \n");
	cpy_str (env, file_dir, path0);
	cpy_str (env, cache_dir, path1);
	cpy_str (env, data_dir, path2);
	cpy_str (env, assemblies_dir, path3);

	_log ("-- file dir %s\n", file_dir);
	_log ("-- cache dir %s\n", cache_dir);
	_log ("-- data dir %s\n", data_dir);
	_log ("-- assembly dir %s\n", assemblies_dir);


	sprintf (buff, "%s/libmonosgen-2.0.so", data_dir);
	void *libmono = dlopen (buff, RTLD_LAZY);

	mono_jit_init_version = dlsym (libmono, "mono_jit_init_version");
	mono_assembly_open = dlsym (libmono, "mono_assembly_open");
	mono_domain_get = dlsym (libmono, "mono_domain_get");
	mono_jit_exec = dlsym (libmono, "mono_jit_exec");
	mono_set_assemblies_path = dlsym (libmono, "mono_set_assemblies_path");
	mono_string_new = dlsym (libmono, "mono_string_new");
	mono_class_from_name_case = dlsym (libmono, "mono_class_from_name_case");
	mono_assembly_get_image = dlsym (libmono, "mono_assembly_get_image");
	mono_class_from_name = dlsym (libmono, "mono_class_from_name");
	mono_class_get_method_from_name = dlsym (libmono, "mono_class_get_method_from_name");
	mono_object_to_string = dlsym (libmono, "mono_object_to_string");
	mono_string_to_utf8 = dlsym (libmono, "mono_string_to_utf8");
	mono_runtime_invoke = dlsym (libmono, "mono_runtime_invoke");
	mono_free = dlsym (libmono, "mono_free");
	mono_set_crash_chaining = dlsym (libmono, "mono_set_crash_chaining");
	mono_set_signal_chaining = dlsym (libmono, "mono_set_signal_chaining");
	mono_dl_fallback_register = dlsym (libmono, "mono_dl_fallback_register"); 
	mono_thread_attach = dlsym (libmono, "mono_thread_attach"); 


	//MUST HAVE envs
	setenv ("TMPDIR", cache_dir, 1);
	setenv ("MONO_CFG_DIR", file_dir, 1);

	// setenv ("MONO_LOG_LEVEL", "debug", 1);
	// setenv ("MONO_VERBOSE_METHOD", "GetCallingAssembly", 1);

	mono_set_assemblies_path (assemblies_dir);
	mono_set_crash_chaining (1);
	mono_set_signal_chaining (1);
	mono_dl_fallback_register (my_dlopen, my_dlsym, NULL, NULL);
	root_domain = mono_jit_init_version ("TEST RUNNER", "mobile");
}

int
Java_org_mono_android_AndroidRunner_execMain (JNIEnv* env, jobject _this)
{
	int argc = 1;
	char *argv[] = { "main.exe" };
	char *main_assembly_name = "main.exe";
	char buff[1024];

	mono_thread_attach (root_domain);
	sprintf (buff, "%s/%s", assemblies_dir, main_assembly_name);
	main_assembly = mono_assembly_open (buff, NULL);

	MonoDomain *domain = mono_domain_get ();
	return mono_jit_exec (domain, main_assembly, argc, argv);
}

static MonoMethod *send_method;

jstring
Java_org_mono_android_AndroidRunner_send (JNIEnv* env, jobject thiz, jstring key, jstring val)
{
	jboolean key_copy, val_copy;
	const char *key_buff = (*env)->GetStringUTFChars (env, key, &key_copy);
	const char *val_buff = (*env)->GetStringUTFChars (env, val, &val_copy);

	mono_thread_attach (root_domain);

	void * params[] = {
		mono_string_new (mono_domain_get (), key_buff),
		mono_string_new (mono_domain_get (), val_buff),
	};

	if (!send_method) {
		MonoClass *driver_class = mono_class_from_name (mono_assembly_get_image (main_assembly), "", "Driver");
		send_method = mono_class_get_method_from_name (driver_class, "Send", -1);
	}

	MonoException *exc = NULL;
	MonoString *res = (MonoString *)mono_runtime_invoke (send_method, NULL, params, (MonoObject**)&exc);
	jstring java_result;
	if (exc) {
		MonoException *second_exc = NULL;
		res = mono_object_to_string ((MonoObject*)exc, (MonoObject**)&second_exc);
		if (second_exc)
			res = mono_string_new (mono_domain_get (), "DOUBLE FAULTED EXCEPTION");
	}

	if (res) {
		char *str = mono_string_to_utf8 (res);
		_log ("SEND RETURNED: %s\n", str);
		java_result = (*env)->NewStringUTF (env, str);
		mono_free (str);
	} else {
		java_result = (*env)->NewStringUTF (env, "<NULL>");
	}

	if (key_copy)
		(*env)->ReleaseStringUTFChars (env, key, key_buff);

	if (val_copy)
		(*env)->ReleaseStringUTFChars (env, val, val_buff);

	return java_result;
}

static int
convert_dl_flags (int flags)
{
	int lflags = flags & MONO_DL_LOCAL? 0: RTLD_GLOBAL;

	if (flags & MONO_DL_LAZY)
		lflags |= RTLD_LAZY;
	else
		lflags |= RTLD_NOW;
	return lflags;
}


/*
This is the Android specific glue ZZZZOMG

# Issues with the monodroid BCL profile
	This pinvoke should not be on __Internal by libmonodroid.so: System.TimeZoneInfo+AndroidTimeZones:monodroid_get_system_property
	This depends on monodroid native code: System.TimeZoneInfo+AndroidTimeZones.GetDefaultTimeZoneName
*/

#define MONO_API __attribute__ ((__visibility__ ("default")))

static void*
my_dlopen (const char *name, int flags, char **err, void *user_data)
{
	char *the_name = name;
	if (!name)
		the_name = m_strdup_printf ("%s/libruntime-bootstrap.so", data_dir);

	void *res = dlopen (the_name, convert_dl_flags (flags));

	//TODO handle loading AOT modules from assemblies_dir

	if (the_name != name)
		free (the_name);

	return res;
}

static void*
my_dlsym (void *handle, const char *name, char **err, void *user_data)
{
	void *s;
	
	s = dlsym (handle, name);

	if (!s && err) {
		*err = m_strdup_printf ("Could not find symbol '%s'.", name);
	}

	return s;
}

MONO_API int
monodroid_get_system_property (const char *name, char **value)
{
	char *pvalue;
	char  sp_value [PROP_VALUE_MAX+1] = { 0, };
	int   len;

	if (value)
		*value = NULL;

	pvalue  = sp_value;
	len     = __system_property_get (name, sp_value);

	if (len >= 0 && value) {
		*value = malloc (len + 1);
		if (!*value)
			return -len;
		memcpy (*value, pvalue, len);
		(*value)[len] = '\0';
	}

	return len;
}

MONO_API void
monodroid_free (void *ptr)
{
	free (ptr);
}
