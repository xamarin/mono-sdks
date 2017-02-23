ANDROID_PLATFORM=android-4
NDK_PLATFORM=$(NDK_PLATFORM_ROOT)/platforms/$(ANDROID_PLATFORM)
TARGET_NAME=arm-linux-androideabi
TARGET_DIR=armv7-android
TOOLCHAIN_BIN_DIR=$(TOP)/sdks/toolchains/$(TARGET_DIR)/bin

ARM_CFLAGS=$(COMMON_CFLAGS) -D__POSIX_VISIBLE=201002 -DSK_RELEASE -DNDEBUG -UDEBUG -fpic
ARM_CXXFLAGS=$(ARM_CFLAGS)
ARM_CPP=-I$(NDK_PLATFORM)/arch-arm/usr/include/
ARM_LDFLAGS=$(COMMON_LDFLAGS) -Wl,--fix-cortex-a8 \
			-Wl,-rpath-link=$(NDK_PLATFORM)/arch-arm/usr/lib,-dynamic-linker=/system/bin/linker \
			-L$(NDK_PLATFORM)/arch-arm/usr/lib

TARGET_CONFIGURE_FLAGS= \
	--cache-file=$(SDKS_PATH)/$(TARGET_DIR).config.cache \
	--host=armv5-linux-androideabi \
	--without-ikvm-native --enable-maintainer-mode	\
	--with-profile2=no --with-profile4=no --with-profile4_5=no --with-monodroid --enable-nls=no --with-sigaltstack=yes \
	--with-tls=pthread mono_cv_uscore=yes \
	--enable-minimal=ssa,portability,attach,verifier,full_messages,sgen_remset,sgen_marksweep_par,sgen_marksweep_fixed,sgen_marksweep_fixed_par,sgen_copying,logging,security,shared_handles \
	--disable-mcs-build --disable-executables --disable-iconv \
	--enable-dynamic-btls --with-btls-android-ndk=$(NDK_PLATFORM_ROOT)


TARGET_EXTRA_CFLAGS=-mtune=cortex-a8 -march=armv7-a -mfpu=vfp -mfloat-abi=softfp
TARGET_CFLAGS=$(ARM_CFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_CXXFLAGS=$(ARM_CXXFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_LDFLAGS=$(ARM_LDFLAGS)
TARGET_CC=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CC_NAME)
TARGET_CXX=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CXX_NAME)
TARGET_CPP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(ARM_CPP)
TARGET_CXXCPP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(ARM_CPP)
TARGET_LD=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ld
TARGET_AS=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-as
TARGET_AR=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ar
TARGET_RANLIB=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ranlib
TARGET_STRIP=$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-strip
TARGET_DLLTOOL=""
TARGET_OBJDUMP="$(TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-objdump"

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

.stamp-toolchain-$(TARGET_DIR):
	$(NDK_PLATFORM_ROOT)/build/tools/make-standalone-toolchain.sh  --platform=$(ANDROID_PLATFORM) --arch=arm --install-dir=toolchains/$(TARGET_DIR) --toolchain=arm-linux-androideabi-clang && \
	touch .stamp-toolchain-$(TARGET_DIR)

setup-toolchain-$(TARGET_DIR): .stamp-toolchain-$(TARGET_DIR)
.PHONY: setup-toolchain-$(TARGET_DIR)

setup-toolchain:: .stamp-toolchain-$(TARGET_DIR)



.stamp-configure-$(TARGET_DIR): $(MONO_PATH)/configure .stamp-toolchain-arm
	mkdir -p $(TARGET_DIR) &&	\
	pushd $(TARGET_DIR) && \
	$(MONO_PATH)/configure $(CONFIGURE_ENVIRONMENT) $(TARGET_CONFIGURE_FLAGS) && \
	popd && \
	$(TOUCH) $$@

configure-$(TARGET_DIR): .stamp-configure-$(TARGET_DIR)
.PHONY: configure-$(TARGET_DIR)

configure:: configure-$(TARGET_DIR)

build-$(TARGET_DIR): configure-$(TARGET_DIR)
	pushd $(TARGET_DIR) && \
	make -j 12 && \
	popd
.PHONY: build-$(TARGET_DIR)

build:: build-$(TARGET_DIR)
