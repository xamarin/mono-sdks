using System;

public class Driver {
	public static string Send (string key, string value) {
		Console.WriteLine ($"I got {key}:{value}");
		return "PASS";
	}

	public static int Main () {
		Console.WriteLine ("IT WORKS");
		return 99;
	}
}