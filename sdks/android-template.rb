require "erb"

class AndroidTemplateVar
  attr_accessor :platform
  attr_accessor :name
  attr_accessor :dir
  attr_accessor :abi_name
  attr_accessor :toolchain_name
  attr_accessor :toolchain_arch
  attr_accessor :host_triple
  attr_accessor :ldflags
  attr_accessor :cflags
  attr_accessor :cppflags
  attr_accessor :filename

  def initialize()
    @template = File.read("android.erb")
  end
  
  def get_binding
    return binding()
  end

  def run
    res = ERB.new(@template).result(self.get_binding)
    File.write(self.filename, res)
  end
end


env = AndroidTemplateVar.new
env.platform="android-9"
env.name="android_armv7"
env.dir="armv7-android"
env.abi_name="arm-linux-androideabi"
env.toolchain_name="arm-linux-androideabi-clang"
env.toolchain_arch="arm"
env.host_triple="armv5-linux-androideabi"
env.ldflags="-Wl,--fix-cortex-a8"
env.cflags="-mtune=cortex-a8 -march=armv7-a -mfpu=vfp -mfloat-abi=softfp"
env.cppflags="-I$(#{env.name}_NDK_PLATFORM)/arch-#{env.toolchain_arch}/usr/include/"
env.filename="armv7-android-generated.mk"
env.run

env = AndroidTemplateVar.new
env.platform="android-21"
env.name="android_aarch64"
env.dir="aarch64-android"
env.abi_name="aarch64-linux-android"
env.toolchain_name="aarch64-linux-android-clang"
env.toolchain_arch="arm64"
env.host_triple="aarch64-linux-android"
env.ldflags=""
env.cflags="-DL_cuserid=9 -DANDROID64"
env.cppflags=""
env.filename="aarch64-android-generated.mk"
env.run

