TOP=$(realpath $(CURDIR)/..)

BCL_DIR=$(TOP)/out/bcl
DEPS_DIR=$(TOP)/out/deps
ASSETS_DIR=$(TOP)/assets/asm

BCL_ASSEMBLIES=	\
	mscorlib.dll	\
	System.dll	\
	System.Core.dll	\
	System.Xml.dll	\
	Mono.Security.dll

MINI_PATH=$(MONO_SOURCE_PATH)/mono/mini

BCL_FILES=$(patsubst %,$(BCL_DIR)/%,$(BCL_ASSEMBLIES))

TEST_DEPS=$(patsubst %,-r:%,$(BCL_FILES))

BUILD_ARTIFACT=main.exe Mono.Android.dll


all: .assets_published

main.exe: main.cs $(BCL_FILES)
	mcs /nostdlib main.cs $(TEST_DEPS)

Mono.Android.dll: fake-monodroid.cs
	mcs /nostdlib fake-monodroid.cs -target:library $(TEST_DEPS) -out:Mono.Android.dll

clean:
	rm $(BUILD_ARTIFACT)

.assets_published: Makefile $(BUILD_ARTIFACT)
	mkdir -p $(ASSETS_DIR)
	cp $(BUILD_ARTIFACT) $(ASSETS_DIR)
	cp $(BCL_FILES) $(DEPS_FILES) $(ASSETS_DIR)
	touch .assets_published


.PHONY:
