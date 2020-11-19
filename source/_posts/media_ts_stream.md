---
title: TS流
categories: 多媒体
tags:
  - ts
abbrlink: 36727
date: 2018-07-16 08:07:24
---

TS流

<!--more-->

![TS](/images/media/TS.svg)

## 数据结构

### TS头

``` C
// Transport packet header
typedef struct TS_packet_header
{
	unsigned sync_byte                    : 8;	//同步字节, 固定为0x47,表示后面的是一个TS分组
	unsigned transport_error_indicator    : 1;	//传输误码指示符
	unsigned payload_unit_start_indicator : 1;	//效荷载单元起始指示符
	unsigned transport_priority           : 1;	//传输优先, 1表示高优先级,传输机制可能用到，解码用不着
	unsigned PID                          : 13;	//PID
	unsigned transport_scrambling_control : 2;	//传输加扰控制
	unsigned adaption_field_control       : 2;	//自适应控制 01仅含有效负载，10仅含调整字段，11含有调整字段和有效负载。为00解码器不进行处理
	unsigned continuity_counter           : 4;	//连续计数器 一个4bit的计数器，范围0-15
} TS_packet_header;
```

>TS包的标识(即sync_byte)为`0x47`，并且为了确保这个TS包里的数据有效，所以我们一开始查找`47 40 00`这三组16进制数
>> 包头大小: `4Byte`

* `adaption_field_control` : 调整字段控制
	- 0x00 : reserved for future use by ISO/IEC
	- 0x01 : 无调整字段,仅含有效负载
	- 0x10 : 仅含调整字段,无有效负载
	- 0x11 : 调整字段后含有效负载
```C
if (adaption_field_control == '10' || adaption_field_control == '11') {
        adaption_fields() //调整字段的处理
}
if (adaption_field_control == '01' || adaption_field_control == '11') {
	for(i = 0; i < N ; i++) //N值 = 184 - 调整字段的字节数
    {

    }
}
```
* `continuity_counter` : 用于对传输误码进行检测。在发送端对所有的包都做0-15的循环计数，在接收终端，如发现循环计数器的值有中断，表明数据在传输中有丢失。


### PAT

``` C
// Program Association Table
typedef struct PAT_Packet_tag
{
	unsigned table_id                        : 8;	//固定为0x00 ，标志是该表是PAT
	unsigned section_syntax_indicator        : 1; 	//段语法标志位，固定为1
	unsigned zero                            : 1; 	//0
	unsigned reserved_1                      : 2; 	//保留位
	unsigned section_length                  : 12;	//表示这个字节后面有用的字节数，包括CRC32
	unsigned transport_stream_id             : 16;	//该传输流的ID，区别于一个网络中其它多路复用的流
	unsigned reserved_2                      : 2; 	//保留位
	unsigned version_number                  : 5; 	//范围0-31，表示PAT的版本号
	unsigned current_next_indicator          : 1; 	//发送的PAT是当前有效还是下一个PAT有效
	unsigned section_number                  : 8; 	//分段的号码。PAT可能分为多段传输，第一段为00，以后每个分段加1，最多可能有256个分段
	unsigned last_section_number             : 8; 	//最后一个分段的号码
	// for(i=0; i<N; i++) {  //N = (section_length - 4(CRC的4Byte) - 5(section_lengt以后的5Byte))/4
	unsigned program_number                  : 16;
	unsigned reserved_3                      : 3;
	unsigned network_PID                     : 16;	// 或者program_map_PID
	// }
	unsigned CRC_32                          : 32;
} PAT_Packet;
```

### PMT

``` C
// Program Map Table
typedef struct PMT_Packet_tag
{
     unsigned table_id                        : 8;
     unsigned section_syntax_indicator        : 1;
     unsigned zero                            : 1;
     unsigned reserved_1                      : 2;
     unsigned section_length                  : 12;
     unsigned program_number                  : 16;
     unsigned reserved_2                      : 2;
     unsigned version_number                  : 5;
     unsigned current_next_indicator          : 1;
     unsigned section_number                  : 8;
     unsigned last_section_number             : 8;
     unsigned reserved_3                      : 3;
     unsigned PCR_PID                         : 13;
     unsigned reserved_4                      : 4;
     unsigned program_info_length             : 12;
     // for(i=0; i<N; i++) {
     unsigned stream_type                     : 8;
     unsigned reserved_5                      : 3;
     unsigned elementary_PID                  : 13;
     unsigned reserved_6                      : 4;
     unsigned ES_info_length                  : 12;
     // }
     unsigned CRC_32                          : 32;
} PMT_Packet;
```
## 数据包

```
1	0.000000000			MPEG TS	188	 Service Description Table (SDT)
2	0.000055764			MPEG TS	188	 Program Association Table (PAT)
3	0.000111529			MPEG TS	188	 Program Map Table (PMT)
4	0.000167294			MPEG TS	188	 [MP2T fragment of a reassembled packet]
......
```
>开始时解析到的数据包:`SDT->PAT->PMT`

