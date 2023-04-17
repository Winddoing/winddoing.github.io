---
title: clash for linux
tags:
  - 科学上网
categories:
  - 工具
abbrlink: '9992854'
date: 2023-03-02 00:00:00
---

Clash 是一个使用 Go 语言编写，基于规则的跨平台代理软件核心程序。

<!--more-->


## 下载

``` shell
wget https://github.com/Dreamacro/clash/releases/download/v1.13.0/clash-linux-amd64-v1.13.0.gz
```
最新版本 https://github.com/Dreamacro/clash/releases


## 安装

解压后直接执行，将在`~/.config/`目录下生成一个clash目录，其中有配置文件

``` shell
gzip -d clash-linux-amd64-v1.13.0.gz
chmod +x clash-linux-amd64-v1.13.0
./clash-linux-amd64-v1.13.0
INFO[0000] Can't find config, create a initial config file
INFO[0000] Can't find MMDB, start download
```

为了后期管理方便，可以之间将解压后的clash拷贝到`~/.config/clash`目录下，并重命名为clash

``` shell
cp ./clash-linux-amd64-v1.13.0 ~/.config/clash/clash

$ls ~/.config/clash/
clash  config.yaml
```


## 配置

下载配置文件

``` shell
wget -O config.yaml "代理商提供的订阅链接"
wget -O config.yaml "https://xxxxxxxxxxxxxxxxxx06d2739906177ad22&flag=clash"
```
>如果下载到的是一大堆字符则需要在订阅链接的后面添加 **&flag=clash**

执行`./clash`，将会下载`Country.mmdb`
``` shell
./clash
WARN[0000] MMDB invalid, remove and download
```

如果下载失败进行手动下载
``` shell
$./clash
WARN[0000] MMDB invalid, remove and download
FATA[0030] Initial configuration directory error: can't initial MMDB: can't download MMDB: Get "https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb": dial tcp 146.75.113.229:443: i/o timeout
```

``` shell
wget -O Country.mmdb https://www.sub-speeder.com/client-download/Country.mmdb
```

在 https://github.com/Dreamacro/maxmind-geoip/releases 下载也可以


以上准备配置文件弄号后就可以运行
```
~/.config/clash
↪ =>$ls
clash  config.yaml  Country.mmdb

↪ =>$./clash
INFO[0000] Start initial compatible provider 故障转移
INFO[0000] Start initial compatible provider 自动选择
INFO[0000] Start initial compatible provider 一元机场
INFO[0000] RESTful API listening at: 127.0.0.1:9090
INFO[0000] Mixed(http+socks) proxy listening at: [::]:7890
```

在`clash`启动后用浏览器访问网址`http://clash.razord.top/` ，在这里修改配置信息

## 配置代理

### 系统代理配置——浏览器生效

![](../../images/clash%20for%20linux.png)

命令行设置：
``` shell
gsettings set org.gnome.system.proxy.http host '127.0.0.1'
gsettings set org.gnome.system.proxy.http port 7890
gsettings set org.gnome.system.proxy.https host '127.0.0.1'
gsettings set org.gnome.system.proxy.https port 7890
gsettings set org.gnome.system.proxy.ftp host ''
gsettings set org.gnome.system.proxy.ftp port 0
gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
gsettings set org.gnome.system.proxy.socks port 7890

gsettings set org.gnome.system.proxy mode 'manual';
```

### git代理

#### https传输

- http代理
```
git config --global http.proxy 'http://127.0.0.1:1080'
git config --global https.proxy 'http://127.0.0.1:1080'
```

- socks5代理
```
git config --global http.proxy 'socks5://127.0.0.1:1081'  
git config --global https.proxy 'socks5://127.0.0.1:1081'
```

- 取消代理
```
git config --global --unset http.proxy  
git config --global --unset https.proxy
```

#### ssh传输

