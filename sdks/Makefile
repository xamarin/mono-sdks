TOP=$(CURDIR)/..
SDKS_PATH=$(CURDIR)
MONO_PATH=$(TOP)/external/mono
MONO_FRAMEWORK=/Library/Frameworks/Mono.framework/Versions/Current/
IS_RELEASE=true

NDK_PLATFORM_ROOT=/Users/kumpera/android-ndk-r11c
CC_NAME=clang
CXX_NAME=clang++

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


armv7-android-generated.mk aarch64-android-generated.mk: android-template.rb android.erb
	ruby android-template.rb

include armv7-android-generated.mk
include aarch64-android-generated.mk
# include aarch64-android.mk


# $(MONO_PATH)/configure: $(MONO_PATH)/configure.ac Makefile
$(MONO_PATH)/configure: $(MONO_PATH)/configure.ac
	$(Q) ./wrap-autogen.sh $(MONO_PATH) mono ''

configure-mono: $(MONO_PATH)/configure
.PHONY: configure-mono

.stamp-bcl-configure: $(MONO_PATH)/configure
	./wrap-configure.sh bcl $(MONO_PATH)/configure --with-monodroid=yes  --with-profile4_x=no --with-mcs-docs=no --disable-btls --disable-nls &&	\
	touch $@

config-bcl: .stamp-bcl-configure

build-bcl: config-bcl
	pushd bcl && \
	make -j12 && \
	popd

setup-out:
	mkdir -p $(TOP)/out
	mkdir -p $(TOP)/out/armv7-android
	mkdir -p $(TOP)/out/aarch64-android
	mkdir -p $(TOP)/out/bcl


package-bcl: setup-out
	cp $(MONO_PATH)/mcs/class/lib/monodroid/*.dll $(TOP)/out/bcl
	cp $(MONO_PATH)/mcs/class/lib/monodroid/*.pdb $(TOP)/out/bcl


package-runtimes: setup-out
	cp armv7-android/mono/mini/.libs/libmonosgen-2.0.so $(TOP)/out/armv7-android/
	cp aarch64-android/mono/mini/.libs/libmonosgen-2.0.so $(TOP)/out/aarch64-android
	cp armv7-android/support/.libs/*.so $(TOP)/out/armv7-android/
	cp aarch64-android/support/.libs/*.so $(TOP)/out/aarch64-android/

package: package-runtimes package-bcl
	@echo Packaging mono


all:
	make -C $(CURDIR) build build-bcl && \
	make -C $(CURDIR) package

prep-repos:
	git submodule update
	(cd external/mono ; git submodule init)