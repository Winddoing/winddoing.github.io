# hid


## R

1. R/S建立socket连接（UDP）
2. 监控HID设备的事件（select）
3. 如果事件被触发，读取事件信息进行传输到S端

两个线程，子线程负责HID设备的事件监听

网络连接，可以使用不同的端口

### 读取事件数据，为什么一次读取128bit,为什么只有读取的时数据长度为64bit时发送


### 数据传输时以什么格式（mNetSession）


### M1、M3、M5等都是Wi-Fi Display技术规范
https://blog.csdn.net/innost/article/details/8474683


/dev/hidraw2   android

/dev/input/mouse1  linux



## S    

1. 添加mouse设备驱动
2. 创建子线程，a）建立socket连接；b）轮询查找uibc进行读数



### signal

```
signal(SIGPIPE, SIG_IGN);
```
https://blog.csdn.net/sukhoi27smk/article/details/43760605
实际这个函数的目的就是防止程序收到SIGPIPE后自动退出   


### select

FD_ISSET
判断描述符fd是否在给定的描述符集fdset中，通常配合select函数使用，由于select函数成功返回时会将未准备好的描述符位清零。通常我们使用FD_ISSET是为了检查在select函数返回后，某个描述符是否准备好，以便进行接下来的处理操作。


### HID驱动


S端相当于device端，模拟鼠标的输入

[usb hid gadget驱动](https://blog.csdn.net/abcamus/article/details/52980107?locationNum=5&fps=1)


ifconfig eth1 up
ifconfig eth1 192.168.1.111 netmask 255.255.255.0

tftp -gr vx_uibc 192.168.1.11 | chmod +x vx_uibc




编译kernel找不到指定的defconfig

修改Makefile

ARCH        ?= arm



/dev/hidraw
