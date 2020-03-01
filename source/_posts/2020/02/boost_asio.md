---
layout: post
title: boost asio for anbox
date: '2020-02-25 17:15'
tags:
  - C++
  - asio
  - 数据传输
  - anbox
categories:
  - 程序设计
---

Boost.Asio是用于`网络`和`低层IO`编程的跨平台C++库,为开发者提供了C++环境下稳定的`异步模型`。

<!--more-->

## IO模型

`io_service`对象是asio框架中的`调度器`，所有异步io事件都是通过它来分发处理的（io对象的构造函数中都需要传入一个io_service对象）, 其提供着是一个`生产者消费者模型`。
`io_service`类在多线程编程模型中提供了任务队列和任务分发功能,最常用的接口：`run`、`post`、`stop`
``` C++
boost::asio::io_service io_service;
boost::asio::ip::tcp::socket socket(io_service);
```
### 同步IO处理

![asio_socket_sync](/images/2020/02/asio_socket_sync.png)

1. 应用程序调用IO对象成员函数执行IO操作
2. IO对象向io_service 提出请求.
3. io_service 调用操作系统的功能`执行连接`操作.
4. 操作系统向io_service 返回执行结果.
5. io_service将错误的操作结果翻译为boost::system::error_code类型，再传递给IO对象.
6. 如果操作失败,IO对象抛出boost::system::system_error类型的异常.

### 异步IO处理

![asio_socket_async](/images/2020/02/asio_socket_async.png)

1. 应用程序调用IO对象成员函数执行IO操作
2. IO对象请求io_service的服务
3. io_service 通知操作系统其需要开始一个`异步连接`操作.
4. 操作系统指示连接操作完成, io_service从队列中获取操作结果
5. 应用程序必须调用io_service::run()以便于接收结果
6. 调用io_service::run()后,io_service返回一个操作结果,并将其翻译为error_code,传递到事件回调函数中

### 常用接口

- post

post用于发布io事件，如timer，socket读写等，一般由asio框架相应对象调用，无需我们显式调用。

- run

run用于`监听io事件`响应，并执行响应回调，对于异步io操作需要在代码中显式调用，对于同步io操作则由io对象隐式调用（并不是run函数，不过也是等待io事件）。

## boost::asio::io_service

`io_service`类在多线程编程里面提供了`任务队列`和`任务分发`功能，在socket、io编程里主要作为一个事件驱动器(完成端口、select、poll、epoll等)。

![asio_io_service](/images/2020/02/asio_io_service.png)
> `io_service`都一个公有任务队列，和多个私有任务队列，公有队列由各个线程共享，私有队列则是每个线程独享

1. 调用run方法，进入主loop；
2. 判断公有队列是否为空，不为空则取出任务并执行，当任务数大于1时同时唤醒其他空闲线程；
3. 任务执行结束，把各个线程的私有队里面的任务移动到公有任务队列里面；
4. 触发reactor，linux下面一般是`epoll`，当有事件时，把相应的事件的任务放到私有队列里。
5. 当队列为空时，把当前线程加到空闲线程队列里面，同时进入wait状态，等待其他线程的唤醒（task_operation）。
6. 当用户调用post时，任务是直接投递到公有队列op_queue里面。


## Anbox IO模型

Anbox 的 I/O 模型基于 boost.asio 构建。Anbox 中所有的 I/O 事件，在一个线程池中，通过一个`boost::asio::io_service`对象来派发并处理。Anbox 用`anbox::Runtime`类封装一个 `boost::asio::io_service`对象，并管理执行任务的`线程池`。

``` C++
namespace anbox {
// We bundle our "global" runtime dependencies here, specifically
// a dispatcher to decouple multiple in-process providers from one
// another , forcing execution to a well known set of threads.
class Runtime : public DoNotCopyOrMove,
                public std::enable_shared_from_this<Runtime> {
 public:
  // Our default concurrency setup.
  static constexpr const std::uint32_t worker_threads = 8;
  // create returns a Runtime instance with pool_size worker threads
  // executing the underlying service.
  static std::shared_ptr<Runtime> create(
      std::uint32_t pool_size = worker_threads);
  // Tears down the runtime, stopping all worker threads.
  ~Runtime() noexcept(true);
  // start executes the underlying io_service on a thread pool with
  // the size configured at creation time.
  void start();
  // stop cleanly shuts down a Runtime instance.
  void stop();
  // to_dispatcher_functional returns a function for integration
  // with components that expect a dispatcher for operation.
  std::function<void(std::function<void()>)> to_dispatcher_functional();
  // service returns the underlying boost::asio::io_service that is executed
  // by the Runtime.
  boost::asio::io_service& service();
 private:
  // Runtime constructs a new instance, firing up pool_size
  // worker threads.
  Runtime(std::uint32_t pool_size);
  std::uint32_t pool_size_;
  boost::asio::io_service service_;
  boost::asio::io_service::strand strand_;
  boost::asio::io_service::work keep_alive_;
  std::vector<std::thread> workers_;
};
}  // namespace anbox
```
> file: anbox/src/anbox/runtime.h

