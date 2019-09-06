---
layout: post
title: printk_ratelimit
date: '2019-09-06 10:15'
tags:
  - printk
categories:
  - Linux内核
---

在Linux内核代码里当需要限制`printk`打印频率时会用到`__ratelimit`或`printk_ratelimit`（封装了__ratelimit）

<!--more-->

`printk_ratelimit`默认允许在`5s`内最多打印`10`条消息出来

``` shell
$cat /proc/sys/kernel/printk_ratelimit
5
$cat /proc/sys/kernel/printk_ratelimit_burst
10
```

``` C
if (printk_ratelimit()) {                                                        
    dev_err(adev->dev, "GPU fault detected: %d 0x%08x\n",                        
        entry->src_id, entry->src_data[0]);                                      
    dev_err(adev->dev, "  VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x%08X\n",         
        addr);                                                                   
    dev_err(adev->dev, "  VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x%08X\n",         
        status);                                                                 
    gmc_v8_0_vm_decode_fault(adev, status, addr, mc_client);                     
}                                                                                
```

## 参考

- [限制printk打印频率函数printk_ratelimit](https://blog.csdn.net/lkkey80/article/details/45190095)
