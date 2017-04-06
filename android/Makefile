TOP=$(CURDIR)/..
include $(TOP)/paths.mk
ADB       = $(SDK_DIR)/platform-tools/adb
ANDROID   = $(SDK_DIR)/tools/android
ANT       = ant
NDK_BUILD = $(NDK_DIR)/ndk-build

PACKAGE   = org.mono.android.AndroidTestRunner
ACTIVITY  = org.mono.android.AndroidRunner

PROJECT_SETUP_FILES = project.properties local.properties

all: setup stage-sdk
	make -C managed all
	$(NDK_BUILD)
	$(ANT) debug
	$(ANT) release

stage-sdk:
	mkdir -p jni/armeabi-v7a
	mkdir -p jni/arm64-v8a
	mkdir -p jni/x86
	mkdir -p jni/x86_64
	cp $(TOP)/out/armv7-android/* jni/armeabi-v7a/
	cp $(TOP)/out/aarch64-android/* jni/arm64-v8a/
	cp $(TOP)/out/x86-android/* jni/x86/
	cp $(TOP)/out/x86_64-android/* jni/x86_64/
	mkdir -p assets/mconfig
	cp machine.config assets/mconfig

app: setup stage-sdk
	make -C managed all
	$(NDK_BUILD)
	$(ANT) debug

clean:
	$(ANT) clean

deploy:
	$(ADB) install bin/AndroidRunner-debug.apk

undeploy:
	$(ADB) uninstall $(PACKAGE)

redeploy:
	$(ADB) uninstall $(PACKAGE)
	$(ADB) install bin/AndroidRunner-debug.apk

run:
	$(ADB) shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER $(PACKAGE)/$(ACTIVITY)

kill:
	$(ADB) shell am force-stop $(PACKAGE)

$(PROJECT_SETUP_FILES): build.xml AndroidManifest.xml
	$(ANDROID) update project -p . -t "android-14"

setup: $(PROJECT_SETUP_FILES)

logcat:
	$(ADB) logcat

shell:
	$(ADB) shell
