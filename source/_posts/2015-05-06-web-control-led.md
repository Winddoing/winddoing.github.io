---
date: 2015-05-06 07:49
layout: post
title: mini2440基于boa服务器通过WEB控制GPIO
thread: 166
categories: 系统应用
tags: [S3C2440, Boa, Web]
---

本文是基于BOA服务器，通过CGI（通用网管接口）控制开发板的GPIO。CGI通用网关接口是一个Web服务器主机提供信息服务的标准接口。通过CGI接口，Web服务器就能够获取客户端提交的信息，转交给服务器端的CGI程序进行处理，最后返回结果给客户端。

在这里以控制LED为例。

![led控制图](/images/boa-led.png)
<!---more--->

### 1.客户端控制界面
采用CGI将浏览器端的控制信息传到boa服务器端,index.html文件

        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />    
        <title>web控制mini2440开发板led</title>
        </head>
        <body>
        <h1 align="center">基于mini2440的web控制GPIO口</h1>
        <form action="/cgi-bin/cgi_led.cgi" method="get">   
        <p align="center">led的测试工作</p>
        <p align="center">请输入需要控制的led <input type="text" name="led_control"/></p>
        <p align="center">请输入控制led的动作 <input type="text" name="led_state"/></p>
        <p align="center"><input type="submit" value="sure"/>        
        <input type="reset" value="back"/>
        </p>
        </form>
        </body>
        </html>
![web截图](/images/boa-led-web.png)

### 2.服务器端数据处理
通过客户端浏览器的from表单将，控制信息提交到服务器，服务器获取数据并通过有名管道将控制数据传给调用LED驱动的控制程序。

``` C
        #include <stdio.h>
        #include <stdlib.h>
        #include <sys/types.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <sys/stat.h>
        #include <sys/mman.h>
        #include <limits.h>
        #include <string.h>
        #define MYFIFO "/www/myfifo"
        #define MAX_BUFFER_SIZE PIPE_BUF

        int main()
        {
            char* data;   //定义一个指针用于指向QUERY_STRING存放的内容
            char buff[MAX_BUFFER_SIZE];
            int fd, nwrite;
            int led_control, led_state;

            printf("Content-type: text/html\n\n");
            printf("<html>\n");
            printf("<head><title>cgi led demo</title></head>\n");
            printf("<body>\n");
            printf("<p>led is setted successful! you can watch the led's change</p>\n");
            printf("<p><a herf=index.html><button>get back</button></a></p>\n");
            printf("</body>\n");

            data = getenv("QUERY_STRING");   //getenv()读取环境变量的当前值的函数
            strcpy(buff, data);
            fd = open(MYFIFO, O_WRONLY);
            if(-1 == fd)
            {
                printf("Open fifo file error\n");
                exit(1);
            }
            if((nwrite = write(fd, buff, sizeof(buff))) < 0)
            {
                printf("\nWrite data error\n");
                exit(1);
            }

            if(sscanf(buff,"led_control=%d&led_state=%d",&led_control,&led_state)!=2)
            {   //利用sscnaf（）函数的特点将环境变量分别提取出led_control和led_state这两个值
                printf("<p>please input right");
                printf("</p>");
            }
            printf("<p>led_control = %d,led_state =  %d</p>", led_control, led_state);
            if(led_control>3)
            {
                printf("<p>Please input 0<=led_control<=3!");
                printf("</p>");
            }
            if(led_state>1)
            {
                printf("<p>Please input 0<=led_state<=1!");
                printf("</p>");
            }
            close(fd);
            printf("</html>\n");

            return 0;
        }
```
### 3.控制端（GPIO驱动调用）
通过管道接受到控制数据，调用驱动程序实现对LED灯的控制

``` C
        #include <stdio.h>
        #include <stdlib.h>
        #include <sys/types.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <sys/ioctl.h>
        #include <sys/stat.h>
        #include <sys/mman.h>
        #include <errno.h>
        #include <limits.h>
        #include <string.h>

        #include <linux/micro2440_leds.h>

        #define MYFIFO "/www/myfifo"
        #define LEDS_DEVICE  "/dev/led4s"
        #define MAX_BUFFER_SIZE PIPE_BUF

        int main(int argc, char* argv[])
        {
            int led_fd, fifo_fd, led_control,led_state, nread;
            struct leds_stat oneStat;
            char buff[MAX_BUFFER_SIZE];  //定义一个指针用于指向QUERY_STRING存放的内容
            led_fd = open(LEDS_DEVICE, O_RDWR);  //打开led设备
            if(-1 == led_fd)
            {
                perror("open led device");
                exit(1);
            }
            if(-1 == access(MYFIFO, F_OK))
            {
                if((mkfifo(MYFIFO, 0666) < 0) && (errno != EEXIST))
                {
                    printf("Connot create fifo file\n");
                    exit(1);
                }
            }
            fifo_fd = open(MYFIFO, O_RDONLY);
            if(-1 == fifo_fd)
            {
                perror("open fifo file error\n");
                exit(1);
            }

            while(1)
            {
                //memset(buff, 0, sizeof(buff));使用会使控制数据出错
                if((nread = read(fifo_fd, buff, sizeof(buff))) < 0)
                {
                    perror("Read data error");
                    exit(1);
                }
                if(sscanf(buff,"led_control=%d&led_state=%d",&led_control,&led_state)!=2)
                {   //利用sscnaf（）函数的特点将环境变量分别提取出led_control和led_state这两个值
                    printf("please input right \n");
                    exit(1);
                }
                if(led_control>3)
                {
                    printf("Please input 0<=led_control<=3!");
                    exit(1);
                }
                if(led_state>1)
                {
                    printf("Please input 0<=led_state<=1!");
                    exit(1);
                }
                oneStat.led_nr = led_control;
                oneStat.led_st = led_state;
                ioctl(led_fd, LEDS_SET_ONE, &oneStat);
            }
            close(led_fd);
            close(fifo_fd);

            return 0;
        }
```
### 4.总结
本文主要参考<http://blog.csdn.net/rwzhou1/article/details/23381811>，采用管道的方式将数据的获取与功能的实现分离，更有利于对GPIO的控制。由于对LED驱动自己编写的跟上文中的有所不同，只有通过管道的方式实现。

在使用GET获取环境变量时，只能将getenv("QUERY_STRING");赋予字符指针，不能使用使用字符数组。

在使用管道的时候，由于管道数据传输为半双通因此在管道的两端只能赋予某一种权限，如读端以只读权限打开，写端以只写权限打开。如果某一端以读写权限打开程序将一直阻塞数据无法传输（刚开始习惯性的当做文件，直接以读写权限打开出错）。

控制端从管道读取数据时，将数据保存到字符数组中。在读取之前不能使用memset(buff, 0, sizeof(buff));函数将数组清零，如果数组清零接受到的数据与发送的数据信息相同，但大小不同会在数据解析的时候会出错，无法实现控制。
