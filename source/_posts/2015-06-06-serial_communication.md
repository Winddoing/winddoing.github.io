---
date: 2015-06-06 19:41
layout: post
title: Micro2440数据传输--串口通信
thread: 166
categories: 嵌入式
tags: [数据传输, 串口]
---

这段时间经过这次对比赛的准备，使用到了串口通信。或许这是最简单的通信方式吧，想弄清楚简单的数据传输协议。比较经典的i2c、CAN等数据传输，到以后的usb、ZigBee的数据传输。在这里先聊一聊串口的数据传输。

在Micro2440开发板上进行串口通信，要做的第一步便是串口驱动。这次我的开发板已经移植好了串口驱动。我只需进行操作，这里简单记录串口的基本操作 **收数据**、**发数据**以后用起来也方便，驱动下次分析。
<!---more--->
### 串口通信
**分类**：同步串口通信（SPI）、异步串口通信（UART）

同步串行是指SPI（Serial Peripheral interface）的缩写，顾名思义就是串行外围设备接口。SPI总线系统是一种同步串行外设接口，它可以使MCU与各种外围设备以串行方式进行通信以交换信息，TRM450是SPI接口。

异步串行是指UART（Universal Asynchronous Receiver/Transmitter），通用异步接收/发送。UART是一个并行输入成为串行输出的芯片，通常集成在主板上。UART包含TTL电平的串口和RS232电平的串口。 TTL电平是3.3V的，而RS232是负逻辑电平，它定义+5~+12V为低电平，而-12~-5V为高电平，MDS2710、MDS SD4、EL805等是RS232接口，EL806有TTL接口。

### 串口数据传输的特点
1.传输速度慢，数据量不大，数据一位一位的顺序传输

2.支持双向通信，只需一对数据线,也可以一根单向通信

        TXD  ---------> RXD

        RXD  <--------- TXD

        GND  <--------> GND

### 串口的参数配置

