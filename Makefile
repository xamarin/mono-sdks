SDK_DIR   = /Users/kumpera/Library/Developer/Xamarin/android-sdk-mac_x86/
ADB       = $(SDK_DIR)/platform-tools/adb
ANDROID   = $(SDK_DIR)/tools/android
ANT       = ant
NDK_DIR   = /Users/kumpera/android-ndk-r11c
NDK_BUILD = $(NDK_DIR)/ndk-build

PACKAGE   = org.mono.android.AndroidTestRunner
ACTIVITY  = org.mono.android.AndroidRunner

all:
	make -C managed all
	make -C sdks all
	$(NDK_BUILD)
	$(ANT) debug
	$(ANT) release

stage-sdk:
	mkdir -p jni/armeabi-v7a
	mkdir -p jni/arm64-v8a
	cp out/armv7-android/libmonosgen-2.0.so jni/armeabi-v7a/
	cp out/aarch64-android/libmonosgen-2.0.so jni/arm64-v8a/

app: stage-sdk
	make -C managed all
	$(NDK_BUILD)
	$(ANT) debug
	$(ANT) release

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
	$(ANDROID) update project -p . -t "android-14"

logcat:
	$(ADB) logcat

shell:
	$(ADB) shell


.PHONY: clean