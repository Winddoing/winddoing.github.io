---
layout: post
title: socket错误号
date: '2018-09-26 11:10'
tags:
  - 错误号
categories:
  - 网络
abbrlink: 54884
---

socket编程中的出现的错误号基本含义：

``` C
#include <errno.h>
...
{
    ...
    ret = sendto(fd, msg, msgLen, 0, (struct sockaddr*)&un, size);
    printf("%d sendto errno:%d\n", getpid(), errno);
}
```

<!--more-->

## 错误号---errno

``` C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define NUM 135
int main(void)
{
	int i;
	for (i = 0; i < NUM; i++) {
		printf("%d: %s\n", i, strerror(i));
	}
	return 0;
}
```

- 结果：
```
0: Success
1: Operation not permitted
2: No such file or directory
3: No such process
4: Interrupted system call
5: Input/output error
6: No such device or address
7: Argument list too long
8: Exec format error
9: Bad file descriptor
10: No child processes
11: Resource temporarily unavailable
12: Cannot allocate memory
13: Permission denied
14: Bad address
15: Block device required
16: Device or resource busy
17: File exists
18: Invalid cross-device link
19: No such device
20: Not a directory
21: Is a directory
22: Invalid argument
23: Too many open files in system
24: Too many open files
25: Inappropriate ioctl for device
26: Text file busy
27: File too large
28: No space left on device
29: Illegal seek
30: Read-only file system
31: Too many links
32: Broken pipe
33: Numerical argument out of domain
34: Numerical result out of range
35: Resource deadlock avoided
36: File name too long
37: No locks available
38: Function not implemented
39: Directory not empty
40: Too many levels of symbolic links
41: Unknown error 41
42: No message of desired type
43: Identifier removed
44: Channel number out of range
45: Level 2 not synchronized
46: Level 3 halted
47: Level 3 reset
48: Link number out of range
49: Protocol driver not attached
50: No CSI structure available
51: Level 2 halted
52: Invalid exchange
53: Invalid request descriptor
54: Exchange full
55: No anode
56: Invalid request code
57: Invalid slot
58: Unknown error 58
59: Bad font file format
60: Device not a stream
61: No data available
62: Timer expired
63: Out of streams resources
64: Machine is not on the network
65: Package not installed
66: Object is remote
67: Link has been severed
68: Advertise error
69: Srmount error
70: Communication error on send
71: Protocol error
72: Multihop attempted
73: RFS specific error
74: Bad message
75: Value too large for defined data type
76: Name not unique on network
77: File descriptor in bad state
78: Remote address changed
79: Can not access a needed shared library
80: Accessing a corrupted shared library
81: .lib section in a.out corrupted
82: Attempting to link in too many shared libraries
83: Cannot exec a shared library directly
84: Invalid or incomplete multibyte or wide character
85: Interrupted system call should be restarted
86: Streams pipe error
87: Too many users
88: Socket operation on non-socket
89: Destination address required
90: Message too long
91: Protocol wrong type for socket
92: Protocol not available
93: Protocol not supported
94: Socket type not supported
95: Operation not supported
96: Protocol family not supported
97: Address family not supported by protocol
98: Address already in use
99: Cannot assign requested address
100: Network is down
101: Network is unreachable
102: Network dropped connection on reset
103: Software caused connection abort
104: Connection reset by peer
105: No buffer space available
106: Transport endpoint is already connected
107: Transport endpoint is not connected
108: Cannot send after transport endpoint shutdown
109: Too many references: cannot splice
110: Connection timed out
111: Connection refused
112: Host is down
113: No route to host
114: Operation already in progress
115: Operation now in progress
116: Stale file handle
117: Structure needs cleaning
118: Not a XENIX named type file
119: No XENIX semaphores available
120: Is a named type file
121: Remote I/O error
122: Disk quota exceeded
123: No medium found
124: Wrong medium type
125: Operation canceled
126: Required key not available
127: Key has expired
128: Key has been revoked
129: Key was rejected by service
130: Owner died
131: State not recoverable
132: Operation not possible due to RF-kill
133: Memory page has hardware error
134: Unknown error 134
```

## 宏定义

