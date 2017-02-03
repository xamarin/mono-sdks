TOP=..

BCL_DIR=$(TOP)/bcl
ASSETS_DIR=$(TOP)/assets/asm

all: .assert_published


main.exe: main.cs
	mcs /nostdlib main.cs -r:$(BCL_DIR)/mscorlib.dll

.assert_published: main.exe
	mkdir -p $(ASSETS_DIR)
	cp main.exe $(ASSETS_DIR)
	cp $(BCL_DIR)/mscorlib.dll $(ASSETS_DIR)
	touch .assert_published

	