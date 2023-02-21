---
layout: post
title: Docker 搭建 Nextcloud
date: '2020-05-06 23:38'
tags:
  - docker
categories:
  - 系统服务
abbrlink: efa23dc6
---

系统：ubuntu18.04

搭建个人网盘

<!--more-->

## Docker环境

### 方法一

1. 添加可信任的 GPG 公钥
   ``` shell
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```
2. 查看 GPG 公钥
   ``` shell
   apt-key fingerprint 0EBFCD88
   $apt-key fingerprint 0EBFCD88
   pub   rsa4096 2017-02-22 [SCEA]
        9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
   uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
   sub   rsa4096 2017-02-22 [S]
   ```
3. 添加镜像源
   ``` shell
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
   ```
4. 安装 Docker-CE 及其依赖
   ``` shell
   sudo apt update
   sudo apt install -y docker-ce
   ```

### 方法二

``` shell
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

### Docker 镜像加速器
1. 添加网易云 Docker 镜像加速器
   ``` shell
   curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://hub-mirror.c.163.com/
   ```
2. 重启 Docker 服务
   ``` shell
   sudo systemctl restart docker.service
   ```
3. 检查 Docker 是否安装成功
   ``` shell
   sudo docker info
   ```

## 安装 docker-compose 工具

docker-compose 是一个由 Docker 官方提供的管理工具，适合一个应用需要多个容器配合统一管理，进一步简化应用部署、应用升级步骤。

``` shell
sudo apt install -y python3 python3-pip
sudo pip3 install docker-compose
```
在安装`docker-compose`时，由于网络原因下载可能会总超时，可以使用该脚本安装直到成功
``` shell
sudo pip3 install docker-compose
while [ $? != 0 ]; do
    sleep 3
    sudo pip3 install docker-compose
done
```

### 直接下载

进入https://github.com/docker/compose/releases 查看最新版本，选择当前版本为`1.25.5`

``` shell
curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` -o docker-compose
chmod +x docker-compose
```

查看是否安装成功

``` shell
./docker-compose --version
```

## 安装nextcloud

1. 编写docker-compose.yml文件
docker-compose 的管理主要依赖于一个名为 docker-compose.yml 的 yaml 文件来进行管理，当然这个文件也可以以任何别的名称并以`-f filename`的方式来启用，但必须是符合yaml格式和Docker官方定义的字段和方式。



2. 启动容器
以下命令即可开始拉取所需容器的镜像文件并根据`docker-compose.yml`文件配置好本地文件夹挂载和端口映射。（由于需要拉取镜像，可能需要等一段时间，与当前网络环境相关。）

``` shell
sudo ./docker–compose up –d
```


查看容器是否启动

```shell
sudo docker ps -a
```

3. 应用初始化配置

访问 http://<IP 地址> 设置管理员用户名和密码（比如 admin 和 admin@nextcloud.com ），数据目录默认即可，数据库信息填写如 docker-composer.yml 中所示，数据库主机名填 db （配置文件中的数据库应用名）

4. 更新应用至最新版

``` shell
sudo docker pull nextcloud
sudo ./docker-compose down && sudo ./docker-compose up -d
```

## 参考

- [Nginx配合docker安装nextcloud](https://tsov.net/home/view/2077/)
- [Docker 搭建 Nextcloud](https://blog.csdn.net/weixin_36851500/article/details/90409195)
