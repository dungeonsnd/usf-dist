# usf-dist
distrubution of  https://github.com/dungeonsnd/usf

TODO:

* 引入 log4cplus 

* 引入 lzma 

* 编译 sqlite ios/android 静态库
查ICU资源时注意到下面这篇文章，而在源码 sqlite3.c 中确实存在 ubrk_open 这些禁用 api。这就比较麻烦了，要么修改源码，看这些部分能不能去掉；要么不用 sqlite，换其它库。
http://stackoverflow.com/questions/2427838/iphone-app-rejection-for-using-icu-unicode-extensions


* 引入 websocket

* 各库 android/ios 最低运行版本统一设置

* 各库功能测试

* 等封装上层库时再完善bitcode 

* libiconv(icu) 不确定移植的必要性。而且 ICU中可能有 ubrk 之类的禁用 api.
