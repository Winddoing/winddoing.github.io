---
layout: post
title: H264编码——POC
date: '2022-10-12 09:26'
tags:
  - h264
categories:
  - 多媒体
  - H264
abbrlink: c614239b
---


POC（picture order count）:图像播放顺序号,在编解码中`视频编码顺序`与`视频的播放顺序`，并不完全相同.

视频编码时，如果采用了B帧编码，由于B帧很多时候都是双向预测得来的，这时会先编码B帧的后向预测图像（P帧），然后再进行B帧编码，因此会把视频原来的播放顺序打乱，以新的编码顺序输出码流而在解码断接收到码流后，需要把顺序还原成原本的播放顺序，以输出正确的视频。

> B帧的存在导致播放顺序POC和解码顺序frame_num不一致


<!--more-->

## 编码顺序、frame_num和POC

### 编码顺序

H.264的`码流输出顺序`便是`编码顺序`，所以在编码B帧的时候，由于B是双向预测，需要先编码后面编码帧P/I，这时候先输出I/P，后面才有B帧，我们在解码段拿到相应的I/P帧后，不能马上丢到buffer list里面，还需要等待后面的B帧，解码B帧后再reorder。

### frame_num

每个参考帧都有一个依次连续的`frame_num`作为它们的标识,这指明了各图像的解码顺序。在非参考帧的slice header中也会出现frame_num，不过该语法元素只有在参考帧才有意义。

H.264 对frame_num的值作了如下规定：
当参数集中的句法元素`gaps_in_frame_num_value_allowed_flag`不为1时，每个图像的frame_num值是它前一个参考帧的frame_num值增加1。这句话包含有两层意思。
- 当gaps_in_frame_num_value_allowed_flag等于`0`，即frame_num连续的情况下，每个图像的frame_num由前一个参考帧图像对应的值加1，着重点是“前一个参考帧”。
- 当gaps_in_frame_num_value_allowed_flag等于`1`，这时若网络阻塞，编码器可以将编码后的若干图像丢弃，而不用另行通知解码器。在这种情况下，解码器必须有机制将缺失的frame_num及所对应的图像填补，否则后续图像若将运动矢量指向缺失的图像将会产生解码错误。

`frame_num`是循环计数的，即当它到达MaxFrameNum后又从0 重新开始新一轮的计数。解码器必须要有机制检测这种循环，

### POC

Picture Order Count，即图像顺序号，主要用于标识图象的播放顺序，同时还用于在对帧间预测片解码时，标记参考图像的初始图像序号，表明下列情况下帧或场之间的图像序号差别：

1. 使用时间直接预测模式的运动矢量推算时；
2. B片中使用固有模式加权预测时；
3. 解码器一致性检测时。


## POC用途

- 主要用于标识图像的播放顺序
  - 在标识图像的播放顺序时，POC=`高位Msb`+`低位Lsb`(按值相加，而非按位相加)
  ```
  POC低位：pic_order_cnt_lsb = POC % MaxPicOrderCntLsb
　　　　		所占长度：log2_max_pic_order_cnt_lsb_minus4 + 4 个比特
　　　　		大小范围：[0 ， MaxPicOrderCntLsb – 1]
　　　　		注：MaxPicOrderCntLsb = 2^（log2_max_pic_order_cnt_lsb_minus4 + 4）
  POC高位：pic_order_cnt_msb = POC - pic_order_cnt_lsb 【是MaxPicOrderCntLsb的整数倍】
  ```

- 在对帧间预测片解码时，标记参考图像的初始图像序号，表明下列情况下帧或场之间的图像序号差别：
  - 使用时间直接预测模式的运动矢量推算时；
  - B片中使用固有模式加权预测时；
  - 解码器一致性检测时；

## POC有三类种类型

- pic_order_cnt_type = 0，把POC的低位（LSB）编进码流内  
- pic_order_cnt_type = 1，依赖frame_num求解POC  
- pic_order_cnt_type = 2，显示顺序与解码顺序一致，不能出现B帧

区别：

| pic_order_cnt_type | bit消耗                    | 序列要求                                                                          |
|:------------------:|:---------------------------|:----------------------------------------------------------------------------------|
|         0          | 最多(大量的lsb)            | 无要求                                                                            |
|         1          | 在sps和slice_header传递bit | POC周期变化                                                                       |
|         2          | 无需消耗bit                | 限制最大(直接从frame_num获取，POC和frmae_num必须一致，不能有B帧，可以有非参考P帧) |


## POC值的计算

这里只计算`pic_order_cnt_type=2`的情况，因为目前解码码流中使用的是该方法，并且也是计算最简单的。
这种方式`不能出现连续的非参考帧`并且`解码输出顺序和显示顺序一致`，也就是不能出现B帧，但可以出现不做参考的P场。

计算方法：直接通过frame_num推导，应用在没有连续的非参考帧的情况下（即一个间隔最多只能包含一个非参考帧）。

```
int iFrameNumOffset;
uint32_t uMaxFrameNum = 1 << (pSlice->pSPS->log2_max_frame_num_minus4 + 4);

if(bIsIDR)
  iFrameNumOffset = 0;
else if(pCtx->iPrevFrameNum > pSlice->frame_num)
  iFrameNumOffset = pCtx->iPrevFrameNumOffset + uMaxFrameNum;
else
  iFrameNumOffset = pCtx->iPrevFrameNumOffset;

int iTempPicOrderCnt;

if(bIsIDR)
  iTempPicOrderCnt = 0;
else if(!pSlice->nal_ref_idc)
  iTempPicOrderCnt = 2 * (iFrameNumOffset + pSlice->frame_num) - 1;
else
  iTempPicOrderCnt = 2 * (iFrameNumOffset + pSlice->frame_num);
```
> H264中pic_order_cnt_type=2时对POC的计算

也就是每一帧的POC值是不同的，因为每一帧的frame_num是不同的（不断累加）。

如果POC值不变时就表明，解码器没有进行解码操作。

## 总结

- POC值表示了解码后图像的显示顺序
- POC值也可以反映解码器的解码状态，比如在硬核解码时，如果读取的POC值在一定时间内没有发生变化，可以认为解码器不进行解码了。


## 参考

- [H264---播放顺序POC（pic_order_cnt）---pic_order_cnt_type=0、1、2 + POC和framenum比较](https://blog.csdn.net/qq_42024067/article/details/107535673)
- [H.264/AVC学习-POC计算](https://blog.csdn.net/qq_42139383/article/details/115357494)
- [h.264的POC计算](https://www.cnblogs.com/TaigaCon/p/3551001.html)
- [编码顺序、frame_num和POC](https://blog.csdn.net/yu_yuan_1314/article/details/9011899)
