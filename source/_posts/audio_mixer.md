---
title: 音频混音
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
abbrlink: 5658a503
date: 2017-07-14 23:07:24
---

## 混音原理

将两个音源进行混合输出(如果多个音源的混音,个人理解将第一次混音数据个下一个音源再次混音)

<!--more-->

## 混音算法

### 线性叠加后求平均

> 优点：不会产生溢出，噪音较小；
> 缺点：衰减过大，影响通话质量；

实现: **(A + B) / 2**

```
short  remix(short buffer1,short buffer2)  
{  
    int value = buffer1 + buffer2;  
    return (short)(value/2);  
}
```

### 归一化混音(自适应加权混音算法)

> 思路：使用更多的位数(32 bit)来表示音频数据的一个样本，混完音后在想办法降低其振幅，使其仍旧分布在16 bit所能表示的范围之内，这种方法叫做归一法；

方法：为避免发生溢出，使用一个可变的衰减因子对语音进行衰减。这个衰减因子也就代表语音的权重，衰减因子随着音频数据的变化而变化，所以称为自适应加权混音。当溢出时，衰减因子较小，使得溢出的数据在衰减后能够处于临界值以内，而在没有溢出时，又让衰减因子慢慢增大，使数据较为平缓的变化。

``` C
#include <stdio.h>  
#include <stdlib.h>  
#include <math.h>  

#define IN_FILE1 "1.wav"  
#define IN_FILE2 "2.wav"  
#define OUT_FILE "remix.pcm"  

#define SIZE_AUDIO_FRAME (2)  

void Mix(char sourseFile[10][SIZE_AUDIO_FRAME],int number,char *objectFile)  
{  
	//归一化混音  
	int const MAX=32767;  
	int const MIN=-32768;  

	double f=1;  
	int output;  
	int i = 0,j = 0;  
	for (i=0;i<SIZE_AUDIO_FRAME/2;i++) {  
		int temp=0;  
		for (j=0;j<number;j++)  
			temp+=*(short*)(sourseFile[j]+i*2);  
		output=(int)(temp*f);  
		if (output>MAX) {  
			f=(double)MAX/(double)(output);  
			output=MAX;  
		}  
		if (output<MIN) {  
			f=(double)MIN/(double)(output);  
			output=MIN;  
		}  
		if (f<1)  
			f+=((double)1-f)/(double)32;  

		*(short*)(objectFile+i*2)=(short)output;  
	}  
}  

int main()  
{  
	FILE * fp1,*fp2,*fpm;  
	fp1 = fopen(IN_FILE1,"rb");  
	fp2 = fopen(IN_FILE2,"rb");  
	fpm = fopen(OUT_FILE,"wb");  

	short data1,data2,date_mix;  
	int ret1,ret2;  
	char sourseFile[10][2];  

	while(1) {  
		ret1 = fread(&data1,2,1,fp1);  
		ret2 = fread(&data2,2,1,fp2);  
		*(short*) sourseFile[0] = data1;  
		*(short*) sourseFile[1] = data2;  

		if(ret1>0 && ret2>0) {  
			Mix(sourseFile,2,(char *)&date_mix);  
			/*
			   if( data1 < 0 && data2 < 0)
			   date_mix = data1+data2 - (data1 * data2 / -(pow(2,16-1)-1));
			   else
			   date_mix = data1+data2 - (data1 * data2 / (pow(2,16-1)-1));
			   */  

			if(date_mix > pow(2,16-1) || date_mix < -pow(2,16-1))  
				printf("mix error\n");  
		} else if( (ret1 > 0) && (ret2==0))  
			date_mix = data1;  
		else if( (ret2 > 0) && (ret1==0))  
			date_mix = data2;  
		else if( (ret1 == 0) && (ret2 == 0))  
			break;  
		fwrite(&date_mix,2,1,fpm);  
	}  
	fclose(fp1);  
	fclose(fp2);  
	fclose(fpm);  
	printf("Done!\n");  
}  
```
### 切割时间片，重采样算法

>可以把各个通道的声音叠到一起，让声音的采样率按倍增加，如果提高声音的播放频率，声音可以正常的播放，声音实现了叠加；如果不想修改声音的播放输出频率，可以通过声音的重采样后输出自己想要的输出频率；


## 参考

1. [Android音视频处理之音频混音](http://www.jianshu.com/p/6492f2a189cf)
2. [混音算法的学习与研究](http://www.cppblog.com/jinq0123/archive/2007/10/31/audiomixingstudy.html)
