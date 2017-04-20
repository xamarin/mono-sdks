TOP=$(CURDIR)/..
include $(TOP)/paths.mk
SDKS_PATH=$(CURDIR)

XCODE_DEVELOPER_ROOT=/Applications/Xcode.app/Contents/Developer
PLATFORM_BIN=$(XCODE_DEVELOPER_ROOT)/Toolchains/XcodeDefault.xctoolchain/usr/bin

IPHONEOS_VERSION=iPhoneOS10.2.sdk

CONFIGURE_FLAGS_I_DONT_CARE= --enable-llvm-runtime --with-bitcode=yes --enable-extension-module=xamarin
#BITCODE_MARKER=-fembed-bitcode-marker

AC_VARS=mono_cv_uscore=yes mono_cv_sizeof_sunpath=104 ac_cv_func_posix_getpwuid_r=yes ac_cv_func_finite=no ac_cv_c_bigendian=no ac_cv_header_sys_user_h=no ac_cv_header_curses_h=no ac_cv_header_localcharset_h=no ac_cv_func_getpwuid_r=no

TARGET_CPPFLAGS=-DSMALL_CONFIG -DDISABLE_POLICY_EVIDENCE=1 -DDISABLE_PROCESS_HANDLING=1 -D_XOPEN_SOURCE -DMONOTOUCH=1 -DHOST_IOS -DHAVE_LARGE_FILE_SUPPORT=1 -Wl,-application_extension -miphoneos-version-min=9.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneOS.platform/Developer/SDKs/$(IPHONEOS_VERSION) -arch armv7

TARGET_CFLAGS=-O2 -gdwarf-2 -DSMALL_CONFIG -DDISABLE_POLICY_EVIDENCE=1 -DDISABLE_PROCESS_HANDLING=1 -D_XOPEN_SOURCE -DMONOTOUCH=1 -DHOST_IOS -DHAVE_LARGE_FILE_SUPPORT=1 -Wl,-application_extension -miphoneos-version-min=9.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneOS.platform/Developer/SDKs/$(IPHONEOS_VERSION) -O0 -fexceptions $(BITCODE_MARKER)

TARGET_CXXFLAGS=-DSMALL_CONFIG -DDISABLE_POLICY_EVIDENCE=1 -DDISABLE_PROCESS_HANDLING=1 -D_XOPEN_SOURCE -DMONOTOUCH=1 -DHOST_IOS -DHAVE_LARGE_FILE_SUPPORT=1 -Wl,-application_extension -miphoneos-version-min=9.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneOS.platform/Developer/SDKs/$(IPHONEOS_VERSION) -arch armv7 -fexceptions $(BITCODE_MARKER)

TARGET_LDFLAGS=-arch armv7 -framework CoreFoundation -lobjc -lc++ -Wl,-no_weak_imports

TARGET_CC=$(CCACHE)$(PLATFORM_BIN)/clang
TARGET_CXX=$(CCACHE)$(PLATFORM_BIN)/clang++

CONFIGURE_ENVIRONMENT =	\
	CC="$(TARGET_CC)"	\
	CXX="$(TARGET_CXX)"	\
	CFLAGS="$(TARGET_CFLAGS)"	\
	CPPFLAGS="$(TARGET_CPPFLAGS)"	\
	CXXFLAGS="$(TARGET_CXXFLAGS)"	\
	LDFLAGS="$(TARGET_LDFLAGS)"


CONFIGURE_INSTALL_FLAGS = --cache-file=$(SDKS_PATH)/ios-armv7.config.cache --prefix=$(SDKS_PATH)/install/ios-target7

CONFIGURE_FLAGS = \
	--build=i386-apple-darwin10 \
	--host=arm-apple-darwin10 \
	--disable-boehm \
	--enable-maintainer-mode \
	$(CONFIGURE_INSTALL_FLAGS) \
	--with-monotouch \
	--with-lazy-gc-thread-creation=yes \
	--disable-mcs-build \
	--enable-minimal=ssa,com,jit,reflection_emit_save,reflection_emit,portability,assembly_remapping,attach,verifier,full_messages,appdomains,security,sgen_remset,sgen_marksweep_par,sgen_marksweep_fixed,sgen_marksweep_fixed_par,sgen_copying,logging,remoting,shared_perfcounters \
	--without-ikvm-native \
	--with-tls=pthread \
	--without-sigaltstack \
	--enable-icall-export \
	--disable-icall-tables \
	--disable-executables \
	--disable-nls \
	--disable-iconv \
	--disable-visibility-hidden \
	--disable-boehm \
	--enable-dtrace=no \
	--disable-btls

.stamp-configure-ios-armv7: $(MONO_SOURCE_PATH)/configure
	mkdir -p ios-armv7 &&	\
	pushd ios-armv7 && \
	PATH="$(PLATFORM_BIN):$$PATH" $(MONO_SOURCE_PATH)/configure $(AC_VARS) $(CONFIGURE_ENVIRONMENT) $(CONFIGURE_FLAGS) && \
	popd && \
	touch .stamp-configure-ios-armv7

configure:: .stamp-configure-ios-armv7



SIM32_PLATFORM=iPhoneSimulator.platform
IPHONESIM_VERSION=iPhoneSimulator10.2.sdk