通过 [netcat](https://en.wikipedia.org/wiki/Netcat) 或 [ssh-connect](https://github.com/gotoh/ssh-connect) 可以建立连接以供 ssh 使用。

修改 OpenSSH 的 `config` 文件（Unix/Linux/Git-Bash：`~/.ssh/config`），添加如下内容之一

#####  netcat

- http代理
```
Host github.com  
	HostName github.com  
	User git  
	ProxyCommand nc -v -X connect -x 127.0.0.1:1080 %h %p
```
- socks5代理
```
Host github.com  
	HostName github.com  
	User git  
	ProxyCommand nc -v -x 127.0.0.1:1081 %h %p
```

##### ssh-connect

- http代理
```
Host github.com  
	HostName github.com  
	User git  
	ProxyCommand connect -H 127.0.0.1:1080 %h %p
```

- socks5代理
```
Host github.com  
	HostName github.com  
	User git  
	ProxyCommand connect -S 127.0.0.1:1081 %h %p
```


## 命令行下载代理——proxychains

需要socks代理端口

``` shell
sudo apt install proxychains
```

ProxyChains 的配置文件位于 /etc/proxychains.conf ，打开后你需要在末尾添加你使用的代理。

```
[ProxyList]
# add proxy here ...
# meanwile
# defaults set to "tor"
#socks4 	127.0.0.1 9050

socks5 127.0.0.1 7890   # 配置为混合端口，因此不需要区分
```

- 测试

```
proxychains ping www.google.com
ProxyChains-3.1 (http://proxychains.sf.net)
ERROR: ld.so: object 'libproxychains.so.3' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
PING www.google.com (199.59.149.201) 56(84) bytes of data.
```

- 解决方法：

查找`libproxychains.so.3`位置
```
whereis libproxychains.so.3
libproxychains.so: /usr/lib/x86_64-linux-gnu/libproxychains.so.3
```

修改`/usr/bin/proxychains`

``` shell
#!/bin/sh
echo "ProxyChains-3.1 (http://proxychains.sf.net)"
if [ $# = 0 ] ; then
	echo "	usage:"
	echo "		proxychains <prog> [args]"
	exit
fi
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libproxychains.so.3   # 使用绝对路径
exec "$@"
```


### 代理与source执行

在需要代理并通过source执行脚本时，可以使用以下方法：

``` shell
proxychains bash -c source install.sh
```


### 代理与sudo

``` shell
sudo proxychains apt-get update
```


## clash的自启动

``` shell
pkill -9 clash # 先杀死之前的进程
rm nohuop.out # 删除刚刚生成的nohup.out文件
nohup ./clash -d . > /dev/null 2>&1 & # 不生成文件
lsof -i:7890 # 查看端口占用情况
```

创建一个`auto_run.sh`脚本
``` shell
nohup $HOME/.config/clash/clash -d $HOME/.config/clash/ > /dev/null 2>&1 &
```

将clash注册为systemctl服务 /usr/lib/systemd/system下新建一个文件clash.service 填入内容

``` shell
sudo vim /usr/lib/systemd/system/clash.service

cat /usr/lib/systemd/system/clash.service
[Unit]
Description=clash linux
After=network-online.target

[Service]
Type=simple
ExecStart=/opt/clash/clash -d /opt/clash
Restart=always

[Install]
WantedBy=multi-user.target
```
>根据实际配置路径进行修改

``` shell
# 重新加载配置文件
sudo systemctl daemon-reload

# 设置开机自启
sudo systemctl enable clash

service clash start   # 启动
service clash stop    # 停止
service clash restart # 重启
service clash status  # 状态
```


## 自动更新配置文件


配置文件信息是会更新的，我们也需要定时地更新本地的配置文件

```
wget -O /home/your_name/.config/clash/config.yaml "订阅链接"
```

使用linux自带的`cron`定时器，设定每日都运行一遍
```
crontab -e # 编辑定时任务
25 20 * * * wget -O /home/your_name/.config/clash/config.yaml [订阅地址]
service cron restart # 修改完都需要重启服务，不然不能生效
```
> 每天的`20:25`定时执行更新命令


## 参考

- [如何在Linux中使用Clash](https://zhuanlan.zhihu.com/p/366589407)
- [CLash for Linux 安装配置](https://www.alvinkwok.cn/2022/01/29/2022/01/Clash%20For%20Linux%20Install%20Guide/)
- [如何在 Linux 上优雅的使用 Clash？](https://blog.zzsqwq.cn/posts/how-to-use-clash-on-linux/) —— Docker
