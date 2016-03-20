# usf-dist
distrubution of  https://github.com/dungeonsnd/usf

TODO:

* 引入 lzma 

* 引入 日志库 
常见的需求是按模块、按天、按日志量分文件。 对于移动端更是如此，可能只拉取某一天的日志。

所以log4cplus不一定适合。待选方案是zf_log，也有可能需要写一个简单的满足常见需求的轻量日志库。


* 引入 websocket

* 各库功能测试

* libiconv(icu) 不确定移植的必要性。而且 ICU中可能有 ubrk 之类的禁用 api.


进展:

* sqlite for ios 的主要功能已经在ios真机和模拟器上测试通过。
* curl for ios 的GET请求功能已经在ios真机和模拟器上测试通过。
* libevent for ios 用域名及ip连接服务器、收发数据功能已经在ios真机和模拟器上测试通过。
* rapidJson for ios 的主要功能已经在ios真机和模拟器上测试通过。
* openssl for ios 的aes/base64/md5/sha 已经在ios真机和模拟器上测试通过, rsa等未测。
* rapidJson for ios 的主要功能已经在ios真机和模拟器上测试通过。
* protobuf for ios 的序列化/反序列化已经在ios真机和模拟器上测试通过。

* 准备把 ios 版本的 sqlite,curl,libevent,openssl,rapidjson,protobuf,log4cplus  添加到某应用上，然后提交审核，检查苹果对于这些库的通过和拒绝情况。


备注:

* 各库 android/ios 最低运行版本统一设置为6.0，并启动 bitcode 进行编译。

* sqlite for ios

关于 ios 版静态库的一点问题：
查ICU资源时注意到下面这篇文章，而在源码 sqlite3.c 中确实存在 ubrk_open 这些禁用 api。这就比较麻烦了，要么修改源码，看这些部分能不能去掉；要么不用 sqlite，换其它库。

http://stackoverflow.com/questions/2427838/iphone-app-rejection-for-using-icu-unicode-extensions

但是另一资料显示好像用了icu不会被拒， 所以可以尝试一下，不行在编译sqlite时研究 SQLITE_ENABLE_ICU 来禁用icu.

http://raywenderlich.com/forums/viewtopic.php?f=2&t=89
"I use SQLite + ICU since over a year in our company apps. I never got any rejection because of SQLIte or ICU - and we upload apps based on our whitelabel 1-2 times a week. "


