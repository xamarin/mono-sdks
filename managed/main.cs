using System;
using System.Reflection;
using NUnitLite.Runner;
using NUnit.Framework.Internal;


public class Driver {
	public static string Send (string key, string value) {
		var baseDir = AppDomain.CurrentDomain.BaseDirectory;

		// string mini_tests = baseDir + "/mini_tests.dll";
		// string[] args = { mini_tests };
		string corlib_tests = baseDir + "/android_corlib_test.dll";
		string[] args = { 
			"-labels",
			"-test=MonoTests.System.Reflection.AssemblyTest",
			// "-test=MonoTests.System.Reflection.Emit.TypeBuilderTest.IsSerializable",
			"-exclude=NotOnMac,NotWorking,ValueAdd,CAS,InetAccess,MobileNotWorking",
			corlib_tests };

		var runner = new TextUI ();
		runner.Execute (args);

		return (runner.Failure ? "FAIL" : "PASS");
	}

	public static int Main () {
		return 1;
	}
}
