---
title: eMMC中的HPI
categories: 设备驱动
tags:
  - emmc
abbrlink: 14442
date: 2017-12-02 02:07:24
---

在某些情景下，不同类型的数据对于Host来讲可能会有不同的优先级。比如在写指定的数据的时候，由于写数据会消耗掉很多的时间，当用于想要立即进行另外一个操作的时候，就必须项办法抑制住当前的写操作来实现分页操作的需求。

>HPI(High Priority Interrupt)高优先级中断，该机制可以中断一些还没有完成的优先级比较低的操作，来满足对高优先级操作的需求。

<!--more-->


HPI命令可以从一下两个命令中的任何一个来发送：

1.CMD12 - 基于STOP_TRANSMISSION命令，当HPI标志位置一的时候生效

2.CMD13 - 基于SEND_STATUS命令，当HPI标志位置一的时候生效

当HPI生效的时候，以上两个命令的参数必须设定为:

| RCA |  填充位 | HPI |
| :----: | :----: | :--:|
| [31:16]| [15:1] | [0] |

>填充位不影响参数配置


当在执行WRITE_MULTIPLE_BLOCK命令时(CMD 25)，设备会更新CORRECTLY_PRG_SECTORS_NUM(EXT_CSD[245:242])，这个值会根据目前成功写入的扇区(512B)数量来更新。当HPI生效之后，Host可以根据这个值来重新继续写入数据而不必从头开始写。

如果HPI中断了在Packed write command中的CMD25，CORRECTLY_PRG_SECTORS_NUM返回的是所有写命令积累起来的当前成功写入扇区的总数量，Host应当通过这个值计算出具体的中断的命令和扇区偏移地址。

在使用HPI功能之前，要先把在EXT_CSD里面[161]字节的HPI_MGMT，把HPI_EN置1


## 参考

1. [eMMC当中HPI的作用以及使用方法](http://blog.csdn.net/polley88/article/details/50457946)
