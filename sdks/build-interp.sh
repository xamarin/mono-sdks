#!/bin/bash

make -C sdks -f ios.mk configure-ios-cross32
make -C sdks -f ios.mk ios-cross32/arm-apple-darwin10.h

make -C sdks -f ios.mk configure-ios-cross64
make -C sdks -f ios.mk ios-cross64/aarch64-apple-darwin10.h

make -C sdks -f ios.mk configure-sim32
make -C sdks -f ios.mk configure-sim64

make -C sdks/ios-cross64 -j8
make -C sdks/ios-arm64 -j8

make -C sdks/ios-cross32 -j8
make -C sdks/ios-armv7 -j8

make -C sdks/ios-sim32 -j8
make -C sdks/ios-sim64 -j8


# Build for arm64
cd sdks/ios-cross64

# dirty boy: use mscorlib.dll from desktop profile;  monotouch disables reflection_emit in BCL profile.
MONO_PATH=$minecraftpe/handheld/lib/mono/lib_shared  ./mono/mini/mono-sgen "--aot=mtriple=aarch64-apple-darwin10,interp,asmonly,static" $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll

as -arch arm64 -miphoneos-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -o $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll.{o,s}

cd -

cd sdks/ios-arm64
cp mono/mini/.libs/libmonosgen-2.0.a $minecraftpe/handheld/lib/mono/lib_ios/arm64
cp support/.libs/libMonoPosixHelper.a $minecraftpe/handheld/lib/mono/lib_ios/arm64

cp support/.libs/libMonoPosixHelper.dylib $minecraftpe/handheld/lib/mono/lib_ios/arm64
install_name_tool -id '@executable_path/Frameworks/libMonoPosixHelper.dylib' $minecraftpe/handheld/lib/mono/lib_ios/arm64/libMonoPosixHelper.dylib
otool -L $minecraftpe/handheld/lib/mono/lib_ios/arm64/libMonoPosixHelper.dylib

cd -


# Build for armv7
cd sdks/ios-cross32

# dirty boy: use mscorlib.dll from desktop profile;  monotouch disables reflection_emit in BCL profile.
MONO_PATH=$minecraftpe/handheld/lib/mono/lib_shared  ./mono/mini/mono-sgen "--aot=mtriple=arm-apple-darwin10,interp,asmonly,static" $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll

as -arch armv7 -miphoneos-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -o $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll.{o,s}

cd -

cd sdks/ios-armv7
cp mono/mini/.libs/libmonosgen-2.0.a $minecraftpe/handheld/lib/mono/lib_ios/armv7
cp support/.libs/libMonoPosixHelper.a $minecraftpe/handheld/lib/mono/lib_ios/armv7

cp support/.libs/libMonoPosixHelper.dylib $minecraftpe/handheld/lib/mono/lib_ios/armv7
install_name_tool -id '@executable_path/Frameworks/libMonoPosixHelper.dylib' $minecraftpe/handheld/lib/mono/lib_ios/armv7/libMonoPosixHelper.dylib
otool -L $minecraftpe/handheld/lib/mono/lib_ios/armv7/libMonoPosixHelper.dylib

cd -




# build for x86_64 (simulator)
cd sdks/ios-sim64
cp mono/mini/.libs/libmonosgen-2.0.a $minecraftpe/handheld/lib/mono/lib_ios/x86_64
cp support/.libs/libMonoPosixHelper.a $minecraftpe/handheld/lib/mono/lib_ios/x86_64

cp support/.libs/libMonoPosixHelper.dylib $minecraftpe/handheld/lib/mono/lib_ios/x86_64
install_name_tool -id '@executable_path/Frameworks/libMonoPosixHelper.dylib' $minecraftpe/handheld/lib/mono/lib_ios/x86_64/libMonoPosixHelper.dylib
otool -L $minecraftpe/handheld/lib/mono/lib_ios/x86_64/libMonoPosixHelper.dylib
cd -

# build for i386 (simulator)
cd sdks/ios-sim32
cp mono/mini/.libs/libmonosgen-2.0.a $minecraftpe/handheld/lib/mono/lib_ios/i386
cp support/.libs/libMonoPosixHelper.a $minecraftpe/handheld/lib/mono/lib_ios/i386

cp support/.libs/libMonoPosixHelper.dylib $minecraftpe/handheld/lib/mono/lib_ios/i386
install_name_tool -id '@executable_path/Frameworks/libMonoPosixHelper.dylib' $minecraftpe/handheld/lib/mono/lib_ios/i386/libMonoPosixHelper.dylib
otool -L $minecraftpe/handheld/lib/mono/lib_ios/i386/libMonoPosixHelper.dylib
