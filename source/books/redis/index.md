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



# Redis设计与实现

## 第二章  简单动态字符串

Redis没有直接使用C语言中的字符串，而是自己构建了SDS这样的一种简单动态字符串，并且将他作为Redis中字符串的默认的表示，个人认为，Redis并未完全抛弃C语言字符串，只不过是在C语言字符串的基础上，通过封装其他的属性，构造出一个更加高效的字符串的封装结构，`记录长度`、`分配内存大小（除去‘\0’）`、`标志位（低三位表示类型，其余五位未使用）`、以及`字符数组`。

### SDS

``` C
typedef char *sds;

/* Note: sdshdr5 is never used, we just access the flags byte directly.
 * However is here to document the layout of type 5 SDS strings. */
struct __attribute__ ((__packed__)) sdshdr5 {
    unsigned char flags; /* 3 lsb of type, and 5 msb of string length */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr8 {
    uint8_t len; /* used */
    uint8_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr16 {
    uint16_t len; /* used */
    uint16_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr32 {
    uint32_t len; /* used */
    uint32_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
struct __attribute__ ((__packed__)) sdshdr64 {
    uint64_t len; /* used */
    uint64_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
```
> 多种结构的sds结构体的定义，个人理解是为了不同长度的字符串所使用，可以更好的利用内存空间。

- len： 字符串长度
- alloc：申请的内存大小
- flags：标记结构体类型
- buf： 字符串的首地址

flags类型：
``` C
#define SDS_TYPE_5  0
#define SDS_TYPE_8  1
#define SDS_TYPE_16 2
#define SDS_TYPE_32 3
#define SDS_TYPE_64 4

#define SDS_TYPE_MASK 7
#define SDS_TYPE_BITS 3
```

#### 存储空间

```
+-----+-------+-------+--------------------------------------------+
| len | alloc | flags |                                         |\0|
+-----+-------+-------+--------------------------------------------+
       header                               data
```

``` C
sds sdsnewlen(const void *init, size_t initlen) {
    void *sh;
    sds s;
    char type = sdsReqType(initlen);
    printf("===> func: %s, line: %d, file: %s, type=%d, initlen=%d\n", __func__, __LINE__, __FILE__, type, initlen);
    /* Empty strings are usually created in order to append. Use type 8
     * since type 5 is not good at this. */
    if (type == SDS_TYPE_5 && initlen == 0) type = SDS_TYPE_8;
    int hdrlen = sdsHdrSize(type);
    printf("===> func: %s, line: %d, file: %s, type=%d, initlen=%d, hdrlen=%d\n", __func__, __LINE__, __FILE__, type, initlen, hdrlen);
    unsigned char *fp; /* flags pointer. */

    sh = s_malloc(hdrlen+initlen+1);
    if (!init)
        memset(sh, 0, hdrlen+initlen+1);
    if (sh == NULL) return NULL;
    s = (char*)sh+hdrlen;
    fp = ((unsigned char*)s)-1;
    switch(type) {
        case SDS_TYPE_5: {
            *fp = type | (initlen << SDS_TYPE_BITS);
            break;
        }
        case SDS_TYPE_8: {
            SDS_HDR_VAR(8,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_16: {
            SDS_HDR_VAR(16,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_32: {
            SDS_HDR_VAR(32,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_64: {
            SDS_HDR_VAR(64,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
    }
    if (initlen && init)
        memcpy(s, init, initlen);
    s[initlen] = '\0';
    return s;
}
```
