TOP=..
MONO_PATH=$(TOP)/external/mono
MONO_FRAMEWORK=/Library/Frameworks/Mono.framework/Versions/Current/


USE_NDK=false
IS_RELEASE=true

ifeq ($(USE_NDK),true)

NDK_PLATFORM_ROOT=/Users/kumpera/android-ndk-r11c
TOOLCHAIN_ROOT=$(NDK_PLATFORM_ROOT)
TOOLCHAIN_NAME=arm-linux-androideabi-4.9
TOOLCHAIN_BIN_DIR=$$(TOOLCHAIN_ROOT)/toolchains/$(TOOLCHAIN_NAME)/prebuilt/darwin-x86_64/bin
CC_NAME=gcc
CXX_NAME=g++
EXTRA_CC_FLAG=--sysroot=$(NDK_PLATFORM)/arch-arm -nostdlib
EXTRA_DEPS=setup-toolchain
else

NDK_PLATFORM_ROOT=/Users/kumpera/android-toolchain/ndk
TOOLCHAIN_ROOT=/Users/kumpera/android-toolchain
TOOLCHAIN_NAME=arm-linux-androideabi-clang
TOOLCHAIN_BIN_DIR=$$(TOOLCHAIN_ROOT)/toolchains/$(TOOLCHAIN_NAME)/bin
CC_NAME=clang
CXX_NAME=clang++
EXTRA_CC_FLAG=
endif

NDK_PLATFORM=$(NDK_PLATFORM_ROOT)/platforms/android-4

COMMON_CONFIGURE_FLAGS= \
			--without-ikvm-native \
			--enable-maintainer-mode \
			--with-profile2=no \
			--with-profile4=no \
			--with-profile4_5=no \
			--with-monodroid \
			--enable-nls=no \
			--with-sigaltstack=yes \
			--with-tls=pthread \
			--enable-extension-module=xamarin	\
			--enable-dynamic-btls \
			--with-btls-android-ndk=$(NDK_PLATFORM_ROOT) \
			mono_cv_uscore=yes			

ifeq ($(IS_RELEASE),true)
REL_FLAGS=-g -O2
else
REL_FLAGS=-ggdb3 -O0
endif


COMMON_CFLAGS=$(REL_FLAGS) -fno-omit-frame-pointer
COMMON_LDFLAGS=-ldl -lm -llog -lc -lgcc
SECURITY_CFLAGS = -Wl,-z,now -Wl,-z,relro -Wl,-z,noexecstack -fstack-protector

ARM_CFLAGS=$(COMMON_CFLAGS) -D__POSIX_VISIBLE=201002 -DSK_RELEASE -DNDEBUG -UDEBUG -fpic
ARM_CXXFLAGS=$(ARM_CFLAGS)
ARM_CPP=-I$(NDK_PLATFORM)/arch-arm/usr/include/
ARM_LDFLAGS=$(COMMON_LDFLAGS) -Wl,--fix-cortex-a8 \
			-Wl,-rpath-link=$(NDK_PLATFORM)/arch-arm/usr/lib,-dynamic-linker=/system/bin/linker \
			-L$(NDK_PLATFORM)/arch-arm/usr/lib

TARGET_CONFIGURE_FLAGS= \
	--cache-file=../armeabi-v7a.config.cache \
	--host=armv5-linux-androideabi \
	--without-ikvm-native --enable-maintainer-mode	\
	--with-profile2=no --with-profile4=no --with-profile4_5=no --with-monodroid --enable-nls=no --with-sigaltstack=yes \
	--with-tls=pthread mono_cv_uscore=yes \
	--enable-minimal=ssa,portability,attach,verifier,full_messages,sgen_remset,sgen_marksweep_par,sgen_marksweep_fixed,sgen_marksweep_fixed_par,sgen_copying,logging,security,shared_handles \
	--disable-mcs-build --disable-executables --disable-iconv \
	--enable-dynamic-btls --with-btls-android-ndk=$(NDK_PLATFORM_ROOT)

THE_CC=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CC_NAME)
THE_CXX=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CXX_NAME)

TARGET_EXTRA_CFLAGS=-mtune=cortex-a8 -march=armv7-a -mfpu=vfp -mfloat-abi=softfp
TARGET_CFLAGS=$(ARM_CFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_CXXFLAGS=$(ARM_CXXFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_LDFLAGS=$(ARM_LDFLAGS)
TARGET_CC=$(THE_CC) $(EXTRA_CC_FLAG)
TARGET_CXX=$(THE_CXX) $(EXTRA_CC_FLAG)
TARGET_CPP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(ARM_CPP)
TARGET_CXXCPP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(ARM_CPP)
TARGET_LD=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ld
TARGET_AS=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-as
TARGET_AR=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ar
TARGET_RANLIB=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ranlib
TARGET_STRIP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-strip
TARGET_DLLTOOL=""
TARGET_OBJDUMP="$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-objdump"
TARGET_NAME=arm-linux-androideabi
TARGET_DIR=armv7-android

CONFIGURE_ENVIRONMENT = \
	LDFLAGS="$(TARGET_LDFLAGS)"	\
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS) " \
	CC="$(TARGET_CC)"	\
	CXX="$(TARGET_CXX)" \
	CPP="$(TARGET_CPP)"	\
    CXXCPP="$(TARGET_CXXCPP)"	\
	LD="$(TARGET_LD)"	\
	AR="$(TARGET_AR)"	\
	AS="$(TARGET_AS)"	\
    RANLIB="$(TARGET_RANLIB)" \
	STRIP="$(TARGET_STRIP)" \
	DLLTOOL="$(TARGET_DLLTOOL)" \
	OBJDUMP="$(TARGET_OBJDUMP)"

# $(MONO_PATH)/configure: $(MONO_PATH)/configure.ac Makefile
$(MONO_PATH)/configure: $(MONO_PATH)/configure.ac
	$(Q) ./wrap-autogen.sh $(MONO_PATH) mono ''

config-mono: $(MONO_PATH)/configure

echo-config:
	@echo ../$(MONO_PATH)/configure $(CONFIGURE_ENVIRONMENT) $(TARGET_CONFIGURE_FLAGS)

.stamp-configure-$(TARGET_DIR): $(MONO_PATH)/configure
	mkdir -p $(TARGET_DIR) &&	\
	pushd $(TARGET_DIR) && \
	../$(MONO_PATH)/configure $(CONFIGURE_ENVIRONMENT) $(TARGET_CONFIGURE_FLAGS) && \
	popd && \
	$(TOUCH) $$@

config-armv7-android: .stamp-configure-$(TARGET_DIR)

build-armv7-android: config-armv7-android

.stamp-bcl-configure: $(MONO_PATH)/configure
	./wrap-configure.sh bcl ../$(MONO_PATH)/configure --with-monodroid=yes  --with-profile4_x=no --with-mcs-docs=no --disable-btls --disable-nls &&	\
	$(TOUCH) $$@

config-bcl: .stamp-bcl-configure

build-bcl: config-bcl
	cd $(MONO_PATH) && \
	make -j4


package:
	mkdir -p $(TOP)/out
	mkdir -p $(TOP)/out/bcl
	cp armv7-android/mono/mini/.libs/libmonosgen-2.0.so $(TOP)/out
	cp $(MONO_PATH)/mcs/class/lib/monodroid/*.dll $(TOP)/out/bcl
	cp $(MONO_PATH)/mcs/class/lib/monodroid/*.pdb $(TOP)/out/bcl

setup-all: config-armv7-android

build-all: setup-all
	echo build

all: build-all


prep-repos:
	git submodule update
	(cd external/mono ; git submodule init)

.PHONY: 