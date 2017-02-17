TOP=..

BCL_DIR=$(TOP)/out/bcl
ASSETS_DIR=$(TOP)/assets/asm

all: .assets_published

main.exe: main.cs $(BCL_DIR)/mscorlib.dll
	mcs /nostdlib main.cs -r:$(BCL_DIR)/mscorlib.dll

.assets_published: main.exe $(TOP)/out/libmonosgen-2.0.so
	mkdir -p $(ASSETS_DIR)
	cp main.exe $(ASSETS_DIR)
	cp $(BCL_DIR)/mscorlib.dll $(ASSETS_DIR)
	cp $(TOP)/out/libmonosgen-2.0.so $(TOP)/jni/armeabi-v7a/
	touch .assets_published

	