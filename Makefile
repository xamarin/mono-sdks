SDK_DIR   = /Users/kumpera/Library/Developer/Xamarin/android-sdk-mac_x86
ADB       = $(SDK_DIR)/platform-tools/adb
ANDROID   = $(SDK_DIR)/tools/android
ANT       = ant
NDK_BUILD = /Users/kumpera/Library/Developer/Xamarin/android-ndk/android-ndk-r8d/ndk-build

PACKAGE   = org.mono.android.AndroidTestRunner
ACTIVITY  = org.mono.android.AndroidRunner

all:
	make -C managed all
	$(NDK_BUILD)
	$(ANT) debug

clean:
	$(ANT) clean

deploy:
	$(ADB) install bin/AndroidRunner-debug.apk

undeploy:
	$(ADB) uninstall $(PACKAGE)

run:
	$(ADB) shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER $(PACKAGE)/$(ACTIVITY)

kill:
	$(ADB) shell am force-stop $(PACKAGE)

setup:
	$(ANDROID) update project -p . -t "android-19"

logcat:
	$(ADB) logcat

shell:
	$(ADB) shell


.PHONY: clean