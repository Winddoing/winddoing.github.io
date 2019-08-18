---
layout: post
title: Virtio-GPU相关
date: '2019-08-18 20:27'
tags:
  - virtio
  - GPU
categories:
  - 设备驱动
---

> For containers in virtualized environments, they are working on accelerated OpenGL ES 2.0 support with that being the lowest common denominator for many mobile platforms. This virtual GPU access they are pursuing is making use of Red Hat's work on Virgil3D as the Gallium3D-based solution for graphics pass-through to the host. Then for the kernel bits are VirtIO-GPU and on the host is the Virgl Renderer with QEMU.

![virtio-gpu-qemu-layer](/images/2019/08/virtio_gpu_qemu_layer.png)M

<!--more-->

## Virgil
> Virgil is an effort to provide 3D acceleration using `Gallium3D` for QEMU+KVM virtual machine guests.

- [Virgil Linux News](https://www.phoronix.com/scan.php?page=search&q=Virgil)

## GPU Driver

- [Linux GPU Driver Developer’s Guide](https://blog.csdn.net/u012839187/article/details/89875800)


## 参考

- [virtio-gpu-wddm-dod](https://gitlab.com/spice/win32/virtio-gpu-wddm-dod)
- [OpenGL ICD for Virtio-GPU Windows driver(Github)](https://github.com/Keenuts/virtio-gpu-win-icd)
