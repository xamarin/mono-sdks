using System;
using System.Threading;
using System.Reflection;
using NUnitLite.Runner;
using NUnit.Framework.Internal;


public class Driver {
	static TextUI runner;
	static Thread runner_thread;
	static bool done;

	public static string Send (string key, string value) {
		if (key == "start") {
			if (runner != null)
				return "IN-PROGRESS";
			StartTest ();
			return "STARTED";
		} else if (key == "status") {
			if (!done)
				return "IN-PROGRESS";
			done = false;
			runner_thread.Join ();
			runner_thread = null;

			var local_runner = runner;
			runner = null;
			return local_runner.Failure ? "FAIL" : "PASS";
		} else {
			return "WTF";
		}
	}

	public static void StartTest () {
		var baseDir = AppDomain.CurrentDomain.BaseDirectory;

		string extra_disable = "";
		if (IntPtr.Size == 4)
			extra_disable = ",LargeFileSupport";

		string corlib_tests = baseDir + "/android_corlib_test.dll";
		string[] args = { 
			"-labels",
			// "-test=MonoTests.System.Runtime.InteropServices.SafeHandleTest",
			"-exclude=NotOnMac,NotWorking,ValueAdd,CAS,InetAccess,MobileNotWorking,SatelliteAssembliesNotWorking" + extra_disable,
			corlib_tests };

		done = false;
		runner = new TextUI ();
		runner_thread = new Thread ( () => {
			runner.Execute (args);
			done = true;
		});
		runner_thread.Start ();
	}

	public static int Main () {
		return 1;
	}
}
