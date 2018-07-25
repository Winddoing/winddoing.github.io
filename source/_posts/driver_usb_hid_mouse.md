---
title: HID设备--开发板模拟鼠标
date: 2018-05-8 23:17:24
categories: 设备驱动
tags: [HID, 驱动]
---


HID

<!--more-->

## HID


## 鼠标裸数据

### 驱动：
```
Symbol: HIDRAW [=y]                                      
Type  : boolean                                          
Prompt: /dev/hidraw raw HID device support               
  Location:                                              
    -> Device Drivers                                    
      -> HID support                                     
        -> HID bus support (HID [=y])                    
```

### 读取数据

```
read(uibc->hid_fd, buf, sizeof(buf));
```

### 鼠标数据格式

鼠标的通信格式：4个字节

```
BYTE3 BYTE2 BYTE1 BYTE0
```
| Byte | BIT7 | BIT6 | BIT5 | BIT4 | BIT3 | BIT2 | BIT1 | BIT0 |
| :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| 0   | 1 表示Y坐标的变化量超出－256~255的范围, 0表示没有溢出 | 1表示X坐标的变化量超出－256~255的范围，0表示没有溢出 | Y坐标变化的符号位，1表示负数，即鼠标向下移动 | X   坐标变化的符号位，1表示负数，即鼠标向左移动 | 恒为1 | 1表示中键按下 | 1表示右键按下 | 1表示左键按下 |
| 1 | X坐标变化量，|与byte的|bit4组成|9位符号数,|负数表示向左移，|正数表右移。|用补码|表示变化量|
| 2 | Y坐标变化量，|与byte的|bit5组成|9位符号数，|负数表示向下移，|正数表上移。|用补码|表示变化量 |
| 3 | 滚轮变化。| - | - | - | - | - | - | - |

鼠标的一次点击，包含`按下`和`抬起`两个动作，这两个动作均会上报事件，`抬起`时上报的全部为`0x0`

```
uibc read device raw data[len: 6]: BIT5~BIT0    //按下左键
                00 00 00 00 00 01
uibc read device raw data[len: 6]: BIT5~BIT0    //抬起左键    
                00 00 00 00 00 00
```

## 开发板模拟鼠标

以开发板作为device端,由于鼠标为HID设备，在HID驱动中添加鼠标的device