* include/uapi/asm-generic/errno-base.h/[_ASM_GENERIC_ERRNO_BASE_H](https://elixir.bootlin.com/linux/latest/source/include/uapi/asm-generic/errno-base.h)
* include/uapi/asm-generic/errno.h/[_ASM_GENERIC_ERRNO_H](https://elixir.bootlin.com/linux/latest/source/include/uapi/asm-generic/errno.h)
> Linux内核中的位置

### 111： ECONNREFUSED

> A connect() on a stream socket found no one listening on the remote address.

> From: `man connect`

1. 拒绝连接。一般发生在连接建立时
    - 拔服务器端网线测试，客户端设置keep alive时，recv较快返回0， 先收到ECONNREFUSED (Connection refused)错误码，其后都是ETIMEOUT。

2. an error returned from connect(), so it can only occur in a client(if a client is defined as the party that initiates the connection

> 场景：使用UDP在进程间socket通信，`sendto`发送消息时，返回错误，错误号为`111`.

对端的socket没有进行接收所致。

### 115: EINPROGRESS

>The socket is `nonblocking` and the connection cannot be completed immediately. It is possible to `select(2)` or `poll(2)` for completion by selecting the socket for `writing`. After select(2) indicates writability, use getsockopt(2) to read the SO_ERROR option at level SOL_SOCKET to determine whether connect() completed successfully (SO_ERROR is zero) or unsuccessfully (SO_ERROR is one of the usual error codes listed here, explaining the reason for the failure).

> From: `man connect`

- 非阻塞的socket，connect调用后立即返回，连接过程还在执行

> 场景： TCP连接中进行`connect`错误后，返回值：`-1`，错误号：`115`

``` C
int connect_timeout(int fd, struct sockaddr_in *addr, unsigned int wait_seconds)
{
	int ret;
	socklen_t addrlen = sizeof(struct sockaddr_in);

	if (wait_seconds > 0)
		activate_nonblock(fd);	//设为非阻塞

	ret = connect(fd, (struct sockaddr*)addr, addrlen);
	if (ret < 0 && errno == EINPROGRESS) {
		struct timeval timeout;
		fd_set write_fdset;

		FD_ZERO(&write_fdset);
		FD_SET(fd, &write_fdset);

		timeout.tv_sec = wait_seconds;
		timeout.tv_usec = 0;

		do {
			ret = select(fd + 1, NULL, &write_fdset, NULL, &timeout);
		} while (ret < 0 && errno == EINTR);

		if (ret == 0) {
			ret = -1;
			errno = ETIMEDOUT;
			printf("%s:%d, select error[%d]:%s, ret=%d\n", __func__, __LINE__, errno, strerror(errno), ret);
		} else if (ret < 0) {
			printf("%s:%d, select error[%d]:%s, ret=%d\n", __func__, __LINE__, errno, strerror(errno), ret);
			return -1;
		} else if (ret == 1) {
			int err;
			socklen_t socklen = sizeof(err);
			ret = getsockopt(fd, SOL_SOCKET, SO_ERROR, &err, &socklen);
			if (ret == -1) {
				printf("%s:%d, getsockopt error[%d]:%s, ret=%d\n", __func__, __LINE__, errno, strerror(errno), ret);
				return -1;
			}
			if (err == 0) {
				ret = 0; //success
			} else {
				errno = err;
				ret = -1;
				printf("%s:%d, getsockopt error[%d]:%s, ret=%d\n", __func__, __LINE__, errno, strerror(errno), ret);
			}
		}
	}
	if (wait_seconds > 0) {
		deactivate_nonblock(fd);	//设回阻塞
	}
	return ret;
}

int net_set_nonblocking(int sock)
{
    int flags, res;

    flags = fcntl(sock, F_GETFL, 0);
    if (flags < 0) {
        flags = 0;
    }

    res = fcntl(sock, F_SETFL, flags | O_NONBLOCK);
    if (res < 0) {
        printf("fcntl return err:%d!\n", res);
        return -1;
    }

    return 0;
}
```


### 4: EINTR

``` C
do {
    n = recv(new_fd, buff, 500, 0);
} while (n < 0 && errno == EINTR);
```

### 34: ERANGE

>#define	ERANGE		34	/* Math result not representable */  结果无法表示

在socket连接中，server端关闭了该连接