`anbox::Runtime` 类封装了一个 `boost::asio::io_service` 对象及多个工作线程 `std::thread`，它还继承 `std::enable_shared_from_this` 以获得从 `this` 指针创建智能指针 `std::shared_ptr` 的能力，同时继承了 `DoNotCopyOrMove`，以禁掉类的拷贝和移动操作。


`anbox::Runtime` 类有两大职责:

- 一是 `boost::asio::io_service` 对象的生命周期管理；
- 二是向 `boost::asio::io_service` 中提交任务。

在 `anbox::Runtime::start()` 函数中创建并启动多个线程，执行一个执行 `boost::asio::io_service::run()` 函数的函数 `exception_safe_run()`。在 `anbox::Runtime::stop()` 函数中停掉 `boost::asio::io_service` 的执行。`anbox::Runtime` 的析够函数中，还会调用 `stop()` 函数停掉 `boost::asio::io_service` 的执行。`anbox::Runtime` 的类型为 `boost::asio::io_service::work` 的成员变量 `keep_alive_` 也是用于管理 `boost::asio::io_service` 对象的生命周期的，该对象在析够时也会停掉 `boost::asio::io_service` 的执行。

Anbox 的 I/O 模型可以理解为，底层有一个多路复用器或事件循环 `boost::asio::io_service`，有一个包含了 8 个线程的线程池基于此 `boost::asio::io_service` 运行，处理 I/O 事件及其它各种类型的任务。

Anbox 需要处理如下这样一些网络 I/O 过程：

- 监听 Unix 域 Socket 接受连接。Anbox 的 SessionManager 通过 Unix 域 Socket 与 ContainerManager 进行通信，同时也通过 Unix 域 Socket 与 ContainerManager 启动的 Android 容器内的应用程序通信。首先 ContainerManager 监听在特定位置的 Unix 域 Socket 上。随后 SessionManager 监听几个位置上的 Unix 域 Socket，然后请求 ContainerManager 启动 Android 容器，并将这几个 Unix 域 Socket 映射到容器内的 `/dev/` 目录下。Android 容器启动后，一些进程，如 surfaceflinger、cameraservice 等连接这些 Unix 域 Socket，并通过这些 Unix 域 Socket 与 SessionManager 通信，进而操作宿主机的硬件设备。
- 监听 TCP Socket 接受连接。Anbox 的 SessionManager 作为容器中运行的 Android 与 ADB 进行通信的桥梁，它在与容器中运行的 Android 通过 Unix 域 Socket 通信的同时，也需要与宿主机上的 ADB 通信。SessionManager 通过 TCP 与宿主机上的 ADB 守护进程通信。如同模拟器等 Android 设备一样，SessionManager 遵从 ADB 的通信协议，在发起与 ADB 之间的 TCP 连接的同时，也需要监听一个 TCP 端口，等待 ADB 守护进程发起的连接，以完成整个 ADB 协议。
- 处理从监听的 Unix 域 Socket 接受的 Unix 域 Socket。监听的 Unix 域 Socket 接受新连接之后，需要将新创建的 Unix 域 Socket 提交给底层的 I/O 多路复用器，并为该 Socket 提供读写等 I/O 事件处理处理回调，以完成 Anbox 的应用逻辑。
- 处理从监听的 TCP Scoket 接受的 TCP Socket。监听的 TCP Socket 接受新连接之后，需要将新创建的 TCP Socket 提交给底层的 I/O 多路复用器，并为该 Socket 提供读写等 I/O 事件处理处理回调，以完成 Anbox 的应用逻辑。
- 发起一个到 TCP 服务器的连接。如前面提到的，Anbox 的 SessionManager 通过 TCP 连接与 ADB 守护进程通信，它会先发起一个到 ADB 守护进程的 TCP 连接。
- 发起一个到 Unix 域 Socket 服务的连接。Anbox 的 SessionManager 与 ContainerManager 之间通过 Unix 域 Socket 通信，SessionManager 会发起到 ContainerManager 监听的 Unix 域 Socket 服务的连接。


## 参考

- [boost::asio::io_service::strand Class Reference](http://charette.no-ip.com:81/programming/doxygen/boost/classboost_1_1asio_1_1io__service_1_1strand.html)
- [Boost.Asio](https://www.boost.org/doc/libs/1_72_0/doc/html/boost_asio.html)
- [Boost.Asio入门](https://mmoaay.gitbooks.io/boost-asio-cpp-network-programming-chinese/content/Chapter1.html)