SDT包只出现在TS文件的开头，而PAT和PMT包，每隔`42Packet`将出现一次。

### SDT

```
Frame 1: 188 bytes on wire (1504 bits), 188 bytes captured (1504 bits)
    Encapsulation type: ISO/IEC 13818-1 MPEG2-TS (138)
    Arrival Time: Jan  1, 1970 08:00:00.000000000 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 0.000000000 seconds
    [Time delta from previous captured frame: 0.000000000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.000000000 seconds]
    Frame Number: 1
    Frame Length: 188 bytes (1504 bits)
    Capture Length: 188 bytes (1504 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: mp2t:mpeg_sect:dvb_sdt]
ISO/IEC 13818-1 PID=0x11 CC=0
    Header: 0x47401110
        0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
        .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
        .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
        .... .... ..0. .... .... .... .... .... = Transport Priority: 0
        .... .... ...0 0000 0001 0001 .... .... = PID: Unknown (0x0011)
        .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
        .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
        .... .... .... .... .... .... .... 0000 = Continuity Counter: 0
    [MPEG2 PCR Analysis]
    Pointer: 0
DVB Service Description Table
    Table ID: Service Description Table (SDT), current network (0x42)
    1... .... .... .... = Syntax indicator: 1
    .111 .... .... .... = Reserved: 0x7
    .... 0000 0010 0101 = Length: 37
    Transport Stream ID: 0x0001
    11.. .... = Reserved: 0x3
    ..00 000. = Version Number: 0x00
    .... ...1 = Current/Next Indicator: Currently applicable (1)
    Section Number: 0
    Last Section Number: 0
    Original Network ID: 0xff01
    Reserved: 0xff
    Service 0x0001
        Service ID: 0x0001
        1111 11.. = Reserved: 0x3f
        .... ..0. = EIT Schedule Flag: 0
        .... ...0 = EIT Present Following Flag: 0
        100. .... .... .... = Running Status: Running (0x4)
        ...0 .... .... .... = Free CA Mode: Not Scrambled (0x0)
        .... 0000 0001 0100 = Descriptors Loop Length: 0x014
        Descriptor Tag=0x48
            Descriptor Tag: Service Descriptor (0x48)
            Descriptor Length: 18
            Service Type: digital television service (0x01)
            Provider Name Length: 6
            [Default character table (Latin)]
            Service Provider Name: FFmpeg
            Service Name Length: 9
            [Default character table (Latin)]
            Service Name: Service01
    CRC 32: 0x777c43ca [unverified]
    [CRC 32 Status: Unverified]
Stuffing
    Stuffing: ffffffffffffffffffffffffffffffffffffffffffffffff...
```

### PAT

```
Frame 2: 188 bytes on wire (1504 bits), 188 bytes captured (1504 bits)
    Encapsulation type: ISO/IEC 13818-1 MPEG2-TS (138)
    Arrival Time: Jan  1, 1970 08:00:00.000055764 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 0.000055764 seconds
    [Time delta from previous captured frame: 0.000055764 seconds]
    [Time delta from previous displayed frame: 0.000055764 seconds]
    [Time since reference or first frame: 0.000055764 seconds]
    Frame Number: 2
    Frame Length: 188 bytes (1504 bits)
    Capture Length: 188 bytes (1504 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: mp2t:mpeg_sect:mpeg_pat]
ISO/IEC 13818-1 PID=0x0 CC=0
    Header: 0x47400010
        0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
        .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
        .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
        .... .... ..0. .... .... .... .... .... = Transport Priority: 0
        .... .... ...0 0000 0000 0000 .... .... = PID: Program Association Table (0x0000)
        .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
        .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
        .... .... .... .... .... .... .... 0000 = Continuity Counter: 0
    [MPEG2 PCR Analysis]
    Pointer: 0    //自适应区,1Byte,如果为0 表示没有自适应区
MPEG2 Program Association Table
    Table ID: Program Association Table (PAT) (0x00)
    1... .... .... .... = Syntax indicator: 1
    .011 .... .... .... = Reserved: 0x3
    .... 0000 0000 1101 = Length: 13
    Transport Stream ID: 0x0001
    11.. .... = Reserved: 0x3
    ..00 000. = Version Number: 0x00
    .... ...1 = Current/Next Indicator: Currently applicable
    Section Number: 0
    Last Section Number: 0
    Program 0x0001 -> PID 0x1000
        Program Number: 0x0001
        111. .... .... .... = Reserved: 0x7
        ...1 0000 0000 0000 = Program Map PID: 0x1000
    CRC 32: 0x2ab104b2 [unverified]
    [CRC 32 Status: Unverified]
Stuffing
    Stuffing: ffffffffffffffffffffffffffffffffffffffffffffffff...
```

