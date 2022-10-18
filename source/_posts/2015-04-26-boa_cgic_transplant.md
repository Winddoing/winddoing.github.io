---
date: '2015-04-26 01:49'
layout: post
title: boa服务器的配置与cgic移植
thread: 166
categories:
  - 系统应用
tags:
  - boa
  - cgic
abbrlink: 54877
---

上次在开发板上成功移植完boa服务器，最近使用C语言进行CGI编程，只在宿主机上搭建CGI的测试环境。

### BOA服务器的配置：

>Port：boa服务器监听的端口，默认的端口是80。如果端口小于1024，则必须是  root用户启动服务器。

>Listen：绑定的ip地址。不使用这个参数时，将绑定所有的地址。

>**User**：连接到服务器的客户端的身份，可以是用户名或UID。

>**Group**：连接到服务器的客户端的组，可以是组名或GID。

>ServerAdmin：服务器出故障时要通知的邮箱地址。
<!---more--->

>ErrorLog：指定错误日志文件。如果路径没有以"/"开始，则相对于ServerRoot路径。没有配置时默 认的文件是/dev/stderr。若不想记录日志，指定文件为/dev/null。

>**AccessLog**：设置存取日志文件，与ErrorLog类似。

>UseLocaltime：设置使用本地时间，使用UTC时注释这个参数。这个参数没有值。

>VerboseCGILogs：在错误日志文件中记录CGI启动和停止时间，若不记录，注释这个参数。这个参数没有值。

>ServerName：指定服务器的名称，当客户端使用gethostname + gethostbyname时返回给客户端。

>VirtualHost：虚拟主机开关。使用此参数，则会在DocumentRoot设定的目录添加一个ip地址作为新的DocumentRoot来处理客户端的请求。如DocumentRoot设置为/var/www，则http://localhost/转换 成/var/www/127.0.0.1/，若注释此参数，则为/var/www/。

>**DocumentRoot**：HTML文件的根目录（也就是网站的目录,使用yum安装的话，为/var/www/boa/html）。

>DirectoryIndex：网站访问的第一个网页，默认是index.html（如果使用yum安装的话，地址为：/var/www/boa/html/index.html ）

>UserDir：指定用户目录。

>DirectoryIndex：指定预生成目录信息的文件，注释此变量将使用DirectoryMaker变量。这个变量也就是设置默认主页的文件名。

>DirectoryMaker：指定用于生成目录的程序，注释此变量将不允许列目录。

>DirectoryCache：当DirectoryIndex文件不存在，而DirecotryMaker又被注释掉时，将列出这个参数指定目录给客户端。

>KeepAliveMax：每个连接允许的请求数量。如果将此值设为" 0 "，将不限制请求的数目。

>KeepAliveTimeOut：在关闭持久连接前等待下一个请求的秒数。（秒）。

>MimeTypes：设置包含mimetypes信息的文件，一般是/etc/mime.types。

>DefaultType：默认的mimetype类型，一般是text/html。

>CGIPath：相当于给CGI程序使用的$PATH变量。

>SinglePostLimit：一次POST允许最大的字节数，默认是1MB。

>AddType: 增加MimeType没有指定的类型，例: AddType type extension [extension ...]。要使用cgi，必须添加cgi类型：AddType application/x-httpd-cgi cgi

>Redirect：重定向文件。

>Aliases：指定路径的别名。

>***ScriptAlias***：指定脚本路径的虚拟路径。


移植boa配置文件只修改强调的部分，具体修改方法参考转载的上文。


## 移植CGIC库
### 1.[下载](/src/cgic205.tar.gz)cgic库源码

### 2.解压
        #tar zxvf cgic205.tar.gz
### 3.修改Markfile
#### 编译器
##### ARM开发板移植
        CC=arm-linux-gcc
        AR=arm-linux-ar
        RANLIB=arm-linux-ranlib
##### 宿主机测试
        CC=gcc
        AR=ar
        RANLIB=ranlib
#### markfile部分
        gcc cgictest.o -o cgictest.cgi ${LIBS}
修改为：

        $(CC) $(CFLAGS) cgictest.o -o cgictest.cgi ${LIBS}

        gcc capture.o -o capture ${LIBS}
修改为：

        $(CC) $(CFLAGS) capture.o -o capture ${LIBS}
宿主机测试只是为了练习CGI编写。

## 遇到的错误
### 1.在宿主机上测试安装CGIC时，修改了Markfile的编译器CC选项为arm-linux-gcc
>出现502错误：The CGI was not CGI/1.1 compliant.

整了我好长时间
主要还是不细心，同时在遇到问题解决问题的时候不应该盲目，为了解决错误而去找答案
应该先捋一捋自己做事的过程，看看有没有出差。
