---
layout: post
title: DRM笔记——驱动初始化
date: '2020-12-03 14:04'
tags:
  - gpu
  - drm
  - driver
  - kernel
categories:
  - 设备驱动
abbrlink: '53854910'
---

drm的驱动加载主要是为了实现各种回调函数的注册，初始化时主要实现的数据结构是`struct drm_driver`

这里以virtio-gpu为例，了解drm驱动的初始化

<!--more-->


```
module_virtio_driver(virtio_gpu_driver);
  \->.probe = virtio_gpu_probe (driver与devices匹配后的入口函数)
    \-> drm_dev_alloc(&driver, &vdev->dev); -- 申请和初始化struct drm_driver结构体
```

## `struct drm_driver`初始化

``` C
static struct drm_driver driver = {
    //drm驱动的功能特性
    .driver_features = DRIVER_MODESET | DRIVER_GEM | DRIVER_RENDER | DRIVER_ATOMI
    //用于设置驱动程序-私有数据结构，如缓冲区分配器、执行上下文（上下文ID）或类似内容
    .open = virtio_gpu_driver_open,
    //与open相对应，用于open接口申请资源的释放
    .postclose = virtio_gpu_driver_postclose,

    //创建dumb buffer （用户通过 ioctl 调用）
    .dumb_create = virtio_gpu_mode_dumb_create,
    //在drm设备节点的地址空间中分配偏移量，以便能够存储映射一个dumb buffer  （用户通过 ioctl 调用）
    .dumb_map_offset = virtio_gpu_mode_dumb_mmap,

#if defined(CONFIG_DEBUG_FS)
    .debugfs_init = virtio_gpu_debugfs_init,
#endif
    //Main PRIME export function（输出）
    .prime_handle_to_fd = drm_gem_prime_handle_to_fd,
    //Main PRIME import function（输入）
    .prime_fd_to_handle = drm_gem_prime_fd_to_handle,
    //用于实现dma-buf mmap
    .gem_prime_mmap = drm_gem_prime_mmap,
    //export接口钩子GEM驱动
    .gem_prime_export = virtgpu_gem_prime_export,
    //import接口钩子GEM驱动
    .gem_prime_import = virtgpu_gem_prime_import,
    //
    .gem_prime_import_sg_table = virtgpu_gem_prime_import_sg_table,

    //GEM对象的构造函数
    .gem_create_object = virtio_gpu_create_object,
    //DRM 设备节点的文件操作
    .fops = &virtio_gpu_driver_fops,

    //驱动私有的IOCTL描述条目数组
    .ioctls = virtio_gpu_ioctls,
    .num_ioctls = DRM_VIRTIO_NUM_IOCTLS,

    .name = DRIVER_NAME,
    .desc = DRIVER_DESC,
    .date = DRIVER_DATE,
    .major = DRIVER_MAJOR,
    .minor = DRIVER_MINOR,
    .patchlevel = DRIVER_PATCHLEVEL,
    //用于在释放最终引用后销毁设备数据
    .release = virtio_gpu_release,
};
```