参考文档：[Documentation/usb/gadget_hid.txt](https://elixir.bootlin.com/linux/v3.4.35/source/Documentation/usb/gadget_hid.txt), 其中主要时驱动的添加和测试

### Device驱动

```
/*hid descriptor for a mouse*/                                                  
static struct hidg_func_descriptor vx_device_mouse_data = {                     
    .subclass = 0,  /*NO SubClass*/                                             
    .protocol = 2,  /*Mouse*/                                                   
    .report_length = 6,                                                         
    .report_desc_length = 79,                                                   
    .report_desc={                                                              
        0x05,0x01,  /*Usage Page (Generic Desktop Controls)*/                   
        0x09,0x02,  /*Usage (Mouse)*/                                           
        0xa1,0x01,  /*Collction (Application)*/                                 
        0x09,0x01,  /*Usage (pointer)*/                                         
        0xa1,0x00,  /*Collction (Physical)*/                                    
        0x05,0x09,  /*Usage Page (Button)*/                                     
        0x19,0x01,  /*Usage Minimum(1)*/                                                                  
        0x29,0x05,  /*Usage Maximum(3) */                                       
        0x15,0x00,  /*Logical Minimum(1)*/                                      
        0x25,0x01,  /*Logical Maximum(1)*/                                      
        0x95,0x05,  /*Report Count(5)  */                                       
        0x75,0x01,  /*Report Size(1)*/                                          
        0x81,0x02,  /*Input (Data,Var,Abs,NWrp,Lin,Pref,NNul,Bit)*/             
        0x95,0x01,  /*Report Count(1)*/                                         
        0x75,0x03,  /*Report Size(3) */                                         
        0x81,0x01,  /*Input (Cnst,Ary,Abs) */                                   
        0x05,0x01,  /*Usage Page (Generic Desktop Controls)*/                   
        0x09,0x30,  /*Usage(x)*/                                                
        0x09,0x31,  /*Usage(y)*/                                                
        0x16,0x00,0xF8,  /*Logical Minimum (-2048)*/                            
        0x26,0xFF,0x07,  /*Logical Maximum (2047)*/                             
        0x75,0x0C, /*Report Size(12)*/                                          
        0x95,0x02, /*Report Count(2) */                                         
        0x81,0x06, /*Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit)*/              
        0x09,0x38,  /*Usage(Wheel)*/                                            
        0x15,0x81,  /*Logical Minimum(-127)*/                                   
        0x25,0x7f,  /*Logical Maximum(127)*/                                    
        0x75,0x08,  /*Report Size(8)*/                                          
        0x95,0x01,  /*Report Count(1)  */                                       
        0x81,0x06,  /*Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit)*/             
        0x05,0x0C, /*Usage Page (Consumer Devices) */                           
        0x0A,0x38,0x02, /*Usage (AC Pan)*/                                      
        0x95,0x01, /*Report Count (1) */                                        
        0x75,0x08, /*Report Size (8)*/                                          
        0x15,0x81, /*Logical Minimum (-127) */                                  
        0x25,0x7F, /*Logical Maximum (127)*/                                    
        0x81,0x06, /*Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) */             
        0xc0,   /*End Collection*/                                              
        0xc0    /*End Collection*/                                              
    }                                                                           
};                                                                              

static struct platform_device vx_device_hid_mouse = {                 
    .name = "hidg",                                                   
    .id            = 1,                                               
    .num_resources = 0,                                               
    .resource    = 0,                                                 
    .dev.platform_data = &vx_device_mouse_data,                       
};                                                                    

static int __init hidg_init(void)                                               
{                                                                               
    int status;                                                                 

    status = platform_device_register(&vx_device_hid_mouse);                    
    if (status < 0) {                                                           
        printk("f:%s, l:%d, platform_driver hid mouse error\n", __func__, __LINE__);
        return status;                                                          
    }                                                                           

}                                                                               
module_init(hidg_init);                                                         
```
>kernel: linux3.4.35, file:drivers/usb/gadget/hid.c

### hidg_func_descriptor

```
struct hidg_func_descriptor {                          
    unsigned char       subclass;                      
    unsigned char       protocol;                      
    unsigned short      report_length;                 
    unsigned short      report_desc_length;            
    unsigned char       report_desc[];                 
};                                                     
```
>file: include/linux/usb/g_hid.h

主要是一个设备如何填充`struct hidg_func_descriptor`数据结构。

> You can add as many HID functions as you want, only limited by the amount of interrupt endpoints your gadget driver supports.

添加`hidg`设备的个数，受USB的endpoint的限制，如果endpoint只有一对，只能添加一个`hidg0`设备。

### 获取USB鼠标HID Descriptor

* 工具：`USBlyzer`
* 官网下载地址：[http://www.usblyzer.com/download.htm](http://www.usblyzer.com/download.htm)
* 下载：[http://bbs.armfly.com/job.php?action=download&aid=9919](http://bbs.armfly.com/job.php?action=download&aid=9919)

#### Device Descriptor

```
Device Descriptor USB OPTICAL MOUSE
Offset Field Size Value Description
0 bLength 1 12h  
1 bDescriptorType 1 01h Device
2 bcdUSB 2 0110h USB Spec 1.1
4 bDeviceClass 1 00h Class info in Ifc Descriptors
`5 bDeviceSubClass 1 00h`  
6 bDeviceProtocol 1 00h  
7 bMaxPacketSize0 1 08h 8 bytes
8 idVendor 2 0101h  
10 idProduct 2 0007h  
12 bcdDevice 2 0100h 1.00
14 iManufacturer 1 00h  
15 iProduct 1 01h "USB OPTICAL MOUSE "
16 iSerialNumber 1 00h  
17 bNumConfigurations 1 01h  
```
### Interface Descriptor

```
Interface Descriptor 0/0 HID, 1 Endpoint
Offset Field Size Value Description
0 bLength 1 09h  
1 bDescriptorType 1 04h Interface
2 bInterfaceNumber 1 00h  
3 bAlternateSetting 1 00h  
4 bNumEndpoints 1 01h  
5 bInterfaceClass 1 03h HID
6 bInterfaceSubClass 1 01h Boot Interface
`7 bInterfaceProtocol 1 02h Mouse`
8 iInterface 1 00h  
```

#### HID Descriptor

```
HID Descriptor
Offset Field Size Value Description
0 bLength 1 09h  
1 bDescriptorType 1 21h HID
2 bcdHID 2 0111h 1.11
4 bCountryCode 1 00h  
5 bNumDescriptors 1 01h  
6 bDescriptorType 1 22h Report
`7 wDescriptorLength 2 004Fh 79 bytes`

Endpoint Descriptor 81 1 In, Interrupt, 10 ms
Offset Field Size Value Description
0 bLength 1 07h  
1 bDescriptorType 1 05h Endpoint
2 bEndpointAddress 1 81h 1 In
3 bmAttributes 1 03h Interrupt
 1..0: Transfer Type  ......11  Interrupt
 7..2: Reserved  000000..   
`4 wMaxPacketSize 2 0006h 6 bytes`
6 bInterval 1 0Ah 10 ms

Interface 0 HID Report Descriptor Mouse
`Item Tag (Value) Raw Data`
Usage Page (Generic Desktop) 05 01  
Usage (Mouse) 09 02  
Collection (Application) A1 01  
    Usage (Pointer) 09 01  
    Collection (Physical) A1 00  
        Usage Page (Button) 05 09  
        Usage Minimum (Button 1) 19 01  
        Usage Maximum (Button 5) 29 05  
        Logical Minimum (0) 15 00  
        Logical Maximum (1) 25 01  
        Report Count (5) 95 05  
        Report Size (1) 75 01  
        Input (Data,Var,Abs,NWrp,Lin,Pref,NNul,Bit) 81 02  
        Report Count (1) 95 01  
        Report Size (3) 75 03  
        Input (Cnst,Ary,Abs) 81 01  
        Usage Page (Generic Desktop) 05 01  
        Usage (X) 09 30  
        Usage (Y) 09 31  
        Logical Minimum (-2048) 16 00 F8  
        Logical Maximum (2047) 26 FF 07  
        Report Size (12) 75 0C  
        Report Count (2) 95 02  
        Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) 81 06  
        Usage (Wheel) 09 38  
        Logical Minimum (-127) 15 81  
        Logical Maximum (127) 25 7F  
        Report Size (8) 75 08  
        Report Count (1) 95 01  
        Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) 81 06  
        Usage Page (Consumer Devices) 05 0C  
        Usage (AC Pan) 0A 38 02  
        Report Count (1) 95 01  
        Report Size (8) 75 08  
        Logical Minimum (-127) 15 81  
        Logical Maximum (127) 25 7F  
        Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) 81 06  
    End Collection C0  
End Collection C0  
```

### hidg_func_descriptor 与 HID Descriptor


| hidg_func_descriptor | HID Descriptor |
| :------------------: | :------------: |
|   subclass           | bDeviceSubClass    |
|   protocol           | bInterfaceProtocol |
|   report_length      | wMaxPacketSize     |
|   report_desc_length | wDescriptorLength  |
|   report_desc[]      | Item Tag (Value) Raw Data |



## 调试

`Bus Hound`是一个超级软件总线协议分析器,用于捕捉来自设备的协议包和输入输出操作


## 参考

1. [s3c6410 linux gadget hid驱动](https://blog.csdn.net/hclydao/article/details/9284215)
2. [DM816X 实现 USB HID Gadget 鼠标键盘功能](https://blog.csdn.net/miaopasi_QAQ/article/details/45479709)
3. [linux 读取 USB HID鼠标坐标和点击 在 LCD上显示](https://www.cnblogs.com/ningci/p/6807654.html)
4. [Linux之访问/dev/hidraw](https://blog.csdn.net/qq_33750826/article/details/79397984)
5. [USB与BT HID reports描述符实践与抓包分析](https://blog.csdn.net/sy373466062/article/details/78223563)
6. [usb hid gadget模拟鼠标键盘](https://blog.csdn.net/luckywang1103/article/details/41282551)
7. [USB/HID设备报告描述符详解](http://blog.chinaunix.net/uid-23215128-id-2521477.html)
