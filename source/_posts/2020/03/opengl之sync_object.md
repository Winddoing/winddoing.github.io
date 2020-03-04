---
layout: post
title: OpenGL之Sync Object
date: '2020-03-04 14:44'
tags:
  - OpenGL
categories:
  - 多媒体
  - OpenGL
---

> *Sync Objects* are objects that are used to synchronize the activity between the GPU and the application. `glFinish` is a start to synchronization, but sync objects allow for much finer grained control.
> - https://www.khronos.org/opengl/wiki/Sync_Object


<!--more-->

## 数据类型

``` C
typedef struct __GLsync *GLsync;
```

`GLsync`同步对象永远不会绑定到上下文，也不会像普通GL对象一样封装状态。 这些不是OpenGL对象。

有一个通用的glDeleteSync函数可删除任何类型的同步对象。


## 图像渲染

egl为opengl的执行创建了一个上下文Context。这时Context中绑定了一个默认的Framebuffer。后续所有的渲染都是在这个framebuffer上进行的。

当我们调用`drawcall`来绘制一组三维物体的时候，实际上这个`drawcall`并没有立即执行，或者说并不保证立即执行了，gl库的实现也可能只是制作了一个命令队列，往这个命令队列里填加了一些命令，当你调用下一条opengl函数时，上一个函数会没有被执行，它还在排队。也就是说普通的opengl函数是异步的。

所有的opengl函数都是异步的肯定是不行的，有些时候我们必须保证某个函数返回时，它及它之前的函数都真正被执行了。也就是说要有一些不普通的函数，它们是同步的。比如说`glFinish`，当这个函数返回时，gl库会保证之前的命令全部都执行完毕了。

还有`glFlush`，gl库会立即把队列里的所有命令提交给显卡去执行一轮。
在glFlush和glFinsh之后的函数调用，都会落在下一轮渲染管线执行中了。

> `drawcall`的标志很简单，一个`glDrawXXX`函数调用就是一个drawcall的结束标志。



## 同步——Synchronization

同步对象的目的是使CPU与GPU的动作同步。为此，同步对象具有当前状态的概念。同步对象的状态可以发信号或不发信号。此状态代表GPU的某种状态，具体取决于同步对象的特定类型及其使用方式。这类似于使用互斥在线程之间同步行为的方式。当发出互斥信号时，它允许正在等待它的其他线程激活。

- 要阻塞所有CPU操作，直到发出同步对象信号为止
  ``` C
  enum glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
  ```
- 指示GL服务器阻塞，直到发出指定的同步对象信号为止
  ``` C
  void glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
  ```


## 接口函数

### glFenceSync

> `glFenceSync` — create a new sync object and insert it into the GL command stream

``` C
GLsync glFenceSync(GLenum condition,
  	             GLbitfield flags);
```
glFenceSync创建一个新的fence同步对象，将fence命令插入GL命令流并将其与该同步对象相关联，并返回与该同步对象相对应的非零名称。

当fence命令满足了同步对象的指定条件时，GL将向该同步对象发出信号，从而使所有在同步中阻塞的glWaitSync和glClientWaitSync命令解除阻塞。 glFenceSync或关联的fence命令的执行不会影响其他任何状态。

条件必须为GL_SYNC_GPU_COMMANDS_COMPLETE。通过完成与同步对象相对应的fence命令以及同一命令流中的所有先前命令，可以满足此条件。在完全实现这些命令对GL客户端和服务器状态以及帧缓冲区的所有影响之前，不会发信号通知同步对象。请注意，一旦更改了相应同步对象的状态，便会完成fence命令，但是直到fence命令完成后，等待该同步对象的命令才可能被释放。

## 例子

``` C
...
GLsync sync = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);  

...

glWaitSync(sync, 0, GL_TIMEOUT_IGNORED);                      
glDeleteSync(sync);                                           
...
```

## 参考

- [Sync Object](https://www.khronos.org/opengl/wiki/Sync_Object)
