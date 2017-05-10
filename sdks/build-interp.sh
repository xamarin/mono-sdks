#!/bin/bash

make -C sdks -f ios.mk configure-ios-cross64 && make -C sdks -f ios.mk ios-cross64/aarch64-apple-darwin10.h

make -C sdks/ios-cross64 -j8
make -C sdks/ios-arm64 -j8


cd sdks/ios-cross64

# dirty boy: use mscorlib.dll from desktop profile;  monotouch disables reflection_emit in BCL profile.
MONO_PATH=$minecraftpe/handheld/lib/mono/lib_shared  ./mono/mini/mono-sgen "--aot=mtriple=aarch64-apple-darwin10,interp,asmonly,static" $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll

as -arch arm64 -miphoneos-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -o $minecraftpe/handheld/lib/mono/lib_shared/mscorlib.dll.{o,s}

cd -

cd sdks/ios-arm64
cp mono/mini/.libs/libmonosgen-2.0.a $minecraftpe/handheld/lib/mono/lib_ios/aarch64
cp support/.libs/libMonoPosixHelper.a $minecraftpe/handheld/lib/mono/lib_ios/aarch64

cp support/.libs/libMonoPosixHelper.dylib $minecraftpe/handheld/lib/mono/lib_ios/aarch64
install_name_tool -id '@executable_path/Frameworks/libMonoPosixHelper.dylib' $minecraftpe/handheld/lib/mono/lib_ios/aarch64/libMonoPosixHelper.dylib
otool -L $minecraftpe/handheld/lib/mono/lib_ios/aarch64/libMonoPosixHelper.dylib
