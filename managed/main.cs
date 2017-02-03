using System;

public class Main {
	public static string Send (string key, string value) {
		Console.WriteLine ($"I got {key}:{value}");
		return "PASS";
	}
}

public class Driver {


	static int Main () {
		Console.WriteLine ("IT WORKS");
		return 99;
	}
}