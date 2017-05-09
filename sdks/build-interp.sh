#!/bin/bash


MONO_PATH=../../out/bcl/monotouch ./mono/mini/mono-sgen "--aot=mtriple=aarch64-apple-darwin10,interp,asmonly" ../../out/bcl/monotouch/mscorlib.dll/

as -arch arm64 -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.s -o /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.o
ld -dylib -arch arm64 -ios_version_min 9.0  /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.o -o  /Users/bernhardu/work/mono-sdks/out/bcl/monotouch/mscorlib.dll.so