```
        int set_opt(int fd, int nSpeed, int nBits, char nEvent, int nStop)  
        {  
            struct termios newtio;  
            struct termios oldtio;  

            if(tcgetattr(fd,&oldtio) != 0)  
            {  
                perror("SetupSerial 2");  
                return -1;  
            }  

            bzero(&newtio,sizeof(newtio));  
            newtio.c_cflag |= CLOCAL |CREAD;  
            newtio.c_cflag &= ~CSIZE;  

            switch(nBits)  
            {  
                case 7:  
                    newtio.c_cflag |= CS7;  
                    break;  
                case 8:  
                    newtio.c_cflag |= CS8;  
                    break;      
            }  

            switch(nEvent)  
            {  
                case 'O':  
                    newtio.c_cflag |= PARENB;  
                    newtio.c_cflag |= PARODD;  
                    newtio.c_iflag |= (INPCK | ISTRIP);  
                    break;  
                case 'E':  
                    newtio.c_iflag |= (INPCK |ISTRIP);  
                    newtio.c_cflag |= PARENB;  
                    newtio.c_cflag &= ~PARODD;  
                    break;  
                case 'N':  
                    newtio.c_cflag &= ~PARENB;  
                    break;  
            }  

            switch(nSpeed)  
            {  
                case 2400:  
                    cfsetispeed(&newtio,B2400);  
                    cfsetospeed(&newtio,B2400);  
                    break;  
                case 4800:  
                    cfsetispeed(&newtio,B4800);  
                    cfsetospeed(&newtio,B4800);  
                    break;  
                case 9600:  
                    cfsetispeed(&newtio,B9600);  
                    cfsetospeed(&newtio,B9600);  
                    break;  
                case 115200:  
                    cfsetispeed(&newtio,B115200);  
                    cfsetospeed(&newtio,B115200);  
                    break;  
                case 460800:  
                    cfsetispeed(&newtio,B460800);  
                    cfsetospeed(&newtio,B460800);  
                    break;            
                default:  
                    cfsetispeed(&newtio,B9600);  
                    cfsetospeed(&newtio,B9600);  
                    break;  
            }  

            if(nStop == 1){  
                newtio.c_cflag &= ~CSTOPB;  
            }  
            else if(nStop ==2){  
                newtio.c_cflag |= CSTOPB;  
            }  
            newtio.c_cc[VTIME] = 0;  
            newtio.c_cc[VMIN] = 0;  

            tcflush(fd,TCIFLUSH);  
            if((tcsetattr(fd,TCSANOW,&newtio)) != 0)  
            {  
                perror("com set error");  
                return -1;  
            }  
            printf("set done!\n");  
            return 0;  
        }  

        int open_port(int fd,int comport)  
        {  
            char *dev[]={"/dev/ttySAC0","/dev/ttySAC1","/dev/ttySAC2"};  
            long vdisable;  
            if(comport == 1)  
            {  
                fd = open("/dev/ttySAC0",O_RDWR|O_NOCTTY|O_NDELAY);  
                if(fd == -1){  
                    perror("Can't Open Serial Port");  
                    return -1;  
                }  
            }  

            else if(comport == 2)  
            {  
                fd = open("/dev/ttySAC1",O_RDWR|O_NOCTTY|O_NDELAY);  
                if(fd == -1){  
                    perror("Can't Open Serial Port");  
                    return -1;  
                }  
            }  

            else if(comport == 3)  
            {  
                fd = open("/dev/ttySAC2",O_RDWR|O_NOCTTY|O_NDELAY);  
                if(fd == -1){  
                    perror("Can't Open Serial Port");  
                    return -1;  
                }  
            }  

            if(fcntl(fd,F_SETFL,0) < 0){  
                printf("fcntl failed\n");  
            }  
            else{  
                printf("fcntl=%d\n",fcntl(fd,F_SETFL,0));  
            }  

            if(isatty(STDIN_FILENO) == 0){  
                printf("standard input is not a terminal device\n");  
            }  
            else{  
                printf("isatty sucess!\n");  
            }  

            printf("fd-open=%d\n",fd);  
            return fd;  
        }  
```

###接收串口数据

    nread = read(fd,buff,n)；

### 发送串口数据

    nwrite = write(fd,buff,length);  

### 实际应用
上面两个程序可以完成数据的收发，在具体的项目中在串口的数据传输中多种数据的传输时，会涉及到一些简单的数据处理，需要自定义一些协议。这时串口数据的收发必须精确的每个字符，不能多一个也不能少一个。

read、write函数，它们读写的字符必须精准，在write时写入数据的大小必须和字符串的大小一致。在送单一的数据时，对写数据大小不做要求可是在自定义协议中数据的大小关系到对方的解析。

这次使用的数据格式：FD 00 06 02 00 31 33 33 C8

```
        char Speaker(char CMD,char par,char * pString)
        {  
            char headOfFrame[5];  
            char length;         //定义字符串长度  
            char ecc = 0;        //定义校验字节  
            int i = 0;   
            if (pString == NULL) //空字符串   
                return 1;        
            headOfFrame[0]=0XFD;       //构造帧头FD  
            headOfFrame[1]=0X00;       //构造数据区长度的高字节
            length = strlen(pString);  //需要发送文本的长度  
            headOfFrame[2]=length+3;   //构造数据区长度的低字节  
            headOfFrame[3]=CMD;        //构造命令字：合成播放命令  
            headOfFrame[4]=par;        //构造命令参数：编码格式为GB2312   
            for(i=0;i<5;i++)           //依次发送构造好的5个帧头字节  
            {    
                ecc=ecc^(headOfFrame[i]); //对发送的字节进行异或校验     
                write(fd,&headOfFrame[i],1);  
            }
            for(i=0;i<length;i++)         //依次发送待合成的文本数据   
            {
                ecc=ecc^(*pString);   
                write(fd,pString,1);
                pString ++;   
            }

            write(fd,&ecc,1);    //最后发送校验和
            return 0; //成功返回0
        }  
```
