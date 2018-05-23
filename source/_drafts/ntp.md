# NTP

通俗：Ntp是一种对时的软件

## 1. 搭建NTP Server

1. ubuntu，deepin

```
sudo apt-get install ntp
```

2. 修改配置文件
```
sudo vim /etc/ntp.conf

　　　　driftfile /var/lib/ntp/ntp.drift

　　　　statistics loopstats peerstats clockstats

　　　　filegen loopstats file loopstats type day enable
　　　　filegen peerstats file peerstats type day enable
　　　　filegen clockstats file clockstats type day enable
　　　　server ntp.ubuntu.com
　　　　restrict -4 default kod notrap nomodify nopeer noquery
　　　　restrict -6 default kod notrap nomodify nopeer noquery

　　　　restrict 192.168.1.0 mask 255.255.255.0 nomodify   #<+++++主要是允许能同步的服务器所在的内部网段

　　　　restrict 127.0.0.1
　　　　restrict ::1V
```

* 权限设定部分

　　权限设定主要以restrict这个参数来设定，主要的语法为：
　　restrict IP mask netmask_IP parameter
　　其中IP可以是软体位址，也可以是 default ，default 就类似0.0.0.0
　　至于 paramter则有：
　　ignore：关闭所有的NTP 连线服务
　　nomodify：表示Client 端不能更改 Server 端的时间参数，不过Client端仍然可以透过Server 端來进行网络较时。
　　notrust：该 Client 除非通过认证，否则该 Client 来源将被视为不信任网域
　　noquery：不提供 Client 端的时间查询
　　如果 paramter完全没有设定，那就表示该 IP (或网域) 『没有任何限制！』
* 上层主机设定
　　上层主机选择ntp.ubuntu.com，要设定上层主机主要以server这个参数来设定，语法为：server [IP|FQDN] [prefer]
　　Server 后面接的就是我们上层的Time Server ！而如果 Server 参数后面加上perfer 的话，那表示我们的 NTP 主机主要以该部主机来作为时间较正的对应。另外，为了解决更新时间封包的传送延迟动作，可以使用driftfile 来规定我们的主机在与Time Server沟通时所花费的时间，可以记录在 driftfile 后面接的档案内

3. reset

```
sudo /etc/init.d/ntp restart
```



## 2. 开发板启动NTP

### 移植NTP

1. 下载[http://www.ntp.org/downloads.html](http://www.ntp.org/downloads.html)

wget https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p11.tar.gz

2. 交叉编译

```
./configure --host=arm-linux CC=arm-none-linux-gnueabi-gcc --prefix=/home/ntp --with-yielding-select
make
make install
```

--with-yielding-select


### 同步

```
ntpdate 192.168.1.11
```

### 获取精准的系统时间



## 时区

两个时区不匹配

```
date
```
注意：用date命令查看之后显示的是UTC时间（世界标准时间），比北京时间（CST=UTC+8）相差8个小时，所以需要设置时区

设置时区为CST时间
（1）把redhat或者ubuntu系统目录/usr/share/zoneinfo/Asia中的文件Shanghai拷贝到开发板目录/etc中并且改名为localtime之后，用命令reboot重启即可



## 参考

* [移植ntp服务到arm-linux平台](https://blog.csdn.net/zgrjkflmkyc/article/details/45098831)
* [So Easy-Ntp嵌入式软件移植](https://www.cnblogs.com/smartxuchao/p/6440524.html)
* [ubuntu搭建NTP服务器](https://blog.csdn.net/mmz_xiaokong/article/details/8700979)
