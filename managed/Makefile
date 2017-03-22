TOP=$(realpath $(CURDIR)/..)

BCL_DIR=$(TOP)/out/bcl
DEPS_DIR=$(TOP)/out/deps
ASSETS_DIR=$(TOP)/assets/asm

MINI_TEST_FILES= \
	TestDriver.cs	\
	aot-tests.cs \
	arrays.cs	\
	basic-calls.cs	\
	basic-float.cs	\
	basic-long.cs	\
	basic-math.cs	\
	basic.cs	\
	exceptions.cs	\
	generics.cs	\
	gshared.cs	\
	objects.cs

BCL_ASSEMBLIES=	\
	mscorlib.dll	\
	System.dll	\
	System.Core.dll	\
	System.Xml.dll	\
	Mono.Security.dll

DEPS_ASSEMBLIES= \
	nunitlite.dll

MINI_PATH=$(MONO_SOURCE_PATH)/mono/mini
MINI_TEST_SOURCES= $(patsubst %,$(MINI_PATH)/%,$(MINI_TEST_FILES))
MINI_TEST_DEPS= $(patsubst %,-r:%,$(BCL_FILES) $(DEPS_FILES))

BCL_FILES=$(patsubst %,$(BCL_DIR)/%,$(BCL_ASSEMBLIES))
DEPS_FILES=$(patsubst %,$(DEPS_DIR)/%,$(DEPS_ASSEMBLIES))

BUILD_ARTIFACT= main.exe mini_tests.dll Mono.Android.dll monodroid_corlib_test.dll monodroid_System_test.dll

all: .assets_published

mini_tests.dll: $(MINI_TEST_SOURCES) mini-test-runner.cs $(BCL_FILES) $(DEPS_FILES)
	mcs /nostdlib /unsafe -target:library -out:mini_tests.dll -define:__MOBILE__ $(MINI_TEST_DEPS) $(MINI_TEST_SOURCES) mini-test-runner.cs 

#FIXME copy the resource assemblies
monodroid_corlib_test.dll: $(BCL_FILES) $(DEPS_FILES)
	pushd $(TOP)/external/mono/mcs/class/corlib &&	\
	make build-test-lib &&	\
	cp $@ $(TOP)/managed/ && \
	popd

monodroid_System_test.dll: $(BCL_FILES) $(DEPS_FILES)
	pushd $(TOP)/external/mono/mcs/class/System &&	\
	make build-test-lib &&	\
	cp $@ $(TOP)/managed/ && \
	popd

main.exe: main.cs mini_tests.dll $(BCL_FILES) $(DEPS_FILES)
	mcs /nostdlib main.cs $(MINI_TEST_DEPS)

Mono.Android.dll: fake-monodroid.cs
	mcs /nostdlib fake-monodroid.cs -target:library -out:Mono.Android.dll $(MINI_TEST_DEPS)

clean:
	rm $(BUILD_ARTIFACT)

.assets_published: Makefile $(BUILD_ARTIFACT)
	mkdir -p $(ASSETS_DIR)
	cp $(BUILD_ARTIFACT) $(ASSETS_DIR)
	cp $(BCL_FILES) $(DEPS_FILES) $(ASSETS_DIR)
	touch .assets_published


.PHONY:
