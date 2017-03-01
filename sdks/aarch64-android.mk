TARGET_ANDROID_PLATFORM=android-21
TARGET_NDK_PLATFORM=$(NDK_PLATFORM_ROOT)/platforms/$(TARGET_ANDROID_PLATFORM)
TARGET_NAME=aarch64-linux-android
TARGET_DIR=aarch64-android
TARGET_TOOLCHAIN_BIN_DIR=$(TOP)/sdks/toolchains/$(TARGET_DIR)/bin
TARGET_NDK_TOOLCHAIN_NAME=aarch64-linux-android-clang
TARGET_NDK_TOOLCHAIN_ARCH=arm64

TARGET_CONFIGURE_FLAGS= \
	--cache-file=$(SDKS_PATH)/$(TARGET_DIR).config.cache \
	--host=aarch64-linux-android \
	--without-ikvm-native --enable-maintainer-mode	\
	--with-profile2=no --with-profile4=no --with-profile4_5=no --with-monodroid --enable-nls=no --with-sigaltstack=yes \
	--with-tls=pthread mono_cv_uscore=yes \
	--enable-minimal=ssa,portability,attach,verifier,full_messages,sgen_remset,sgen_marksweep_par,sgen_marksweep_fixed,sgen_marksweep_fixed_par,sgen_copying,logging,security,shared_handles \
	--disable-mcs-build --disable-executables --disable-iconv \
	--enable-dynamic-btls --with-btls-android-ndk=$(NDK_PLATFORM_ROOT)

TARGET_LDFLAGS=$(COMMON_LDFLAGS) \
			-Wl,-rpath-link=$(TARGET_NDK_PLATFORM)/arch-arm64/usr/lib,-dynamic-linker=/system/bin/linker \
			-L$(TARGET_NDK_PLATFORM)/arch-arm64/usr/lib

TARGET_EXTRA_CFLAGS=-DL_cuserid=9 -DANDROID64
TARGET_EXTRA_CPPFLAGS=


TARGET_CFLAGS=$(ARM_CFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_CXXFLAGS=$(ARM_CXXFLAGS) $(TARGET_EXTRA_CFLAGS) $(SECURITY_CFLAGS) -DMONODROID=1
TARGET_CC=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CC_NAME)
TARGET_CXX=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-$(CXX_NAME)
TARGET_CPP=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(TARGET_EXTRA_CPPFLAGS)
TARGET_CXXCPP=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-cpp $(TARGET_EXTRA_CPPFLAGS)
TARGET_LD=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ld
TARGET_AS=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-as
TARGET_AR=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ar
TARGET_RANLIB=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-ranlib
TARGET_STRIP=$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-strip
TARGET_DLLTOOL=""
TARGET_OBJDUMP="$(TARGET_TOOLCHAIN_BIN_DIR)/$(TARGET_NAME)-objdump"

TARGET_CONFIGURE_ENVIRONMENT = \
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
	$(NDK_PLATFORM_ROOT)/build/tools/make-standalone-toolchain.sh  --platform=$(TARGET_ANDROID_PLATFORM) --arch=$(TARGET_NDK_TOOLCHAIN_ARCH) --install-dir=toolchains/$(TARGET_DIR) --toolchain=$(TARGET_NDK_TOOLCHAIN_NAME) && \
	touch .stamp-toolchain-$(TARGET_DIR)

setup-toolchain-$(TARGET_DIR): .stamp-toolchain-$(TARGET_DIR)
.PHONY: setup-toolchain-$(TARGET_DIR)

setup-toolchain:: .stamp-toolchain-$(TARGET_DIR)

.stamp-configure-$(TARGET_DIR): $(MONO_PATH)/configure .stamp-toolchain-$(TARGET_DIR)
	mkdir -p $(TARGET_DIR) &&	\
	pushd $(TARGET_DIR) && \
	$(MONO_PATH)/configure $(TARGET_CONFIGURE_ENVIRONMENT) $(TARGET_CONFIGURE_FLAGS) && \
	popd && \
	touch .stamp-configure-$(TARGET_DIR)

configure-$(TARGET_DIR): .stamp-configure-$(TARGET_DIR)
.PHONY: configure-$(TARGET_DIR)

configure:: configure-$(TARGET_DIR)

build-$(TARGET_DIR): configure-$(TARGET_DIR)
	pushd $(TARGET_DIR) && \
	make -j 12 && \
	popd
.PHONY: build-$(TARGET_DIR)

build:: build-$(TARGET_DIR)
