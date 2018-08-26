---
title: Redis
date: 2018-08-26 8:07:24
comments: false
---

{% centerquote %} Redis源码分析 {% endcenterquote %}

## 下载源码

```
$ git clone https://github.com/antirez/redis.git
$ git checkout -b 4.0 4.0.11
```

## 编译&运行

```
make
./redis-server
./redis-cli
```

## 文件目录

程序入口`main`函数与相关文件的关系和作用：
```
dict.c:1151:int main(int argc, char **argv)   //字典和哈希表的实现
redis-benchmark.c:648:int main(int argc, const char **argv)   //Redis性能测试工具
redis-cli.c:2849:int main(int argc, char **argv)  //Redis的Client入口
sds.c:1282:int main(void)   //Redis字符串实现
server.c:3709:int main(int argc, char **argv)  //Redis的Server入口
siphash.c:350:int main(void)    //非加密的64位哈希算法的实现
```
>dir:src

这里主要从`Server`和`Client`这两个入口进行简单分析：

## Makefile

从Makefile文件中可以得到，Redis最终编译完成后，生成的可执行文件和其所依赖的相关源码文件，方便认识Radis源码的基本结构。

### 可执行文件
```
REDIS_SERVER_NAME=redis-server                                                                                                     
REDIS_SENTINEL_NAME=redis-sentinel                                                                                                                  
REDIS_CLI_NAME=redis-cli                                             
REDIS_BENCHMARK_NAME=redis-benchmark                                                                                               
REDIS_CHECK_RDB_NAME=redis-check-rdb                                                                                               
REDIS_CHECK_AOF_NAME=redis-check-aof                                                                                                                          
```
|      文件       | 作用         |
|:---------------:|:-------------|
|  redis-server   | Server端     |
| redis-sentinel  | 分布式       |
|    redis-cli    | Client端     |
| redis-benchmark | 性能测试工具 |
| redis-check-rdb |              |
| redis-check-aof |              |

### redis-server

```
REDIS_SERVER_OBJ=adlist.o quicklist.o ae.o anet.o dict.o server.o sds.o zmalloc.o lzf_c.o lzf_d.o pqsort.o zipmap.o sha1.o ziplist.o release.o networking.o util.o object.o db.o replication.o rdb.o t_string.o t_list.o t_set.o t_zset.o t_hash.o config.o aof.o pubsub.o multi.o debug.o sort.o intset.o syncio.o cluster.o crc16.o endianconv.o slowlog.o scripting.o bio.o rio.o rand.o memtest.o crc64.o bitops.o sentinel.o notify.o setproctitle.o blocked.o hyperloglog.o latency.o sparkline.o redis-check-rdb.o redis-check-aof.o geo.o lazyfree.o module.o evict.o expire.o geohash.o geohash_helper.o childinfo.o defrag.o siphash.o rax.o  
```

### redis-cli

```
REDIS_CLI_OBJ=anet.o adlist.o redis-cli.o zmalloc.o release.o anet.o ae.o crc64.o
```

### redis-benchmark

```
REDIS_BENCHMARK_OBJ=ae.o anet.o redis-benchmark.o adlist.o zmalloc.o redis-benchmark.o
```

## Server

模式：`sentinel` 、`cluster`
- cluster : 集群模式
- sentinel : 哨兵模式

事件驱动：`ae`


## Client
