

在MPEG-2标准中，有两种不同类型的码流输出到信道：一种是节目码流（Program Stream, PS），适用于没有误差产生的媒体存储，如DVD等存储介质；另一种是传送流（Transport stream, TS)，适用于有信道噪声产生的传输，目前TS流广泛应用于广播电视中，如机顶盒等。

[TS流基本概念](https://www.cnblogs.com/jiayayao/p/6832614.html)

* ES流（Elementary Stream）：基本码流，不分段的音频、视频或其他信息的连续码流。
* PES流：把基本流ES分割成段，并加上相应头文件打包成形的打包基本码流。
* PS流（Program Stream）：节目流，将具有共同时间基准的一个或多个PES组合（复合）而成的单一数据流（用于播放或编辑系统，如m2p）
* TS流（Transport Stream）：传输流，将具有共同时间基准或独立时间基准的一个或多个PES组合（复合）而成的单一数据流（用于数据传输）

* [TS流格式学习](https://www.jianshu.com/p/2b812a4e3315)
* [TS协议解析第一部分（PAT）](https://blog.csdn.net/u013354805/article/details/51578457)
## PS


* xxxxxxxxxxxxxx[从TS流到PAT和PMT](https://blog.csdn.net/rongdeguoqian/article/details/18214627)
## TS

S流是基于Packet的位流格式，每个包是188个字节


包头：
```
0000   47 10 11 11 5e b8 03 29 93 60 62 76 bf ff fc 10  G...^..).`bv....
0010   21 19 80 1d dd bc 87 1c fc 10 47 00 42 9b 53 80  !.........G.B.S.
0020   de b6 ff c0 7d 6f 65 3c fc 04 55 b0 c3 af 22 38  ....}oe<..U..."8
0030   9e 7f ff 4a 0a 9b 80 96 46 64 f9 bf 00 98 31 9e  ...J....Fd....1.
0040   24 3b 3f ff c1 33 eb d7 f7 c0 19 4c 9b 03 13 b5  $;?..3.....L....
0050   ed 55 ad ad ad ad ad ad ad ad ad ad ad ad ad ad  .U..............
0060   ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad  ................
0070   ad ad ad ad ac 8a d1 16 a6 bb 5d ad ad ad ad ad  ..........].....
0080   ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad  ................
0090   ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad ad  ................
00a0   ad ad ad ad ad ad ad ad ad ad ad ad ad ad ac 7a  ...............z
00b0   9c 97 90 d7 ff 84 14 3e 32 df 21 af              .......>2.!.
```

协议：
```
Frame 105: 1370 bytes on wire (10960 bits), 1370 bytes captured (10960 bits)
Ethernet II, Src: AmpakTec_c3:63:dc (04:e6:76:c3:63:dc), Dst: AmpakTec_b3:d6:a0 (ac:83:f3:b3:d6:a0)
Internet Protocol Version 4, Src: 192.168.100.3, Dst: 239.0.0.11
User Datagram Protocol, Src Port: 55226, Dst Port: 15550
Real-Time Transport Protocol
ISO/IEC 13818-1 PID=0x1011 CC=1
    Header: 0x47101111
        0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
        .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
        .... .... .0.. .... .... .... .... .... = Payload Unit Start Indicator: 0
        .... .... ..0. .... .... .... .... .... = Transport Priority: 0
        .... .... ...1 0000 0001 0001 .... .... = PID: Unknown (0x1011)
        .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
        .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
        .... .... .... .... .... .... .... 0001 = Continuity Counter: 1
    [MPEG2 PCR Analysis]
```

## 第一个TS包

```
0000   47 40 00 11 00 00 b0 0d 00 00 c3 00 00 00 01 e1  G@..............
0010   00 2d f6 52 95 ff ff ff ff ff ff ff ff ff ff ff  .-.R............
0020   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0030   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0040   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0050   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0060   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0070   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0080   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
0090   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
00a0   ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
00b0   ff ff ff ff ff ff ff ff ff ff ff ff              ............
```

```
Frame 80: 1370 bytes on wire (10960 bits), 1370 bytes captured (10960 bits)
Ethernet II, Src: AmpakTec_c3:63:dc (04:e6:76:c3:63:dc), Dst: AmpakTec_b3:d6:a0 (ac:83:f3:b3:d6:a0)
Internet Protocol Version 4, Src: 192.168.100.3, Dst: 239.0.0.11
User Datagram Protocol, Src Port: 55226, Dst Port: 15550
Real-Time Transport Protocol
ISO/IEC 13818-1 PID=0x0 CC=1
Header: 0x47400011
    0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
    .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
    .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
    .... .... ..0. .... .... .... .... .... = Transport Priority: 0
    .... .... ...0 0000 0000 0000 .... .... = PID: Program Association Table (0x0000)
    .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
    .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
    .... .... .... .... .... .... .... 0001 = Continuity Counter:
    [MPEG2 PCR Analysis]
    Pointer: 0
```

## TS

### 数据--TS流

```
+---------+---------+---------+--------+---------+
| packet1 | packet2 | packet3 |  ....  | packetn |
+---------+----------------------------+---------+
             +------+         +------+
             v 4Byte      184Byte    v
             +--------+--------------+
             | header |     data     |
             +--------+--------------+
```

### TS协议--Header

```
Header: 0x47400011
    0100 0111 .... .... .... .... .... .... = Sync Byte: Correct (0x47)
    .... .... 0... .... .... .... .... .... = Transport Error Indicator: 0
    .... .... .1.. .... .... .... .... .... = Payload Unit Start Indicator: 1
    .... .... ..0. .... .... .... .... .... = Transport Priority: 0
    .... .... ...0 0000 0000 0000 .... .... = PID: Program Association Table (0x0000)
    .... .... .... .... .... .... 00.. .... = Transport Scrambling Control: Not scrambled (0x0)
    .... .... .... .... .... .... ..01 .... = Adaptation Field Control: Payload only (0x1)
    .... .... .... .... .... .... .... 0001 = Continuity Counter:
```

|              字段             |  位宽 |      含义      |
| :--------------------------: | :---: | :-----------: |
|          sync_byte           | 1bit | 同步字节(`0x47`) |
| transport_error_indicator    | 1bit | 错误指示信息（1：该包至少有1bits传输错误）|
| payload_unit_start_indicator | 1bit | 负载单元开始标志（packet不满188字节时需填充）|
| transport_priority           | 1bit | 传输优先级标志（1：优先级高）|
| PID                          | 13bit| **Packet ID号码，唯一的号码对应`不同的包`** |
| transport_scrambling_control | 2bit | 加密标志（00：未加密；其他表示已加密） |
| adaptation_field_control     | 2bit | 附加区域控制，调整字段标志。01表示无调整字段，只有有效负载数据；10表示只有调整字段，无有效负载；11表示有调整字段，且其后跟有有效负载；空分组此字段应为01； |
| continuity_counter           | 4bit | 包递增计数器 |


### 不同的包

PID是TS流中唯一识别标志，Packet Data是什么内容就是由PID决定的。如果一个TS流中的一个Packet的Packet Header中的PID是0x0000，那么这个Packet的Packet Data就是DVB的PAT表而非其他类型数据（如Video、Audio或其他业务信息）。下表给出了一些表的PID值，这些值是固定的，不允许用于更改。


|   PID  |  Tables |
| :-----:| :-----: |
| 0x0000 | PAT (Program Association Table (PAT) contains a directory listing of all Program Map Tables)|
| 0x0001 | CAT (Conditional Access Table (CAT) contains a directory listing of all ITU-T Rec. H.222 entitlement management message streams used by Program Map Tables) |
| 0x0002 | TSDT (Transport Stream Description Table (TSDT) contains descriptors relating to the overall transport stream) |
| 0x0003 | IPMP Control Information Table contains a directory listing of all ISO/IEC 14496-13 control streams used by Program Map Tables |
| 0x0004 ~ 0x000f | Reserved for future use |
| 0x0010 ~ 0x001f | Used by DVB metadata |
| 0x0010 | NIT, ST |
| 0x0011 | SDT, BAT, ST |
| 0x0012 | EIT, ST, CIT |
| 0x0013 | RST, ST |
| 0x0014 | TDT, TOT, ST |
| 0x0015 | network synchronization |
| 0x0016 | RNT |
| 0x0017 ~ 0x001B | reserved for future use |
| 0x001C | inband signalling |
| 0x001D | measurement |
| 0x001E | DIT |
| 0x001F | SIT |
| 0x0020 ~ 0x1FFA | May be assigned as needed to Program Map Tables, elementary streams and other data tables |
| 0x1FFB | Used by DigiCipher 2/ATSC MGT metadata |
| 0x1FFC ~ 0x1FFE | May be assigned as needed to Program Map Tables, elementary streams and other data tables |
| 0x1FFF | Null Packet (used for fixed bandwidth padding) |

### PAT --- (PID == 0x0000)

>Program Association Table，节目关联表

#### PAT的描述(Data)

PAT表定义了当前TS流中所有的节目，其PID为0x0000，它是PSI的根节点，要查寻找节目必须从PAT表开始查找。

PAT表携带以下信息:

|  | | |
| :-: | :-: | :-: |
| TS流ID    | transport_stream_id | 该ID标志唯一的流ID |
| 节目频道号 |  program_number | 该号码标志ＴＳ流中的一个频道，该频道可以包含很多的节目(即可以包含多个Video PID和Audio PID) |
| PMT的PID  | program_map_PID | 表示本频道使用哪个PID做为PMT的PID,因为可以有很多的频道,因此DVB规定PMT的PID可以由用户自己定义 |

#### PAT的结构

``` C
typedef struct TS_PAT_Program
{
    unsigned program_number  :  16;  // 节目号
    unsigned program_map_PID :  13;  // 节目映射表的PID，节目号大于0时对应的PID，每个节目对应一个
}TS_PAT_Program
```

``` C
typedef struct TS_PAT
{
    unsigned table_id                     : 8;  //固定为0x00 ，标志是该表是PAT表
    unsigned section_syntax_indicator     : 1;  //段语法标志位，固定为1
    unsigned zero                         : 1;  //0
    unsigned reserved_1                   : 2;  // 保留位
    unsigned section_length               : 12; //表示从下一个字段开始到CRC32(含)之间有用的字节数
    unsigned transport_stream_id          : 16; //该传输流的ID，区别于一个网络中其它多路复用的流
    unsigned reserved_2                   : 2;  // 保留位
    unsigned version_number               : 5;  //范围0-31，表示PAT的版本号
    unsigned current_next_indicator       : 1;  //发送的PAT是当前有效还是下一个PAT有效
    unsigned section_number               : 8;  //分段的号码。PAT可能分为多段传输，第一段为00，以后每个分段加1，最多可能有256个分段
    unsigned last_section_number          : 8;  //最后一个分段的号码

    std::vector<TS_PAT_Program> program;
    unsigned reserved_3                   : 3;  // 保留位
    unsigned network_PID                  : 13; //网络信息表（NIT）的PID,节目号为0时对应的PID为network_PID
    unsigned CRC_32                       : 32; //CRC32校验码
} TS_PAT;
```

#### PAT数据

| Packet Header | Packet Data |
| :-----------: | :---------: |
|  0x47400011   | 00 b0 0d 00 00 c3 00 00 00 01 e1 00 2d f6 52 95 |

```
MPEG2 Program Association Table
    Table ID: Program Association Table (PAT) (0x00)
    1... .... .... .... = Syntax indicator: 1
    .011 .... .... .... = Reserved: 0x3
    .... 0000 0000 1101 = Length: 13
    Transport Stream ID: 0x0000
    11.. .... = Reserved: 0x3
    ..00 001. = Version Number: 0x01
    .... ...1 = Current/Next Indicator: Currently applicable
    Section Number: 0
    Last Section Number: 0
    Program 0x0001 -> PID 0x0100
        Program Number: 0x0001
        111. .... .... .... = Reserved: 0x7
        ...0 0001 0000 0000 = Program Map PID: 0x0100
    CRC 32: 0x2df65295 [unverified]
    [CRC 32 Status: Unverified]
```


#### PMT

PMT（Program Map Table）：节目映射表，该表的PID是由PAT提供给出的。通过该表可以得到一路节目中包含的信息，例如，该路节目由哪些流构成和这些流的类型（视频，音频，数据），指定节目中各流对应的PID，以及该节目的PCR所对应的PID。

PMT表中携带的信息：
| | | |
| :-: | :-: | :-: |
|

1) 当前频道中包含的所有Video数据的PID
(2) 当前频道中包含的所有Audio数据的PID
(3) 和当前频道关联在一起的其他数据的PID(如数字广播,数据通讯等使用的PID)

#### PMT数据包

| Packet Header | Packet Data |
| :-----------: | :---------: |
|  0x47410011   | 02 b0 25 00 01 c3 00 00 f0 00 f0 00 1b f0 11 f0 0a 28 04 42 c0 00 3f 2a 02 7e 1f 83 f1 00 f0 04 83 02 46 2f 98 2b 45 c7 |

```
MPEG2 Program Map Table
    Table ID: Program Map Table (PMT) (0x02)
    1... .... .... .... = Syntax indicator: 1
    .011 .... .... .... = Reserved: 0x3
    .... 0000 0010 0101 = Length: 37
    Program Number: 0x0001
    11.. .... = Reserved: 0x3
    ..00 001. = Version Number: 0x01
    .... ...1 = Current/Next Indicator: Currently applicable (0x1)
    Section Number: 0
    Last Section Number: 0
    111. .... .... .... = Reserved: 0x7
    ...1 0000 0000 0000 = PCR PID: 0x1000
    1111 .... .... .... = Reserved: 0xf
    .... 0000 0000 0000 = Program Info Length: 0x000
    Stream PID=0x1011
    Stream PID=0x1100
    CRC 32: 0x982b45c7 [unverified]
    [CRC 32 Status: Unverified]
```

#### 数据结构

``` C
typedef struct TS_PMT_Stream
{
	unsigned stream_type     : 8;  //指示特定PID的节目元素包的类型。该处PID由elementary PID指定
	unsigned elementary_PID  : 13; //该域指示TS包的PID值。这些TS包含有相关的节目元素
	unsigned ES_info_length  : 12; //前两位bit为00。该域指示跟随其后的描述相关节目元素的byte数
	unsigned descriptor;
}TS_PMT_Stream;
```

``` C
typedef struct TS_PMT
{
	unsigned table_id                  : 8; //固定为0x02, 表示PMT表
	unsigned section_syntax_indicator  : 1; //固定为0x01
	unsigned zero                      : 1; //0x01
	unsigned reserved_1                : 2; //0x03
	unsigned section_length			   : 12;//首先两位bit置为00，它指示段的byte数，由段长度域开始，包含CRC
	unsigned program_number            : 16;// 指出该节目对应于可应用的Program map PID
	unsigned reserved_2                : 2; //0x03
	unsigned version_number            : 5; //指出TS流中Program map section的版本号
	unsigned current_next_indicator	   : 1; //当该位置1时，当前传送的Program map section可用
									   	 //当该位置0时，指示当前传送的Program map section不可用，下一个TS流的Program map section有效
	unsigned section_number            : 8; //固定为0x00
	unsigned last_section_number       : 8; //固定为0x00
	unsigned reserved_3                : 3; //0x07
	nsigned PCR_PID                    : 13;//指明TS包的PID值，该TS包含有PCR域，
	                                        //该PCR值对应于由节目号指定的对应节目，如果对于私有数据流的节目定义与PCR无关，这个域的值将为0x1FFF。
	unsigned reserved_4                : 4; //预留为0x0F
	unsigned program_info_length       : 12;//前两位bit为00。该域指出跟随其后对节目信息的描述的byte数。

	std::vector<TS_PMT_Stream> PMT_Stream;   //每个元素包含8位, 指示特定PID的节目元素包的类型。该处PID由elementary PID指定
	unsigned reserved_5                : 3; //0x07
	unsigned reserved_6                : 4; //0x0F
	unsigned CRC_32                    : 32;
} TS_PMT;
```

* [UDP_RTP+MPEG2-TS浅析](https://blog.csdn.net/H514434485/article/details/52120625)
* [TS Stream 详解](https://www.cnblogs.com/big-devil/p/8589377.html)



## H264 -> TS

代码可以参考ffmpeg， mpegtsenc.c

[将H264与AAC打包Ipad可播放的TS流的总结](http://www.cnblogs.com/wangqiguo/archive/2013/03/29/2987949.html)


PMT

普通帧



关键帧

* [mpeg2-ts协议分析](https://blog.csdn.net/qingfengtsing/article/details/55668911)
* [MPEG2 TS概念总结](https://blog.csdn.net/coloriy/article/details/47147181)
