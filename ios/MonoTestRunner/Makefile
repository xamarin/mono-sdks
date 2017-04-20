TOP=../../

MT_BCL=$(TOP)/out/bcl/monotouch

logcat:
	tail -f  ~/Library/Logs/CoreSimulator/0812220D-8709-4335-8E13-400765C26515/system.log 

prep-managed:
	mkdir -p managed
	mcs main.cs  -out:managed/main.exe
	cp $(MT_BCL)/mscorlib.dll managed/

build-sim32: prep-managed
	xcodebuild -configuration Debug -arch i386 -sdk iphonesimulator

build-sim64: prep-managed
	xcodebuild -configuration Debug -arch x86_64 -sdk iphonesimulator

install:
	xcrun simctl install booted  build/Debug-iphonesimulator/MonoTestRunner.app

launch:
	xcrun simctl  launch booted runtime.MonoTestRunner

boot:
	nohup /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/Contents/MacOS/Simulator -CurrentDeviceUDID 0812220D-8709-4335-8E13-400765C26515 &

shutdown:
	xcrun simctl shutdown all

kill:
	xcrun simctl  terminate booted runtime.MonoTestRunner
