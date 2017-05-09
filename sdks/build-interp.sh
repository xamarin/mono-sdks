#!/bin/bash


MONO_PATH=../../out/bcl/monotouch ./mono/mini/mono-sgen "--aot=mtriple=aarch64-apple-darwin10,interp,asmonly,static" ../../out/bcl/monotouch/mscorlib.dll/

as -arch arm64 -miphoneos-version-min=8.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.s -o /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.o
ld -dylib -arch arm64 -ios_version_min 8.0  /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.o -o  /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.so


install_name_tool -id '@rpath/libMonoPosixHelper.dylib' libMonoPosixHelper.dylib

# verify with
otool -L libMonoPosixHelper.dylib