### PMT

```
Frame 3: 188 bytes on wire (1504 bits), 188 bytes captured (1504 bits)
    Encapsulation type: ISO/IEC 13818-1 MPEG2-TS (138)
    Arrival Time: Jan  1, 1970 08:00:00.000111529 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 0.000111529 seconds
    [Time delta from previous captured frame: 0.000055765 seconds]
    [Time delta from previous displayed frame: 0.000055765 seconds]
    [Time since reference or first frame: 0.000111529 seconds]
    Frame Number: 3
    Frame Length: 188 bytes (1504 bits)
    Capture Length: 188 bytes (1504 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: mp2t:mpeg_sect:mpeg_pmt]
ISO/IEC 13818-1 PID=0x1000 CC=0
    Header: 0x47500010
        0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
        .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
        .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
        .... .... ..0. .... .... .... .... .... = Transport Priority: 0
        .... .... ...1 0000 0000 0000 .... .... = PID: Unknown (0x1000)
        .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
        .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
        .... .... .... .... .... .... .... 0000 = Continuity Counter: 0
    [MPEG2 PCR Analysis]
    Pointer: 0
MPEG2 Program Map Table
    Table ID: Program Map Table (PMT) (0x02)
    1... .... .... .... = Syntax indicator: 1
    .011 .... .... .... = Reserved: 0x3
    .... 0000 0001 1101 = Length: 29
    Program Number: 0x0001
    11.. .... = Reserved: 0x3
    ..00 000. = Version Number: 0x00
    .... ...1 = Current/Next Indicator: Currently applicable (0x1)
    Section Number: 0
    Last Section Number: 0
    111. .... .... .... = Reserved: 0x7
    ...0 0001 0000 0000 = PCR PID: 0x0100
    1111 .... .... .... = Reserved: 0xf
    .... 0000 0000 0000 = Program Info Length: 0x000
    Stream PID=0x0100
        Stream type: AVC video stream as defined in ITU-T Rec. H.264 | ISO/IEC 14496-10 Video (0x1b)
        111. .... .... .... = Reserved: 0x7
        ...0 0001 0000 0000 = Elementary PID: 0x0100
        1111 .... .... .... = Reserved: 0xf
        .... 0000 0000 0000 = ES Info Length: 0x000
    Stream PID=0x0101
        Stream type: ISO/IEC 11172 Audio (0x03)
        111. .... .... .... = Reserved: 0x7
        ...0 0001 0000 0001 = Elementary PID: 0x0101
        1111 .... .... .... = Reserved: 0xf
        .... 0000 0000 0110 = ES Info Length: 0x006
        Descriptor Tag=0x0a
            Descriptor Tag: ISO 639 Language Descriptor (0x0a)
            Descriptor Length: 4
            ISO 639 Language Code: und
            ISO 639 Language Type: Undefined (0x00)
    CRC 32: 0x30afbe63 [unverified]
    [CRC 32 Status: Unverified]
Stuffing
    Stuffing: ffffffffffffffffffffffffffffffffffffffffffffffff...
```

### packet

```
Frame 4: 188 bytes on wire (1504 bits), 188 bytes captured (1504 bits)
    Encapsulation type: ISO/IEC 13818-1 MPEG2-TS (138)
    Arrival Time: Jan  1, 1970 08:00:00.000167294 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 0.000167294 seconds
    [Time delta from previous captured frame: 0.000055765 seconds]
    [Time delta from previous displayed frame: 0.000055765 seconds]
    [Time since reference or first frame: 0.000167294 seconds]
    Frame Number: 4
    Frame Length: 188 bytes (1504 bits)
    Capture Length: 188 bytes (1504 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: mp2t]
ISO/IEC 13818-1 PID=0x100 CC=0
    Header: 0x47410030
        0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
        .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
        .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
        .... .... ..0. .... .... .... .... .... = Transport Priority: 0
        .... .... ...0 0001 0000 0000 .... .... = PID: Unknown (0x0100)
        .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
        .... .... .... .... .... .... ..11 .... = Adaptation Field Control: Adaptation Field and Payload (0x3)
        .... .... .... .... .... .... .... 0000 = Continuity Counter: 0
    [MPEG2 PCR Analysis]
    Adaptation Field Length: 7
    Adaptation Field
        0... .... = Discontinuity Indicator: 0
        .1.. .... = Random Access Indicator: 1
        ..0. .... = Elementary Stream Priority Indicator: 0
        ...1 .... = PCR Flag: 1
        .... 0... = OPCR Flag: 0
        .... .0.. = Splicing Point Flag: 0
        .... ..0. = Transport Private Data Flag: 0
        .... ...0 = Adaptation Field Extension Flag: 0
        Program Clock Reference: 0x000000000132a20c
Reassembled in: 7139
```
