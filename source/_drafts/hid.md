# hid


## R

1. R/S建立socket连接（UDP）
2. 监控HID设备的事件（select）
3. 如果事件被触发，读取事件信息进行传输到S端

两个线程，子线程负责HID设备的事件监听

网络连接，可以使用不同的端口

### 读取事件数据，为什么一次读取128bit,为什么只有读取的时数据长度为64bit时发送


### 数据传输时以什么格式（mNetSession）


### M1、M3、M5等都是Wi-Fi Display技术规范
https://blog.csdn.net/innost/article/details/8474683


/dev/hidraw2   android

/dev/input/mouse1  linux

dinfo: bustype:[0x00000003], vendor:[0x0101], product:[0x0007]
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]




## S    

1. 添加mouse设备驱动
2. 创建子线程，a）建立socket连接；b）轮询查找uibc进行读数



### signal

```
signal(SIGPIPE, SIG_IGN);
```
https://blog.csdn.net/sukhoi27smk/article/details/43760605
实际这个函数的目的就是防止程序收到SIGPIPE后自动退出   


### select

FD_ISSET
判断描述符fd是否在给定的描述符集fdset中，通常配合select函数使用，由于select函数成功返回时会将未准备好的描述符位清零。通常我们使用FD_ISSET是为了检查在select函数返回后，某个描述符是否准备好，以便进行接下来的处理操作。


### HID驱动

/dev/hidg0


S端相当于device端，模拟鼠标的输入

[usb hid gadget驱动](https://blog.csdn.net/abcamus/article/details/52980107?locationNum=5&fps=1)


access_ok | 检查用户空间内存块是否可用   

ifconfig eth1 up
ifconfig eth1 192.168.1.111 netmask 255.255.255.0

tftp -gr vx_uibc 192.168.1.11 | chmod +x vx_uibc




编译kernel找不到指定的defconfig

修改Makefile

ARCH        ?= arm


编译模块：

make  modules




## 驱动模块加载


tftp -gr g_hid.ko 192.168.1.11
tftp -gr dwc_otg.ko 192.168.1.11


~ # insmod g_hid.ko
g_hid: Unknown symbol usb_gadget_probe_driver (err 0)
g_hid: Unknown symbol usb_gadget_unregister_driver (err 0)
insmod: can't insert 'g_hid.ko': unknown symbol in module, or unknown parameter


insmod dwc_otg.ko
insmod g_hid.ko

modinfo  ./ixgbe.ko | grep depend   找模块的依赖，结果如下，
depends:        mdio, dca
然后再执行：
modprobe dca
modprobe mdio
insmod ./ixgbe.ko

## 模拟鼠标


识别的设备信息：lsusb

```
Bus 002 Device 004: ID 0525:a4ac Netchip Technology, Inc.
```

驱动中的定义：
```
#define HIDG_VENDOR_NUM     0x0525  /* XXX NetChip */                     
#define HIDG_PRODUCT_NUM    0xa4ac  /* Linux-USB HID gadget */             
```

cat  /sys/kernel/debug/usb/devices   

cat  /proc/bus/input/devices

```
#lsusb -d 0525:a4ac -v

Bus 002 Device 004: ID 0525:a4ac Netchip Technology, Inc.
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x0525 Netchip Technology, Inc.
  idProduct          0xa4ac
  bcdDevice            3.99
  iManufacturer           1 Linux 3.4.35 with dwc_otg_pcd
  iProduct                2 HID Gadget
  iSerial                 0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           34
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0
    bmAttributes         0xc0
      Self Powered
    MaxPower                2mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         3 Human Interface Device
      bInterfaceSubClass      0 No Subclass
      bInterfaceProtocol      2 Mouse
      iInterface              3 HID Interface
        HID Device Descriptor:
          bLength                 9
          bDescriptorType        33
          bcdHID               1.01
          bCountryCode            0 Not supported
          bNumDescriptors         1
          bDescriptorType        34 Report
          wDescriptorLength      52
         Report Descriptors:
           ** UNAVAILABLE **
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0004  1x 4 bytes
        bInterval               4
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0001
  Self Powered

```
## struct hidg_func_descriptor

结构体含义：

``` C
/*hid descriptor for a mouse*/                                             
static struct hidg_func_descriptor vx_device_mouse_data = {                
    .subclass = 0,  /*NO SubClass*/                                        
    .protocol = 2,  /*Mouse*/                                              
    .report_length = 4,                                                    
    .report_desc_length = 52,                                              
    .report_desc={                                                         
        0x05,0x01,  /*Usage Page (Generic Desktop Controls)*/              
        0x09,0x02,  /*Usage (Mouse)*/                                      
        0xa1,0x01,  /*Collction (Application)*/                            
        0x09,0x01,  /*Usage (pointer)*/                                    
        0xa1,0x00,  /*Collction (Physical)*/                               
        0x05,0x09,  /*Usage Page (Button)*/                                
        0x19,0x01,  /*Usage Minimum(1)*/                                   
        0x29,0x03,  /*Usage Maximum(3) */                                  
        0x15,0x00,  /*Logical Minimum(1)*/                                 
        0x25,0x01,  /*Logical Maximum(1)*/                                 
        0x95,0x03,  /*Report Count(5)  */                                  
        0x75,0x01,  /*Report Size(1)*/                                     
        0x81,0x02,  /*Input(Data,Variable,Absolute,BitFiled)*/             
        0x95,0x01,  /*Report Count(1)*/                                    
        0x75,0x05,  /*Report Size(5) */                                    
        0x81,0x01,  /*Input(Constant,Array,Absolute,BitFiled) */           
        0x05,0x01,  /*Usage Page (Generic Desktop Controls)*/              
        0x09,0x30,  /*Usage(x)*/                                           
        0x09,0x31,  /*Usage(y)*/                                           
        0x09,0x38,  /*Usage(Wheel)*/                                       
        0x15,0x81,  /*Logical Minimum(-127)*/                              
        0x25,0x7f,  /*Logical Maximum(127)*/                               
        0x75,0x08,  /*Report Size(8)*/                                     
        0x95,0x02,  /*Report Count(2)  */                                  
        0x81,0x06,  /*Input(Data,Variable,Relative,BitFiled)*/             
        0xc0,   /*End Collection*/                                         
        0xc0    /*End Collection*/                                         
    }                                                                      
};                                                                         
```
