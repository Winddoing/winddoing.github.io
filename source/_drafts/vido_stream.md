

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
        .... .... .... .... .... .... .... 0001 = Continuity Counter: 1
    [MPEG2 PCR Analysis]
    Pointer: 0
```

## PAT




* [UDP_RTP+MPEG2-TS浅析](https://blog.csdn.net/H514434485/article/details/52120625)



## H264 -> TS

代码可以参考ffmpeg， mpegtsenc.c

[将H264与AAC打包Ipad可播放的TS流的总结](http://www.cnblogs.com/wangqiguo/archive/2013/03/29/2987949.html)


PMT

普通帧

关键帧
