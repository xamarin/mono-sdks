using System;
using System.Collections.Generic;
using System.Linq;
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
			StartTest (value);
			return "STARTED";
		} else if (key == "status") {
			if (!done)
				return runner == null ? "NO RUN" : "IN-PROGRESS";
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

	public class TestSuite {
		public string Name { get; set; }
		public string File { get; set; }
	}

	static TestSuite[] suites = new TestSuite [] {
		new TestSuite () { Name = "mini", File = "mini_tests.dll" },
		new TestSuite () { Name = "corlib", File = "monodroid_mscorlib_test.dll" },
		new TestSuite () { Name = "system", File = "monodroid_System_test.dll" },
	};

	public static void StartTest (string name) {
		var baseDir = AppDomain.CurrentDomain.BaseDirectory;

		string extra_disable = "";
		if (IntPtr.Size == 4)
			extra_disable = ",LargeFileSupport";

		string[] args = name.Split (',');
		var testsuite_name = suites.Where (ts => ts.Name == args [0]).Select (ts => ts.File).FirstOrDefault ();
		if (testsuite_name == null)
			throw new Exception ("NO SUITE NAMED " + args [0]);

		string test_name = null;
		int? range = null;
		for (int i = 1; i < args.Length; ++i) {
			int r;
			if (int.TryParse (args [i], out r))
				range = r;
			else
				test_name = args [i];
		}

		var arg_list = new List<string> ();
		arg_list.Add ("-labels");
		if (test_name != null)
			arg_list.Add ("-test=" + test_name);

		arg_list.Add ("-exclude=NotOnMac,NotWorking,ValueAdd,CAS,InetAccess,MobileNotWorking,SatelliteAssembliesNotWorking" + extra_disable);
		arg_list.Add (baseDir + "/" + testsuite_name);

		done = false;
		runner = new TextUI ();
		runner_thread = new Thread ( () => {
			runner.Execute (arg_list.ToArray ());
			done = true;
		});
		runner_thread.Start ();
	}

	public static int Main () {
		return 1;
	}
}