SIM32_CPPFLAGS=-arch i386 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM32_CFLAGS=-arch i386 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM32_CXXFLAGS=-arch i386 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM32_LDFLAGS="-Wl,-no_weak_imports"

SIM32_CC=$(CCACHE)$(PLATFORM_BIN)/clang
SIM32_CXX=$(CCACHE)$(PLATFORM_BIN)/clang++

SIM32_CONFIGURE_INSTALL_FLAGS= --cache-file=$(SDKS_PATH)/ios-sim32.config.cache --prefix=$(SDKS_PATH)/install/ios-sim32

SIM_CONFIGURE_FLAGS_I_DONT_CARE= --enable-extension-module=xamarin
SIM32_CONFIGURE_FLAGS= \
	--host=i386-apple-darwin10 \
	$(SIM32_CONFIGURE_INSTALL_FLAGS) \
	--enable-maintainer-mode \
	--with-glib=embedded \
	--without-ikvm-native \
	--with-tls=pthread \
	--enable-minimal=com,remoting,shared_perfcounters \
	--disable-mcs-build \
	--disable-nls \
	--disable-iconv \
	--disable-boehm \
	--disable-executables \
	--disable-visibility-hidden \
	--disable-btls

SIM32_AC_VARS=ac_cv_func_fstatat=no ac_cv_func_readlinkat=no  ac_cv_func_clock_nanosleep=no mono_cv_uscore=yes 

SIM32_CONFIGURE_ENVIRONMENT =	\
	CC="$(SIM32_CC)"	\
	CXX="$(SIM32_CXX)"	\
	CFLAGS="$(SIM32_CFLAGS)"	\
	CPPFLAGS="$(SIM32_CPPFLAGS)"	\
	CXXFLAGS="$(SIM32_CXXFLAGS)"	\
	LDFLAGS="$(SIM32_LDFLAGS)"

.stamp-configure-ios-sim32: $(MONO_SOURCE_PATH)/configure
	mkdir -p ios-sim32 &&	\
	pushd ios-sim32 && \
	PATH="$(PLATFORM_BIN):$$PATH" $(MONO_SOURCE_PATH)/configure $(SIM32_AC_VARS) $(SIM32_CONFIGURE_ENVIRONMENT) $(SIM32_CONFIGURE_FLAGS) && \
	popd && \
	touch .stamp-configure-ios-sim32

configure-sim32: .stamp-configure-ios-sim32
configure:: .stamp-configure-ios-sim32



SIM64_PLATFORM=iPhoneSimulator.platform

SIM64_CPPFLAGS=-arch x86_64 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM64_CFLAGS=-arch x86_64 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM64_CXXFLAGS=-arch x86_64 -O2 -DMONOTOUCH -DHOST_IOS -Wl,-application_extension -mios-simulator-version-min=6.0 -isysroot $(XCODE_DEVELOPER_ROOT)/Platforms/iPhoneSimulator.platform/Developer/SDKs/$(IPHONESIM_VERSION)

SIM64_LDFLAGS="-Wl,-no_weak_imports"

SIM64_CC=$(CCACHE)$(PLATFORM_BIN)/clang
SIM64_CXX=$(CCACHE)$(PLATFORM_BIN)/clang++

SIM64_CONFIGURE_INSTALL_FLAGS= --cache-file=$(SDKS_PATH)/ios-sim64.config.cache --prefix=$(SDKS_PATH)/install/ios-sim64

SIM_CONFIGURE_FLAGS_I_DONT_CARE= --enable-extension-module=xamarin
SIM64_CONFIGURE_FLAGS= \
	--host=x86_64-apple-darwin10 \
	$(SIM64_CONFIGURE_INSTALL_FLAGS) \
	--enable-maintainer-mode \
	--with-glib=embedded \
	--without-ikvm-native \
	--with-tls=pthread \
	--enable-minimal=com,remoting,shared_perfcounters \
	--disable-mcs-build \
	--disable-nls \
	--disable-iconv \
	--disable-boehm \
	--disable-executables \
	--disable-visibility-hidden \
	--disable-btls

SIM64_AC_VARS=ac_cv_func_fstatat=no ac_cv_func_readlinkat=no  ac_cv_func_clock_nanosleep=no mono_cv_uscore=yes 

SIM64_CONFIGURE_ENVIRONMENT =	\
	CC="$(SIM64_CC)"	\
	CXX="$(SIM64_CXX)"	\
	CFLAGS="$(SIM64_CFLAGS)"	\
	CPPFLAGS="$(SIM64_CPPFLAGS)"	\
	CXXFLAGS="$(SIM64_CXXFLAGS)"	\
	LDFLAGS="$(SIM64_LDFLAGS)"

.stamp-configure-ios-sim64: $(MONO_SOURCE_PATH)/configure
	mkdir -p ios-sim64 &&	\
	pushd ios-sim64 && \
	PATH="$(PLATFORM_BIN):$$PATH" $(MONO_SOURCE_PATH)/configure $(SIM64_AC_VARS) $(SIM64_CONFIGURE_ENVIRONMENT) $(SIM64_CONFIGURE_FLAGS) && \
	popd && \
	touch .stamp-configure-ios-sim64

configure-sim64: .stamp-configure-ios-sim64
configure:: .stamp-configure-ios-sim64

