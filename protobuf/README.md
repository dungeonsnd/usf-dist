ios:

参考了 

https://gist.github.com/BennettSmith/9487468ae3375d0db0cc

编译成功。 但是不支持 bitcode，也不能直接在 configure 参数中增加 -fembed-bitcode，加了编译时不是提示错误。

于是在上面的BennettSmith的页面下面评论中找到了这个文章

https://gist.github.com/ksc91u/bef7e2482018a5d363b8#file-build-protobuf-sh

文章中有个注释是这个链接

 http://stackoverflow.com/questions/32622284/building-c-static-libraries-using-configure-make-with-fembed-bitcode-fails

其中说明了为什么增加 -fembed-bitcode 却还是没有成功启用bitcode的原因。解决方案如下，

The solution is simply do this before building the library for iOS devices with -fembed-bitcode:

export MACOSX_DEPLOYMENT_TARGET="10.4"

使用上面 ksc91u 的链接中的脚本编译通过，经测试成功启动了bitcode。稍加了修改。


注意， 编译 xcode 项目时需要在 include/google/protobuf/descriptor.h 增加 #undef TYPE_BOOL

因为  protobuf 源码中的 TYPE_BOOL 枚举名称在mac osx中被定义成了一个宏。悲剧！



另外，使用已有的脚本编译失败了，下面这个脚本也编译失败了，

https://github.com/dinote/protobuf-mobile-build


-----------------------------------------------------
android:

使用下面的方法在mac上一次编译通过，期间要安装一下protobuf,即  brew install protobuf，要不然提示没有找到 protoc程序，
http://hadesmo.com/2015/09/13/ndk-toolchain-protobuf.html

编译成功。 
暂时未测试。
