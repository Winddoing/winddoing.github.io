# 鼠标

## R

```
# ./hid-example 
Report Descriptor Size: 46
Report Descriptor:
5 1 9 2 a1 1 9 1 a1 0 5 9 19 1 29 3 15 0 25 1 95 8 75 1 81 2 5 1 9 30 9 31 9 38 15 81 25 7f 75 8 95 3 81 6 c0 c0 

Raw Name: Logitech USB Optical Mouse
Raw Phys: usb-f9890000.ehci-1.3/input0
Raw Info:
        bustype: 3 (USB)
        vendor: 0x046d
        product: 0xc077
HIDIOCSFEATURE: Broken pipe
HIDIOCGFEATURE: Broken pipe
Error: 32
write: Broken pipe
read: Resource temporarily unavailable
# ͉�1-1.3: USB disconnect, device number 7
```

```
   # ./vx_uibc 111
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
===> func: uibc_get_device_info, line: 146, desc size=46
===> func: uibc_get_device_info, line: 155, size=46
iocgrdesc: 5 1 9 2 a1 1 9 1 a1 0 5 9 19 1 29 3 15 0 25 1 95 8 75 1 81 2 5 1 9 30 9 31 9 38 15 81 25 7f 75 8 95 3 81 6 c0 c0 

```

## PC

```
=====>(master)$sudo ./hid-example 
[sudo] password for wqshao: 
Report Descriptor Size: 46
Report Descriptor:
5 1 9 2 a1 1 9 1 a1 0 5 9 19 1 29 3 15 0 25 1 95 8 75 1 81 2 5 1 9 30 9 31 9 38 15 81 25 7f 75 8 95 3 81 6 c0 c0 

Raw Name: Logitech USB Optical Mouse
Raw Phys: usb-0000:00:14.0-5.4/input0
Raw Info:
	bustype: 3 (USB)
	vendor: 0x046d
	product: 0xc077
HIDIOCSFEATURE: Broken pipe
HIDIOCGFEATURE: Broken pipe
Error: 32
write: Broken pipe
read: Resource temporarily unavailable

```



# USB  HID



```
usb_composite_probe
	\->hid_bind
		\->usb_add_config
			\->do_config
		
do_config
	\->hidg_bind_config
		\->hidg_bind
		
hidg_bind
	\->usb_ep_autoconfig
		\->usb_ep_autoconfig_ss
			list_for_each_entry (ep, &gadget->ep_list, ep_list){...}
            遍历ep_list只有一个ep，ep的初始化？？
        


```



# 问题



##　写hidg0时阻塞



```
########################################

#################diepint.b.epdisabled==0,i=100,depctl.b.epdis = 0
dwc_otg_ep_deactivate depctl before deactivate 00020000
dwc_otg_ep_deactivate depctl after deactivate 00020000
g_hid gadget: high-speed config #1: HID Gadget
[vx_uibc.c 180] uibc write data success len=4
===> func: uibc_thread, line: 182
[vx_uibc.c 130] ubic recvfrom data ...
uibc read socket data[len: 5]: BIT4~BIT0
                00 fe 06 00 22 
rpt data[len: 4]: BIT3~BIT0
                00 fe 06 00 
g_hid gadget: End Point Request ERROR: -108

#########################################

#################diepint.b.epdisabled==0,i=100,depctl.b.epdis = 0
dwc_otg_ep_deactivate depctl before deactivate 00020000
dwc_otg_ep_deactivate depctl after deactivate 00020000
g_hid gadget: high-speed config #1: HID Gadget
[vx_uibc.c 180] uibc write data success len=4
===> func: uibc_thread, line: 182
[vx_uibc.c 130] ubic recvfrom data ...
uibc read socket data[len: 5]: BIT4~BIT0
                00 fc 09 00 22 
rpt data[len: 4]: BIT3~BIT0
                00 fc 09 00 
```



```
T:  Bus=01 Lev=02 Prnt=06 Port=02 Cnt=03 Dev#= 11 Spd=1.5  MxCh= 0
D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs=  1
P:  Vendor=046d ProdID=c077 Rev=72.00
S:  Manufacturer=Logitech
S:  Product=USB Optical Mouse
C:* #Ifs= 1 Cfg#= 1 Atr=a0 MxPwr=100mA
I:* If#= 0 Alt= 0 #EPs= 1 Cls=03(HID  ) Sub=01 Prot=02 Driver=usbhid
E:  Ad=81(I) Atr=03(Int.) MxPS=   4 Ivl=10ms

T:  Bus=01 Lev=01 Prnt=01 Port=08 Cnt=04 Dev#= 12 Spd=480  MxCh= 0
D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=046d ProdID=c077 Rev= 3.99
S:  Manufacturer=Linux 3.4.35 with dwc_otg_pcd
S:  Product=Mouse HID Gadget
C:* #Ifs= 1 Cfg#= 1 Atr=c0 MxPwr=  2mA
I:* If#= 0 Alt= 0 #EPs= 1 Cls=03(HID  ) Sub=01 Prot=02 Driver=(none)
E:  Ad=81(I) Atr=03(Int.) MxPS=   4 Ivl=1ms

```



sudo modprobe usbmon



## S端USB线断开后再次接入时

```
1. 
g_hid gadget: End Point Request ERROR: -108

2. ep的disable时，检测到ep的enable寄存器为1
#########################################

#################diepint.b.epdisabled==0,i=100,depctl.b.epdis = 0
dwc_otg_ep_deactivate depctl before deactivate 00020000
dwc_otg_ep_deactivate depctl after deactivate 00020000
g_hid gadget: high-speed config #1: HID Gadget

```

```
#####
static struct usb_gadget_driver composite_driver = {                          
    .setup      = composite_setup,                                   
}
dwc_otg_pcd_irq
 \->dwc_otg_pcd_handle_intr
     \->dwc_otg_pcd_handle_out_ep_intr
         \->handle_ep0
             \->pcd_setup
                 \->pcd_setup
                     \->do_gadget_setup
                         \->pcd->fops->setup(pcd, (uint8_t *) ctrl);
                         \->composite_setup
                             \->
                               \->hidg_disable
                                  \->usb_ep_disable
                                     \->ep->ops->disable(ep);
                                     \->ep_disable
                                        \->dwc_otg_pcd_ep_disable
```

拔掉S端USB后的流程

```
 # ===> func: dwc_otg_pcd_ep_disable, line: 1638, depctl.b.epena=0
Backtrace: 
[<c0011fdc>] (dump_backtrace+0x0/0x110) from [<c03b2aa4>] (dump_stack+0x18/0x1c)
 r6:c3b03400 r5:c28fd084 r4:c28fd000 r3:c04ea900
[<c03b2a8c>] (dump_stack+0x0/0x1c) from [<bf4c82f4>] (dwc_otg_pcd_ep_disable+0x11c/0x4e4 [dwc_otg])
[<bf4c81d8>] (dwc_otg_pcd_ep_disable+0x0/0x4e4 [dwc_otg]) from [<bf4c66e8>] (ep_disable+0x44/0x9c [dwc_otg])
 r9:00000001 r8:c2949808 r7:00000000 r6:00000000 r5:c2951128
r4:bf4dafac
[<bf4c66a4>] (ep_disable+0x0/0x9c [dwc_otg]) from [<bf4fa21c>] (hidg_disable+0x20/0x30 [g_hid])
 r5:c2a107cc r4:c285aa84
[<bf4fa1fc>] (hidg_disable+0x0/0x30 [g_hid]) from [<bf4fac34>] (reset_config.isra.13+0x3c/0x64 [g_hid])
 r4:c285aa84 r3:bf4fa1fc
[<bf4fabf8>] (reset_config.isra.13+0x0/0x64 [g_hid]) from [<bf4fc41c>] (composite_setup+0x688/0xc1c [g_hid])
 r6:00000000 r5:c2951008 r4:c2a10640 r3:bf4fd708
[<bf4fbd94>] (composite_setup+0x0/0xc1c [g_hid]) from [<bf4c5b10>] (_setup+0x38/0x58 [dwc_otg])
[<bf4c5ad8>] (_setup+0x0/0x58 [dwc_otg]) from [<bf4ca8bc>] (handle_ep0+0x65c/0x16d4 [dwc_otg])
[<bf4ca260>] (handle_ep0+0x0/0x16d4 [dwc_otg]) from [<bf4cd7e4>] (dwc_otg_pcd_handle_out_ep_intr+0x1638/0x1948 [dwc_otg])
[<bf4cc1ac>] (dwc_otg_pcd_handle_out_ep_intr+0x0/0x1948 [dwc_otg]) from [<bf4d0c4c>] (dwc_otg_pcd_handle_intr+0x34c/0x358 [dwc_otg])
[<bf4d0900>] (dwc_otg_pcd_handle_intr+0x0/0x358 [dwc_otg]) from [<bf4c6038>] (dwc_otg_pcd_irq+0x14/0x20 [dwc_otg])
 r9:c04ee9f8 r8:00000037 r7:00000000 r6:00000000 r5:00000000
r4:c29d4980
[<bf4c6024>] (dwc_otg_pcd_irq+0x0/0x20 [dwc_otg]) from [<c005db98>] (handle_irq_event_percpu+0x3c/0x198)
[<c005db5c>] (handle_irq_event_percpu+0x0/0x198) from [<c005dd24>] (handle_irq_event+0x30/0x40)
[<c005dcf4>] (handle_irq_event+0x0/0x40) from [<c00602fc>] (handle_fasteoi_irq+0x78/0x134)
 r4:c04ee9f8 r3:00000000
[<c0060284>] (handle_fasteoi_irq+0x0/0x134) from [<c005d4c0>] (generic_handle_irq+0x30/0x40)
 r4:c04f494c r3:c0060284
[<c005d490>] (generic_handle_irq+0x0/0x40) from [<c000f024>] (handle_IRQ+0x40/0x8c)
[<c000efe4>] (handle_IRQ+0x0/0x8c) from [<c00084c4>] (gic_handle_irq+0x30/0x58)
 r6:c29499c8 r5:fe402000 r4:c04e6050 r3:00000037
[<c0008494>] (gic_handle_irq+0x0/0x58) from [<c000dd40>] (__irq_svc+0x40/0x50)
Exception stack(0xc29499c8 to 0xc2949a10)
99c0:                   00000001 c3826580 c38265b0 00000001 60000013 c04ec158
99e0: c03bcec0 c04f1158 c2948028 000f423c 0000000f c2949a24 c2949958 c2949a10
9a00: c003f700 c0062504 60000013 ffffffff
 r6:ffffffff r5:60000013 r4:c0062504 r3:c003f700
[<c0062464>] (rcu_sched_qs+0x0/0xa4) from [<c03b8350>] (__schedule+0x3c/0x414)
 r4:c04ec158 r3:c29562c0
[<c03b8314>] (__schedule+0x0/0x414) from [<c03b8760>] (schedule+0x38/0x78)
[<c03b8728>] (schedule+0x0/0x78) from [<c03b7c20>] (schedule_hrtimeout_range_clock+0xbc/0x148)
[<c03b7b64>] (schedule_hrtimeout_range_clock+0x0/0x148) from [<c03b7cc0>] (schedule_hrtimeout_range+0x14/0x18)
 r9:0000000f r8:00000000 r7:00004200 r6:00000020 r5:c2948038
r4:c2949b84
[<c03b7cac>] (schedule_hrtimeout_range+0x0/0x18) from [<c00a41ec>] (poll_schedule_timeout+0x40/0x60)
[<c00a41ac>] (poll_schedule_timeout+0x0/0x60) from [<c00a4ae0>] (do_select+0x4c4/0x558)
 r5:fffffd98 r4:00008000
[<c00a461c>] (do_select+0x0/0x558) from [<c00a4ca8>] (core_sys_select+0x134/0x33c)
[<c00a4b74>] (core_sys_select+0x0/0x33c) from [<c00a4f7c>] (sys_select+0xcc/0x118)
[<c00a4eb0>] (sys_select+0x0/0x118) from [<c000e140>] (ret_fast_syscall+0x0/0x30)
===> func: dwc_otg_pcd_ep_disable, line: 1683, depctl1.b.epena=0
dwc_otg_ep_deactivate depctl before deactivate 004d0004
dwc_otg_ep_deactivate depctl after deactivate 000d0004
g_hid gadget: high-speed config #1: HID Gadget
hidg_set_alt: usb_ep_enable
```

## 多次插拔R端USB设备

S端log

```
# dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
Dedicated Tx FIFOs mode
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
g_hid gadget: high-speed config #1: HID Gadget

~ # 
~ # 
~ # ===> func: vx_uibc_device_relese, line: 265, config=bf4fd678, set to NULL
dwc_otg_ep_deactivate depctl before deactivate 004e8004
dwc_otg_ep_deactivate depctl after deactivate 000e0004
WARN::dwc_otg_pcd_ep_dequeue:2364: bad argument

dwc_otg_driver_cleanup()
dwc_otg module removed

~ # 
~ # dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
Dedicated Tx FIFOs mode
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
Unable to handle kernel NULL pointer dereference at virtual address 00000011
pgd = c28e4000
[00000011] *pgd=828e9831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] ARM
Modules linked in: g_hid dwc_otg hi_gpio_key(O) hi_gpio_led(O) hi_mipi(O) hi3516a_adec(PO) hi3516a_aenc(PO) hi3516a_ao(PO) hi3516a_ai(PO) hi3516a_aio(PO) acodec(PO) adv76xx piris(O) pwm(O) hi3516a_ive(PO) hi3516a_vda(PO) hi3516a_jpe
ge(PO) hi3516a_h265e(PO) hi3516a_h264e(PO) hi3516a_chnl(PO) hi3516a_venc(PO) hi3516a_rc(PO) hifb(PO) hi3516a_vou(PO) hi3516a_vpss(PO) hi3516a_viu(PO) hi3516a_isp(PO) hi3516a_vgs(PO) hi3516a_region(PO) hi3516a_tde(PO) hi3516a_sys(PO)
 hi3516a_base(PO) hi_media(O) mmz(O) bcmdhd [last unloaded: dwc_otg]
CPU: 0    Tainted: P           O  (3.4.35 #12)
PC is at ep_queue+0x19c/0x2e8 [dwc_otg]
LR is at 0x0
pc : [<bf517a14>]    lr : [<00000000>]    psr: 20000013
sp : c3acdeb8  ip : c28fe4ec  fp : c3acdeec
r10: 00000004  r9 : bf52bf10  r8 : 00000020
r7 : c28fe000  r6 : c29b6bc0  r5 : 00000000  r4 : c2941128
r3 : 00000001  r2 : c29b6dc0  r1 : c29b6bc0  r0 : c2941000
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 828e4059  DAC: 00000015

SP: 0xc3acde38:
de38  00000000 00000000 00000000 00000000 c3b1eb00 bf517a14 20000013 ffffffff
de58  c3acdea4 00000020 c3acdeec c3acde70 c000dcd8 c0008360 c2941000 c29b6bc0
de78  c29b6dc0 00000001 c2941128 00000000 c29b6bc0 c28fe000 00000020 bf52bf10
de98  00000004 c3acdeec c28fe4ec c3acdeb8 00000000 bf517a14 20000013 ffffffff
deb8  c288561c c29afb80 c3acc000 00000004 c2885600 00000000 c3acc000 c288561c
ded8  00000001 c3acc000 c3acdf3c c3acdef0 bf54b798 bf517884 c3acc030 b6ea08ed
def8  00000000 c0014990 9faa0002 0131a8c0 00000000 00000000 00000001 c29afb80
df18  b6ea08ed c3acdf78 b6ea08ed 00000004 c3acc000 00000000 c3acdf6c c3acdf40

IP: 0xc28fe46c:
e46c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e48c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e4ac  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e4cc  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e4ec  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e50c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e52c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e54c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

FP: 0xc3acde6c:
de6c  c0008360 c2941000 c29b6bc0 c29b6dc0 00000001 c2941128 00000000 c29b6bc0
de8c  c28fe000 00000020 bf52bf10 00000004 c3acdeec c28fe4ec c3acdeb8 00000000
deac  bf517a14 20000013 ffffffff c288561c c29afb80 c3acc000 00000004 c2885600
decc  00000000 c3acc000 c288561c 00000001 c3acc000 c3acdf3c c3acdef0 bf54b798
deec  bf517884 c3acc030 b6ea08ed 00000000 c0014990 9faa0002 0131a8c0 00000000
df0c  00000000 00000001 c29afb80 b6ea08ed c3acdf78 b6ea08ed 00000004 c3acc000
df2c  00000000 c3acdf6c c3acdf40 c0094300 bf54b60c c3acdf68 00000000 b6ea0858
df4c  00000000 00000000 c29afb80 b6ea08ed 00000004 c3acdfa4 c3acdf70 c0094614

R0: 0xc2940f80:
0f80  146204fc d89f4c10 84036100 49f0409f 078204b1 07c20782 936e6620 02f44051
0fa0  bd1009e1 88064440 913700c8 3e383093 f1264440 0ec4016f 1240694a 807e0be8
0fc0  dc000300 6a35b2df 01804031 4bdb1300 d4080202 df988227 60100fc9 dae5e100
0fe0  0000006e 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1000  c28fe000 00000000 bf523af0 c2941104 c2941134 c2941374 00000003 00000000
1020  00000000 bf52bcb0 bf52b8e8 c29af400 c29fe540 bf54e6fc bf52b8f4 bf52b8f0
1040  c381d3c0 c04f84e8 c29fe500 00000002 00000003 00000000 00000000 00000001
1060  c2941060 c2941060 00000000 00000000 c294105c 00000000 bf54e5b8 00000000

R1: 0xc29b6b40:
6b40  73627573 65747379 83b0006d 00000000 00000000 00000000 00000000 bf4fa12c
6b60  00000000 00000000 00000000 00000000 0000002e 00000000 00000000 00000000
6b80  00000001 00000000 c381df00 c29b6c80 c39bf310 00000000 00000000 00000000
6ba0  00000000 42105a23 c29b6cc0 00000000 00000000 a1ff0008 00001df2 00000000
6bc0  c29b6dc0 00000004 ffffffff 00000000 00000000 00000000 00000000 bf54b5ac
6be0  c2885600 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
6c00  c29b6c10 c29b6c19 c29b6c22 00000000 00000409 00000301 01210903 22010001
6c20  0507002e 00040381 69726504 6369646f 6172665f 695f656d 0072746e 5f766564

R2: 0xc29b6d40:
6d40  02090105 010901a1 090500a1 03290119 01250015 01750895 01050281 31093009
6d60  81153809 08757f25 06810395 0000c0c0 00000000 00000000 00000000 00000000
6d80  c3800b40 0fd00000 00000001 00000000 c0097390 c0097800 c2885648 0000058d
6da0  c04ebd68 00000000 00200200 00000000 00000000 a1ff2008 00001df7 00000000
6dc0  00010600 c29b6dc0 00000000 00000000 00000000 c003ad38 725f6873 69665f78
6de0  5f006f66 4357445f 4552465f 77640045 746f5f63 65675f67 73685f74 635f6369
6e00  c29b6900 c2885290 c2885290 c384d4c0 c2885290 c04f8514 c29b65c0 00000002
6e20  00000003 c29b66c0 00000000 00000000 00000000 00000000 00000000 00000000

R4: 0xc29410a8:
10a8  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c29410c4
10c8  c29410c4 00000000 00000000 00000000 00000000 c29410dc c29410dc 00000000
10e8  00000000 00000000 00000000 00000000 00000000 bf517100 bf54e59c c29b6400
1108  bf529748 bf52bc88 c2941110 c2941110 00000040 00000000 00000000 00000000
1128  00000000 bf5297e0 bf52bc88 c2941374 c2941010 00000400 00008100 00000000
1148  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1168  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1188  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

R6: 0xc29b6b40:
6b40  73627573 65747379 83b0006d 00000000 00000000 00000000 00000000 bf4fa12c
6b60  00000000 00000000 00000000 00000000 0000002e 00000000 00000000 00000000
6b80  00000001 00000000 c381df00 c29b6c80 c39bf310 00000000 00000000 00000000
6ba0  00000000 42105a23 c29b6cc0 00000000 00000000 a1ff0008 00001df2 00000000
6bc0  c29b6dc0 00000004 ffffffff 00000000 00000000 00000000 00000000 bf54b5ac
6be0  c2885600 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
6c00  c29b6c10 c29b6c19 c29b6c22 00000000 00000409 00000301 01210903 22010001
6c20  0507002e 00040381 69726504 6369646f 6172665f 695f656d 0072746e 5f766564

R7: 0xc28fdf80:
df80  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
dfa0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
dfc0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
dfe0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e000  bf523b20 c2950940 c3b02c00 00000001 00000000 00000000 ffdf9000 829da000
e020  00000000 00000000 ffdf8000 829d9000 00000000 c28fe034 c28fe034 00000001
e040  01000000 00000000 829da000 00000000 00000000 00000000 00000000 00000000
e060  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c28fe000
Process vx_uibc_s (pid: 1166, stack limit = 0xc3acc2e8)
Stack: (0xc3acdeb8 to 0xc3ace000)
dea0:                                                       c288561c c29afb80
dec0: c3acc000 00000004 c2885600 00000000 c3acc000 c288561c 00000001 c3acc000
dee0: c3acdf3c c3acdef0 bf54b798 bf517884 c3acc030 b6ea08ed 00000000 c0014990
df00: 9faa0002 0131a8c0 00000000 00000000 00000001 c29afb80 b6ea08ed c3acdf78
df20: b6ea08ed 00000004 c3acc000 00000000 c3acdf6c c3acdf40 c0094300 bf54b60c
df40: c3acdf68 00000000 b6ea0858 00000000 00000000 c29afb80 b6ea08ed 00000004
df60: c3acdfa4 c3acdf70 c0094614 c0094268 b6ea1538 00000001 00000000 00000000
df80: b6ea08dc b6ea1538 b6f80870 b6f9a404 00000004 c000e2e8 00000000 c3acdfa8
dfa0: c000e140 c00945e0 b6ea1538 b6f80870 00000005 b6ea08ed 00000004 00000004
dfc0: b6ea1538 b6f80870 b6f9a404 00000004 b6ea1040 00800000 00000000 b6ea0eec
dfe0: 00000002 b6ea0840 b6ea14d0 b6ef2f64 60000010 00000005 ffffffff ffffffff
Backtrace: 
[<bf517878>] (ep_queue+0x0/0x2e8 [dwc_otg]) from [<bf54b798>] (f_hidg_write+0x198/0x27c [g_hid])
 r9:c3acc000 r8:00000001 r7:c288561c r6:c3acc000 r5:00000000
r4:c2885600
[<bf54b600>] (f_hidg_write+0x0/0x27c [g_hid]) from [<c0094300>] (vfs_write+0xa4/0x150)
[<c009425c>] (vfs_write+0x0/0x150) from [<c0094614>] (sys_write+0x40/0x80)
 r8:00000004 r7:b6ea08ed r6:c29afb80 r5:00000000 r4:00000000
[<c00945d4>] (sys_write+0x0/0x80) from [<c000e140>] (ret_fast_syscall+0x0/0x30)
 r8:c000e2e8 r7:00000004 r6:b6f9a404 r5:b6f80870 r4:b6ea1538
Code: e5953000 eaffffa6 e5990000 e1a01006 (e5de2011) 
---[ end trace 1efce3c99afbee53 ]---
g_hid gadget: high-speed config #1: HID Gadget

CTRL-A Z for help | 115200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyUSB0                                                                                                                                                       

```





```
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
g_hid gadget: high-speed config #1: HID Gadget
===> func: vx_uibc_device_relese, line: 265, config=bf6e3678, set to NULL
dwc_otg_ep_deactivate depctl before deactivate 004d8004
dwc_otg_ep_deactivate depctl after deactivate 000d0004
WARN::dwc_otg_pcd_ep_dequeue:2364: bad argument

dwc_otg_driver_cleanup()
dwc_otg module removed
dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
Dedicated Tx FIFOs mode
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
g_hid gadget: high-speed config #1: HID Gadget
===> func: vx_uibc_device_relese, line: 265, config=bf734678, set to NULL
dwc_otg_ep_deactivate depctl before deactivate 004c8004
dwc_otg_ep_deactivate depctl after deactivate 000c0004
WARN::dwc_otg_pcd_ep_dequeue:2364: bad argument

dwc_otg_driver_cleanup()
dwc_otg module removed
dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
Dedicated Tx FIFOs mode
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:376: bogus device state

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
Unable to handle kernel NULL pointer dereference at virtual address 00000011
pgd = c3af0000
[00000011] *pgd=83af7831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] ARM
Modules linked in: g_hid dwc_otg hi_gpio_key(O) hi_gpio_led(O) hi_mipi(O) hi3516a_adec(PO) hi3516a_aenc(PO) hi3516a_ao(PO) hi3516a_ai(PO) hi3516a_aio(PO) acodec(PO) adv76xx piris(O) pwm(O) hi3516a_ive(PO) hi3516a_vda(PO) hi3516a_jpe
ge(PO) hi3516a_h265e(PO) hi3516a_h264e(PO) hi3516a_chnl(PO) hi3516a_venc(PO) hi3516a_rc(PO) hifb(PO) hi3516a_vou(PO) hi3516a_vpss(PO) hi3516a_viu(PO) hi3516a_isp(PO) hi3516a_vgs(PO) hi3516a_region(PO) hi3516a_tde(PO) hi3516a_sys(PO)
 hi3516a_base(PO) hi_media(O) mmz(O) bcmdhd [last unloaded: dwc_otg]
CPU: 0    Tainted: P           O  (3.4.35 #12)
PC is at ep_queue+0x19c/0x2e8 [dwc_otg]
LR is at 0x0
pc : [<bf74ea14>]    lr : [<00000000>]    psr: 20000013
sp : c293deb8  ip : c29c24ec  fp : c293deec
r10: 00000004  r9 : bf762f10  r8 : 00000020
r7 : c29c2000  r6 : c3a9d300  r5 : 00000000  r4 : c323e128
r3 : 00000001  r2 : c3a9d340  r1 : c3a9d300  r0 : c323e000
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 83af0059  DAC: 00000015

SP: 0xc293de38:
de38  00000000 00000000 00000000 00000000 c2909080 bf74ea14 20000013 ffffffff
de58  c293dea4 00000020 c293deec c293de70 c000dcd8 c0008360 c323e000 c3a9d300
de78  c3a9d340 00000001 c323e128 00000000 c3a9d300 c29c2000 00000020 bf762f10
de98  00000004 c293deec c29c24ec c293deb8 00000000 bf74ea14 20000013 ffffffff
deb8  c290741c c28f0080 c293c000 00000004 c2907400 00000000 c293c000 c290741c
ded8  00000001 c293c000 c293df3c c293def0 bf782798 bf74e884 c293c030 b6eb58ed
def8  00000000 c293df08 dab10002 0131a8c0 00000000 00000000 c293df44 c28f0080
df18  b6eb58ed c293df78 b6eb58ed 00000004 c293c000 00000000 c293df6c c293df40

IP: 0xc29c246c:
246c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
248c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
24ac  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
24cc  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
24ec  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
250c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
252c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
254c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

FP: 0xc293de6c:
de6c  c0008360 c323e000 c3a9d300 c3a9d340 00000001 c323e128 00000000 c3a9d300
de8c  c29c2000 00000020 bf762f10 00000004 c293deec c29c24ec c293deb8 00000000
deac  bf74ea14 20000013 ffffffff c290741c c28f0080 c293c000 00000004 c2907400
decc  00000000 c293c000 c290741c 00000001 c293c000 c293df3c c293def0 bf782798
deec  bf74e884 c293c030 b6eb58ed 00000000 c293df08 dab10002 0131a8c0 00000000
df0c  00000000 c293df44 c28f0080 b6eb58ed c293df78 b6eb58ed 00000004 c293c000
df2c  00000000 c293df6c c293df40 c0094300 bf78260c c293df68 00000000 b6eb5858
df4c  00000000 00000000 c28f0080 b6eb58ed 00000004 c293dfa4 c293df70 c0094614

R0: 0xc323df80:
df80  1e804ffc fa6fbede ff400bdc 34fd373a 9feffdc6 7691357e 2967fa3c b965fe77
dfa0  ea54ecee 9c9eff3f ea28157f e71407bf 4f40147f 3fa07c40 affc966a 00300807
dfc0  d9ead35e 4fb23844 e88e291f e874dbc7 57192f0d 378eff51 969bb4c2 e63a6993
dfe0  59da50c2 69b70e50 eaec4ec2 b04013ff 35141a8a 00060100 7cd19f20 00000000
e000  c29c2000 00000000 bf75aaf0 c323e104 c323e134 c323e374 00000003 00000000
e020  00000000 bf762cb0 bf7628e8 c39fab00 c3aa8880 bf7856fc bf7628f4 bf7628f0
e040  c381d3c0 c04f84e8 c3aa9100 00000002 00000003 00000000 00000000 00000001
e060  c323e060 c323e060 00000000 00000000 c323e05c 00000000 bf7855b8 00000000

R1: 0xc3a9d280:
d280  64627375 2e317665 c3a90032 c3a9d240 c3a9d390 00000000 00000000 00000000
d2a0  00000000 3af3f719 c3a9a8c0 00000000 00000000 a1ff0008 000016ae 00000000
d2c0  00000002 00000000 c387be40 c3a9d280 00000001 c39d1c50 c3a2d290 00000000
d2e0  00000000 2134f381 c3a9d0c0 00000000 00000000 a1ff2008 000016af 00000000
d300  c3a9d340 00000004 ffffffff 00000000 00000000 00000000 00000000 bf7825ac
d320  c2907400 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
d340  00ef0900 c3a9d340 00000000 00000000 00000000 c003ad38 c00323a4 00000617
d360  c04ebd68 c3995424 00200200 00000000 00000000 00000000 00000000 00000000

R2: 0xc3a9d2c0:
d2c0  00000002 00000000 c387be40 c3a9d280 00000001 c39d1c50 c3a2d290 00000000
d2e0  00000000 2134f381 c3a9d0c0 00000000 00000000 a1ff2008 000016af 00000000
d300  c3a9d340 00000004 ffffffff 00000000 00000000 00000000 00000000 bf7825ac
d320  c2907400 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
d340  00ef0900 c3a9d340 00000000 00000000 00000000 c003ad38 c00323a4 00000617
d360  c04ebd68 c3995424 00200200 00000000 00000000 00000000 00000000 00000000
d380  67646968 00730030 c059dfa0 c057de80 00000000 00000000 00000000 00000000
d3a0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

R4: 0xc323e0a8:
e0a8  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c323e0c4
e0c8  c323e0c4 00000000 00000000 00000000 00000000 c323e0dc c323e0dc 00000000
e0e8  00000000 00000000 00000000 00000000 00000000 bf74e100 bf78559c c3a9d200
e108  bf760748 bf762c88 c323e110 c323e110 00000040 00000000 00000000 00000000
e128  00000000 bf7607e0 bf762c88 c323e374 c323e010 00000400 00008100 00000000
e148  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e168  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
e188  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

R6: 0xc3a9d280:
d280  64627375 2e317665 c3a90032 c3a9d240 c3a9d390 00000000 00000000 00000000
d2a0  00000000 3af3f719 c3a9a8c0 00000000 00000000 a1ff0008 000016ae 00000000
d2c0  00000002 00000000 c387be40 c3a9d280 00000001 c39d1c50 c3a2d290 00000000
d2e0  00000000 2134f381 c3a9d0c0 00000000 00000000 a1ff2008 000016af 00000000
d300  c3a9d340 00000004 ffffffff 00000000 00000000 00000000 00000000 bf7825ac
d320  c2907400 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
d340  00ef0900 c3a9d340 00000000 00000000 00000000 c003ad38 c00323a4 00000617
d360  c04ebd68 c3995424 00200200 00000000 00000000 00000000 00000000 00000000

R7: 0xc29c1f80:
1f80  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1fa0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1fc0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1fe0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
2000  bf75ab20 c29a5f80 c2966400 00000001 00000000 00000000 ffdf9000 82994000
2020  00000000 00000000 ffdf8000 83b13000 00000000 c29c2034 c29c2034 00000000
2040  01000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
2060  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c29c2000
Process vx_uibc_s (pid: 1205, stack limit = 0xc293c2e8)
Stack: (0xc293deb8 to 0xc293e000)
dea0:                                                       c290741c c28f0080
dec0: c293c000 00000004 c2907400 00000000 c293c000 c290741c 00000001 c293c000
dee0: c293df3c c293def0 bf782798 bf74e884 c293c030 b6eb58ed 00000000 c293df08
df00: dab10002 0131a8c0 00000000 00000000 c293df44 c28f0080 b6eb58ed c293df78
df20: b6eb58ed 00000004 c293c000 00000000 c293df6c c293df40 c0094300 bf78260c
df40: c293df68 00000000 b6eb5858 00000000 00000000 c28f0080 b6eb58ed 00000004
df60: c293dfa4 c293df70 c0094614 c0094268 b6eb5404 00000001 00000000 00000000
df80: b6eb58dc b6eb6538 b6f95870 b6faf404 00000004 c000e2e8 00000000 c293dfa8
dfa0: c000e140 c00945e0 b6eb6538 b6f95870 00000005 b6eb58ed 00000004 00000004
dfc0: b6eb6538 b6f95870 b6faf404 00000004 b6eb6040 00800000 00000000 b6eb5eec
dfe0: 00000002 b6eb5840 b6eb64d0 b6f07f64 60000010 00000005 00000000 00000126
Backtrace: 
[<bf74e878>] (ep_queue+0x0/0x2e8 [dwc_otg]) from [<bf782798>] (f_hidg_write+0x198/0x27c [g_hid])
 r9:c293c000 r8:00000001 r7:c290741c r6:c293c000 r5:00000000
r4:c2907400
[<bf782600>] (f_hidg_write+0x0/0x27c [g_hid]) from [<c0094300>] (vfs_write+0xa4/0x150)
[<c009425c>] (vfs_write+0x0/0x150) from [<c0094614>] (sys_write+0x40/0x80)
 r8:00000004 r7:b6eb58ed r6:c28f0080 r5:00000000 r4:00000000
[<c00945d4>] (sys_write+0x0/0x80) from [<c000e140>] (ret_fast_syscall+0x0/0x30)
 r8:c000e2e8 r7:00000004 r6:b6faf404 r5:b6f95870 r4:b6eb6538
Code: e5953000 eaffffa6 e5990000 e1a01006 (e5de2011) 
---[ end trace 4ab9b1fb1790566f ]---
g_hid gadget: high-speed config #1: HID Gadget

CTRL-A Z for help | 115200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyUSB0                                                                                                                                                    
```



### WARN::ep_queue:376: bogus device state

```
static int ep_queue(struct usb_ep *usb_ep, struct usb_request *usb_req,  
            gfp_t gfp_flags)                                             
{
	...
	if (!gadget_wrapper->driver ||                                           
    	gadget_wrapper->gadget.speed == USB_SPEED_UNKNOWN) {                 
     	DWC_DEBUGPL(DBG_PCDV, "gadget.speed=%d\n",                           
             	gadget_wrapper->gadget.speed);                               
     	DWC_WARN("bogus device state\n");                                    
     	return -ESHUTDOWN;                                                   
 	}
 	...
}
.queue = ep_queue, 
 USB的速度没有设置，其设置的位置
 
 static int _connect(dwc_otg_pcd_t *pcd, int speed)               
{                                                                
    gadget_wrapper->gadget.speed = speed;                        
    return 0;                                                    
}                                                                
.connect = _connect,  
二者属于异步操作，启动其执行流程，和可能出现错误的原因
```

### 异常状态---ARN::ep_queue:376: bogus device state

```
f_hidg_write -- f_hid.c
 \->usb_ep_queue
      \->ep->ops->queue(ep, req, gfp_flags);
          \->ep_queue -- 向EP提交I/O请求
            gadget_wrapper->gadget.speed == USB_SPEED_UNKNOWN
```



### 设置speed

```
request_irq(_dev->resource[1].start, dwc_otg_pcd_irq,IRQF_SHARED | IRQF_DISABLED, 
 \->dwc_otg_pcd_irq
     \->dwc_otg_pcd_handle_intr -- gintr_status.b.enumdone true
         \-> dwc_otg_pcd_handle_enum_done_intr
	           \-->connect -> _connect(dwc_otg_pcd_t *pcd, int speed)
```



### 访问指针错误

```
f_hidg_write -- f_hid.c
 \->usb_ep_queue
      \->ep->ops->queue(ep, req, gfp_flags);
          \->ep_queue -- 向EP提交I/O请求
             ep = ep_from_handle(pcd, usb_ep);  -- ep == NULL
             {
             	 ep --> in_ep --> id = 0;
             }
```

### enable

``` .enable = ep_enable
 static struct usb_ep_ops dwc_otg_pcd_ep_ops = {
 	.enable = ep_enable
 }
 
 hidg_set_alt -- ???
  \->usb_ep_enable
       \->ep->ops->enable(ep, ep->desc); 
       	   \->dwc_otg_pcd_ep_enable
       	      \->ep->priv = usb_ep;
```

hidg_set_alt

```
static struct usb_gadget_driver composite_driver = {                                         
    .setup      = composite_setup,                                                       
};                                                                        
composite_setup -- USB_REQ_SET_CONFIGURATION
 \->set_config
     \->f->set_alt(f, tmp, 0); 
        \->hidg_set_alt
```



## 访问空指针异常，主要是在ep_enable之前进行了写操作

在enable和write之间使用全局变量同步usb_ep_enable_done

```
etting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
===> func: dwc_otg_driver_probe, line: 701
Dedicated Tx FIFOs mode
===> func: gadget_add_eps, line: 1055
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
g_hid gadget: high-speed config #1: HID Gadget
===> func: ep_enable, line: 187
===> func: vx_uibc_device_relese, line: 265, config=bf59f748, set to NULL
dwc_otg_ep_deactivate depctl before deactivate 004c8004
dwc_otg_ep_deactivate depctl after deactivate 000c0004
WARN::dwc_otg_pcd_ep_dequeue:2364: bad argument

dwc_otg_driver_cleanup()
dwc_otg module removed
dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
===> func: dwc_otg_driver_probe, line: 701
Dedicated Tx FIFOs mode
===> func: gadget_add_eps, line: 1055
dinfo: bustype:[0x00000003], vendor:[0x046d], product:[0xffffc077]
structure_func_desc report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
structure_func_desc: subclass=0, protocol=0, report_length=4, report_desc_length=46
redefine_dev_id: idVendor=0x046d, idProduct=0xc077
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
WARN::ep_queue:377: bogus device state, gadget_wrapper->gadget.speed=0

g_hid gadget: usb_ep_queue error on int endpoint 4294967188
===> func: ep_queue, line: 391, pcd->ep0.priv=c3b3d104, usb_ep=c3b3d128
===> func: ep_queue, line: 395, pcd->in_ep[0].priv=  (null), pcd->out_ep[0].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[1].priv=  (null), pcd->out_ep[1].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[2].priv=  (null), pcd->out_ep[2].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[3].priv=  (null), pcd->out_ep[3].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[4].priv=  (null), pcd->out_ep[4].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[5].priv=  (null), pcd->out_ep[5].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[6].priv=  (null), pcd->out_ep[6].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[7].priv=  (null), pcd->out_ep[7].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[8].priv=  (null), pcd->out_ep[8].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[9].priv=  (null), pcd->out_ep[9].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[10].priv=  (null), pcd->out_ep[10].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[11].priv=  (null), pcd->out_ep[11].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[12].priv=  (null), pcd->out_ep[12].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[13].priv=  (null), pcd->out_ep[13].priv=  (null)
===> func: ep_queue, line: 395, pcd->in_ep[14].priv=  (null), pcd->out_ep[14].priv=  (null)
------------[ cut here ]------------
WARNING: at drivers/usb/gadget/hi_hs_dev/dwc_otg_pcd_linux.c:404 ep_queue+0x16c/0x374 [dwc_otg]()
Modules linked in: g_hid dwc_otg hi_gpio_key(O) hi_gpio_led(O) hi_mipi(O) hi3516a_adec(PO) hi3516a_aenc(PO) hi3516a_ao(PO) hi3516a_ai(PO) hi3516a_aio(PO) acodec(PO) adv76xx piris(O) pwm(O) hi3516a_ive(PO) hi3516a_vda(PO) hi3516a_jpe
ge(PO) hi3516a_h265e(PO) hi3516a_h264e(PO) hi3516a_chnl(PO) hi3516a_venc(PO) hi3516a_rc(PO) hifb(PO) hi3516a_vou(PO) hi3516a_vpss(PO) hi3516a_viu(PO) hi3516a_isp(PO) hi3516a_vgs(PO) hi3516a_region(PO) hi3516a_tde(PO) hi3516a_sys(PO)
 hi3516a_base(PO) hi_media(O) mmz(O) bcmdhd [last unloaded: dwc_otg]
Backtrace: 
[<c0011fdc>] (dump_backtrace+0x0/0x110) from [<c03b2aa4>] (dump_stack+0x18/0x1c)
 r6:bf5b9a10 r5:00000009 r4:00000000 r3:c04ea900
[<c03b2a8c>] (dump_stack+0x0/0x1c) from [<c001c204>] (warn_slowpath_common+0x5c/0x6c)
[<c001c1a8>] (warn_slowpath_common+0x0/0x6c) from [<c001c2b8>] (warn_slowpath_null+0x24/0x2c)
 r8:00000020 r7:c3a8a000 r6:c296b580 r5:0000000f r4:c3b3d128
r3:00000009
[<c001c294>] (warn_slowpath_null+0x0/0x2c) from [<bf5b9a10>] (ep_queue+0x16c/0x374 [dwc_otg])
[<bf5b98a4>] (ep_queue+0x0/0x374 [dwc_otg]) from [<bf5ed7f0>] (f_hidg_write+0x1ac/0x304 [g_hid])
[<bf5ed644>] (f_hidg_write+0x0/0x304 [g_hid]) from [<c0094300>] (vfs_write+0xa4/0x150)
[<c009425c>] (vfs_write+0x0/0x150) from [<c0094614>] (sys_write+0x40/0x80)
 r8:00000004 r7:b6e4f8ed r6:c296a580 r5:00000000 r4:00000000
g_hid gadget: high-speed config #1: HID Gadget
===> func: ep_enable, line: 187

[<c00945d4>] (sys_write+0x0/0x80) from [<c000e140>] (ret_fast_syscall+0x0/0x30)
 r8:c000e2e8 r7:00000004 r6:b6f49404 r5:b6f2f870 r4:b6e50538
---[ end trace fee705e27e6703b5 ]---
Unable to handle kernel NULL pointer dereference at virtual address 00000011
pgd = c3adc000
[00000011] *pgd=828a2831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] ARM
Modules linked in: g_hid dwc_otg hi_gpio_key(O) hi_gpio_led(O) hi_mipi(O) hi3516a_adec(PO) hi3516a_aenc(PO) hi3516a_ao(PO) hi3516a_ai(PO) hi3516a_aio(PO) acodec(PO) adv76xx piris(O) pwm(O) hi3516a_ive(PO) hi3516a_vda(PO) hi3516a_jpe
ge(PO) hi3516a_h265e(PO) hi3516a_h264e(PO) hi3516a_chnl(PO) hi3516a_venc(PO) hi3516a_rc(PO) hifb(PO) hi3516a_vou(PO) hi3516a_vpss(PO) hi3516a_viu(PO) hi3516a_isp(PO) hi3516a_vgs(PO) hi3516a_region(PO) hi3516a_tde(PO) hi3516a_sys(PO)
 hi3516a_base(PO) hi_media(O) mmz(O) bcmdhd [last unloaded: dwc_otg]
CPU: 0    Tainted: P        W  O  (3.4.35 #12)
PC is at ep_queue+0x178/0x374 [dwc_otg]
LR is at 0x0
pc : [<bf5b9a1c>]    lr : [<00000000>]    psr: 60000013
sp : c3ad7eb0  ip : 00000000  fp : c3ad7eec
r10: c3a8a4ec  r9 : bf5ce128  r8 : 00000020
r7 : c3a8a000  r6 : c296b580  r5 : 0000000f  r4 : c3b3d128
r3 : 00000009  r2 : 00001201  r1 : c296b580  r0 : c3b3d000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 83adc059  DAC: 00000015

SP: 0xc3ad7e30:
7e30  00000010 c3ad7e4c c3ad7e6c c3ad7e58 c001c194 bf5b9a1c 60000013 ffffffff
7e50  c3ad7e9c 00000020 c3ad7eec c3ad7e68 c000dcd8 c0008360 c3b3d000 c296b580
7e70  00001201 00000009 c3b3d128 0000000f c296b580 c3a8a000 00000020 bf5ce128
7e90  c3a8a4ec c3ad7eec 00000000 c3ad7eb0 00000000 bf5b9a1c 60000013 ffffffff
7eb0  00000000 0000000e 00000000 c296a580 c3ad6000 c3b5d800 b6e4f8ed c3ad6000
7ed0  c3b5d81c c296a580 c3ad6000 00000004 c3ad7f3c c3ad7ef0 bf5ed7f0 bf5b98b0
7ef0  c3ad6030 b6e4f8ed 00000000 c3ad7f08 85860002 0131a8c0 00000000 00000000
7f10  c3ad7f44 c296a580 b6e4f8ed c3ad7f78 b6e4f8ed 00000004 c3ad6000 00000000

FP: 0xc3ad7e6c:
7e6c  c296b580 00001201 00000009 c3b3d128 0000000f c296b580 c3a8a000 00000020
7e8c  bf5ce128 c3a8a4ec c3ad7eec 00000000 c3ad7eb0 00000000 bf5b9a1c 60000013
7eac  ffffffff 00000000 0000000e 00000000 c296a580 c3ad6000 c3b5d800 b6e4f8ed
7ecc  c3ad6000 c3b5d81c c296a580 c3ad6000 00000004 c3ad7f3c c3ad7ef0 bf5ed7f0
7eec  bf5b98b0 c3ad6030 b6e4f8ed 00000000 c3ad7f08 85860002 0131a8c0 00000000
7f0c  00000000 c3ad7f44 c296a580 b6e4f8ed c3ad7f78 b6e4f8ed 00000004 c3ad6000
7f2c  00000000 c3ad7f6c c3ad7f40 c0094300 bf5ed650 c3ad7f68 00000000 b6e4f86c
7f4c  00000000 00000000 c296a580 b6e4f8ed 00000004 c3ad7fa4 c3ad7f70 c0094614

R0: 0xc3b3cf80:
cf80  e39e91fc e022f80a 7d453c87 a80bdf41 e3e85bdf fe75f0cf d237fecb 27c4db60
cfa0  079ea1c4 3fd07786 6019c1fa f30c2add f1ee1481 bdf3791d 7ecd7c2c b49463a0
cfc0  5b0ab94d 23a1d785 d3e4d769 2d2bf6ca 010fe8bd 05b6dc84 ac003008 00254f6a
cfe0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
d000  c3a8a000 00000000 bf5c5bd4 c3b3d104 c3b3d134 c3b3d374 00000003 00000000
d020  00000000 bf5cdec8 bf5cdb00 c296ab00 c2976200 bf5f07cc bf5cdb0c bf5cdb08
d040  c381d3c0 c04f84e8 c2976f40 00000002 00000003 00000000 00000000 00000001
d060  c3b3d060 c3b3d060 00000000 00000000 c3b3d05c 00000000 bf5f0688 00000000

R1: 0xc296b500:
b500  00000001 00000000 c296bb40 c047c9f0 c296be11 c296bbd0 c296bd90 00000000
b520  00000000 27692f8b c04f8760 00000000 00000000 81240002 00001e03 00000000
b540  00000003 00000000 c296bc40 c0462b5c c296b850 00000000 00000000 00000000
b560  00000000 57c6bb9d c04f85a0 00000000 00000000 80800002 00001e0c 00000000
b580  c296b240 00000004 ffffffff 00000000 00000000 00000000 00000000 bf5ed5f0
b5a0  c3b5d800 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
b5c0  bf4fa000 bf501000 00000005 c296b78d 00000000 00000000 c296b798 c296b058
b5e0  00000000 00000000 c2962140 00000000 00000000 00000000 00000000 00000000

R4: 0xc3b3d0a8:
d0a8  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c3b3d0c4
d0c8  c3b3d0c4 00000000 00000000 00000000 00000000 c3b3d0dc c3b3d0dc 00000000
d0e8  00000000 00000000 00000000 00000000 00000000 bf5b912c bf5f066c c296b080
d108  bf5cb964 bf5cdea0 c3b3d110 c3b3d110 00000040 00000000 00000000 00000000
d128  c3b5d800 bf5cb9fc bf5cdea0 c3b3d374 c3b3d010 00000004 00008100 c296b462
d148  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
d168  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
d188  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

R6: 0xc296b500:
b500  00000001 00000000 c296bb40 c047c9f0 c296be11 c296bbd0 c296bd90 00000000
b520  00000000 27692f8b c04f8760 00000000 00000000 81240002 00001e03 00000000
b540  00000003 00000000 c296bc40 c0462b5c c296b850 00000000 00000000 00000000
b560  00000000 57c6bb9d c04f85a0 00000000 00000000 80800002 00001e0c 00000000
b580  c296b240 00000004 ffffffff 00000000 00000000 00000000 00000000 bf5ed5f0
b5a0  c3b5d800 00000000 00000000 ffffff8d 00000000 00000000 00000000 00000000
b5c0  bf4fa000 bf501000 00000005 c296b78d 00000000 00000000 c296b798 c296b058
b5e0  00000000 00000000 c2962140 00000000 00000000 00000000 00000000 00000000

R7: 0xc3a89f80:
9f80  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fa0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fc0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fe0  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a000  bf5c5c04 c2962680 c3b11400 00000001 00000000 00000000 ffdf9000 8297b000
a020  00000000 00000000 ffdf8000 8297a000 00000000 c3a8a034 c3a8a034 00000001
a040  01000000 00000000 8297b000 00000000 00000000 00000000 00000000 00000000
a060  00000000 00000000 00000000 00000000 00000000 00000000 00000000 c3a8a000

R10: 0xc3a8a46c:
a46c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a48c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a4ac  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a4cc  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a4ec  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a50c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a52c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
a54c  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
Process vx_uibc_s (pid: 1228, stack limit = 0xc3ad62e8)
Stack: (0xc3ad7eb0 to 0xc3ad8000)
7ea0:                                     00000000 0000000e 00000000 c296a580
7ec0: c3ad6000 c3b5d800 b6e4f8ed c3ad6000 c3b5d81c c296a580 c3ad6000 00000004
7ee0: c3ad7f3c c3ad7ef0 bf5ed7f0 bf5b98b0 c3ad6030 b6e4f8ed 00000000 c3ad7f08
7f00: 85860002 0131a8c0 00000000 00000000 c3ad7f44 c296a580 b6e4f8ed c3ad7f78
7f20: b6e4f8ed 00000004 c3ad6000 00000000 c3ad7f6c c3ad7f40 c0094300 bf5ed650
7f40: c3ad7f68 00000000 b6e4f86c 00000000 00000000 c296a580 b6e4f8ed 00000004
7f60: c3ad7fa4 c3ad7f70 c0094614 c0094268 b6e4f414 00000001 00000000 00000000
7f80: 004a2010 b6e50538 b6f2f870 b6f49404 00000004 c000e2e8 00000000 c3ad7fa8
7fa0: c000e140 c00945e0 b6e50538 b6f2f870 00000005 b6e4f8ed 00000004 00000004
7fc0: b6e50538 b6f2f870 b6f49404 00000004 b6e50040 00800000 00000000 b6e4feec
7fe0: 00000002 b6e4f850 b6e504d0 b6ea1f64 60000010 00000005 00000000 00000000
Backtrace: 
[<bf5b98a4>] (ep_queue+0x0/0x374 [dwc_otg]) from [<bf5ed7f0>] (f_hidg_write+0x1ac/0x304 [g_hid])
[<bf5ed644>] (f_hidg_write+0x0/0x304 [g_hid]) from [<c0094300>] (vfs_write+0xa4/0x150)
[<c009425c>] (vfs_write+0x0/0x150) from [<c0094614>] (sys_write+0x40/0x80)
 r8:00000004 r7:b6e4f8ed r6:c296a580 r5:00000000 r4:00000000
[<c00945d4>] (sys_write+0x0/0x80) from [<c000e140>] (ret_fast_syscall+0x0/0x30)
 r8:c000e2e8 r7:00000004 r6:b6f49404 r5:b6f2f870 r4:b6e50538
Code: eb298a20 e3a0e000 e5990000 e1a01006 (e5de2011) 
---[ end trace fee705e27e6703b6 ]---
[sched_delayed] sched: RT throttling activated

CTRL-A Z for help | 115200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyUSB0                                                                                                                                                     
```



# 键盘两个hid描述符

```
=====>$usbhid-dump -s1:20 -i0 | grep -v ":" | xxd -r -p | hidrd-convert -o code
0x05, 0x01,         /*  Usage Page (Desktop),               */
0x09, 0x06,         /*  Usage (Keyboard),                   */
0xA1, 0x01,         /*  Collection (Application),           */
0x05, 0x08,         /*      Usage Page (LED),               */
0x19, 0x01,         /*      Usage Minimum (01h),            */
0x29, 0x03,         /*      Usage Maximum (03h),            */
0x15, 0x00,         /*      Logical Minimum (0),            */
0x25, 0x01,         /*      Logical Maximum (1),            */
0x75, 0x01,         /*      Report Size (1),                */
0x95, 0x03,         /*      Report Count (3),               */
0x91, 0x02,         /*      Output (Variable),              */
0x95, 0x05,         /*      Report Count (5),               */
0x91, 0x01,         /*      Output (Constant),              */
0x05, 0x07,         /*      Usage Page (Keyboard),          */
0x19, 0xE0,         /*      Usage Minimum (KB Leftcontrol), */
0x29, 0xE7,         /*      Usage Maximum (KB Right GUI),   */
0x95, 0x08,         /*      Report Count (8),               */
0x81, 0x02,         /*      Input (Variable),               */
0x75, 0x08,         /*      Report Size (8),                */
0x95, 0x01,         /*      Report Count (1),               */
0x81, 0x01,         /*      Input (Constant),               */
0x19, 0x00,         /*      Usage Minimum (None),           */
0x29, 0x91,         /*      Usage Maximum (KB LANG2),       */
0x26, 0xFF, 0x00,   /*      Logical Maximum (255),          */
0x95, 0x06,         /*      Report Count (6),               */
0x81, 0x00,         /*      Input,                          */
0xC0                /*  End Collection                      */

=====>$usbhid-dump -s1:20 -i1 | grep -v ":" | xxd -r -p | hidrd-convert -o code
0x05, 0x0C,         /*  Usage Page (Consumer),              */
0x09, 0x01,         /*  Usage (Consumer Control),           */
0xA1, 0x01,         /*  Collection (Application),           */
0x85, 0x01,         /*      Report ID (1),                  */
0x19, 0x00,         /*      Usage Minimum (00h),            */
0x2A, 0x3C, 0x02,   /*      Usage Maximum (AC Format),      */
0x15, 0x00,         /*      Logical Minimum (0),            */
0x26, 0x3C, 0x02,   /*      Logical Maximum (572),          */
0x95, 0x01,         /*      Report Count (1),               */
0x75, 0x10,         /*      Report Size (16),               */
0x81, 0x00,         /*      Input,                          */
0xC0,               /*  End Collection,                     */
0x05, 0x01,         /*  Usage Page (Desktop),               */
0x09, 0x80,         /*  Usage (Sys Control),                */
0xA1, 0x01,         /*  Collection (Application),           */
0x85, 0x02,         /*      Report ID (2),                  */
0x19, 0x81,         /*      Usage Minimum (Sys Power Down), */
0x29, 0x83,         /*      Usage Maximum (Sys Wake Up),    */
0x25, 0x01,         /*      Logical Maximum (1),            */
0x75, 0x01,         /*      Report Size (1),                */
0x95, 0x03,         /*      Report Count (3),               */
0x81, 0x02,         /*      Input (Variable),               */
0x95, 0x05,         /*      Report Count (5),               */
0x81, 0x01,         /*      Input (Constant),               */
0xC0                /*  End Collection                      */
```

# R usb

```
#                                                                         
# USB Host Controller Drivers                                             
#                                                                         
# CONFIG_USB_C67X00_HCD is not set                                        
CONFIG_USB_XHCI_HCD=y                                                     
CONFIG_USB_XHCI_PCI=y                                                     
CONFIG_USB_XHCI_PLATFORM=m                                                
CONFIG_USB_XHCI_HISILICON=m                                               
CONFIG_USB_EHCI_HCD=y                                                     
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set                                  
CONFIG_USB_EHCI_TT_NEWSCHED=y                                             
CONFIG_USB_EHCI_PCI=y                                                     
CONFIG_USB_EHCI_HCD_PLATFORM=m                                            
# CONFIG_USB_OXU210HP_HCD is not set                                      
# CONFIG_USB_ISP116X_HCD is not set                                       
# CONFIG_USB_ISP1760_HCD is not set                                       
# CONFIG_USB_ISP1362_HCD is not set                                       
# CONFIG_USB_FUSBH200_HCD is not set                                      
# CONFIG_USB_FOTG210_HCD is not set                                       
# CONFIG_USB_MAX3421_HCD is not set                                       
CONFIG_USB_OHCI_HCD=y                                                     
CONFIG_USB_OHCI_HCD_PCI=y                                                 
CONFIG_USB_OHCI_HCD_PLATFORM=m                                            
# CONFIG_USB_UHCI_HCD is not set                                          
# CONFIG_USB_SL811_HCD is not set                                         
# CONFIG_USB_R8A66597_HCD is not set                                      
# CONFIG_USB_HCD_TEST_MODE is not set                                     
```



# thinkpad mouse

PC端windows系统获取HID设备的Report Description失败

## Device端处理流程

hi_hs_dev：



```
/**                                                            
 * States of EP0.                                              
 */                                                            
typedef enum ep0_state {                                       
    EP0_DISCONNECT,     /* no host */                          
    EP0_IDLE,                                                  
    EP0_IN_DATA_PHASE,                                         
    EP0_OUT_DATA_PHASE,                                        
    EP0_IN_STATUS_PHASE,                                       
    EP0_OUT_STATUS_PHASE,                                      
    EP0_STALL,                                                 
} ep0state_e;                                                  
```

PC端获取Report Description时，ep0的状态变化：

```
================> func: handle_ep0, line: 3189, ep0state=4
================> func: handle_ep0, line: 3189, ep0state=1
===> func: pcd_setup, line: 1803
===> func: pcd_setup, line: 1893, bRequest=6
===> func: pcd_setup, line: 1925
===> func: do_gadget_setup, line: 1306
===> func: _setup, line: 713
HID Gadget: hid_setup crtl_request : bRequestType:0x81 bRequest:0x6 Value:0x2200
HID Gadget: USB_REQ_GET_DESCRIPTOR: REPORT
hidg_setup report desc report_desc_length=64:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x03 0x75 0x01 0x81 0x02 0x95 0x01 0x75 0x05 0x81 0x01 
0x05 0x01 0x09 0x30 0x09 0x31 0x16 0x01 0x80 0x26 0xff 0x7f 0x75 0x10 0x95 0x02 
0x81 0x06 0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x01 0x81 0x06 0xc0 0xc0 

===> func: ep_queue, line: 420, retval=0
===> func: ep_queue, line: 425
===> func: hidg_setup, line: 447, status=0
===> func: composite_setup, line: 1313, value=0
===> func: _setup, line: 725, retval=0
===> func: do_gadget_setup, line: 1310, ret=0
================> func: handle_ep0, line: 3189, ep0state=2
```

正常鼠标插入后ep0状态的变化：

```
================> func: handle_ep0, line: 3189, ep0state=4
================> func: handle_ep0, line: 3189, ep0state=1
===> func: pcd_setup, line: 1803
===> func: pcd_setup, line: 1893, bRequest=6
===> func: pcd_setup, line: 1925
===> func: do_gadget_setup, line: 1306
===> func: _setup, line: 713
HID Gadget: hid_setup crtl_request : bRequestType:0x81 bRequest:0x6 Value:0x2200
HID Gadget: USB_REQ_GET_DESCRIPTOR: REPORT
hidg_setup report desc report_desc_length=46:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x08 0x75 0x01 0x81 0x02 0x05 0x01 0x09 0x30 0x09 0x31 
0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x03 0x81 0x06 0xc0 0xc0 
===> func: ep_queue, line: 420, retval=0
===> func: ep_queue, line: 425
===> func: hidg_setup, line: 447, status=0
===> func: composite_setup, line: 1313, value=0
===> func: _setup, line: 725, retval=0
===> func: do_gadget_setup, line: 1310, ret=0
================> func: handle_ep0, line: 3189, ep0state=2
DATA_IN EP0-IN: type=0, mps=64
===> func: handle_ep0, line: 3248, CONTINUE TRANSFER
===> func: handle_ep0, line: 3251
================> func: handle_ep0, line: 3189, ep0state=5
```

## ep0状态变化

根据pc端给的中断

### dwc中断

```
 DWC_DEBUGPL(DBG_ANY, "registering handler for irq%d\n", _dev->resource[1].start);           
 retval = request_irq(_dev->resource[1].start, dwc_otg_pcd_irq,                             
              IRQF_SHARED | IRQF_DISABLED,  
              gadget_wrapper->gadget.name, otg_dev->pcd);   
```

```
static irqreturn_t dwc_otg_pcd_irq(int irq, void *dev)                 
{                                                                      
    dwc_otg_pcd_t *pcd = dev;                                          
    int32_t retval = IRQ_NONE;                                         
                                                                       
    retval = dwc_otg_pcd_handle_intr(pcd);                             
    if (retval != 0)                                                   
        S3C2410X_CLEAR_EINTPEND();                                     
                                                                       
    return IRQ_RETVAL(retval);                                         
}                                                                      
```



获取描述符

1. inepint

```
 if (gintr_status.b.inepint) {                            
     if (!core_if->multiproc_int_enable)                  
         retval |= dwc_otg_pcd_handle_in_ep_intr(pcd);    
                                                          
 }                                                        
```

2. outepint

```
if (gintr_status.b.outepintr) {                                     
    otg_usbhost_stat = 1;                                           
    if (!core_if->multiproc_int_enable)                             
        retval |= dwc_otg_pcd_handle_out_ep_intr(pcd);              
                                                                    
}                                                                   
```

> thinkpad鼠标无法枚举主要是Device端没有检测到outepint中断

在report描述符写入PC端host后，device端没有检测到OUT Endpoints Interrupt



- 写入的report描述符，从鼠标获取的一致
- 控制器将描述符通过ep0发送出去后，dwc控制器没有检测到中断，该中断由host端的PC发起
- PC没有给中断，可能与report描述符的解析相关，对比分析report描述符的区别





```
~ # dwc_otg: version 3.00a 10-AUG-2012
Core Release: 3.10a
Setting default values for core params
Using Buffer DMA mode
Periodic Transfer Interrupt Enhancement - disabled
Multiprocessor Interrupt Enhancement - disabled
OTG VER PARAM: 0, OTG VER FLAG: 0
Dedicated Tx FIFOs mode
dinfo: bustype:[0x00000003], vendor:[0x10c4], product:[0xffff8108]
structure_func_desc report desc report_desc_length=64:
0x05 0x01 0x09 0x02 0xa1 0x01 0x09 0x01 0xa1 0x00 0x05 0x09 0x19 0x01 0x29 0x03 
0x15 0x00 0x25 0x01 0x95 0x03 0x75 0x01 0x81 0x02 0x95 0x01 0x75 0x05 0x81 0x01 
0x05 0x01 0x09 0x30 0x09 0x31 0x16 0x01 0x80 0x26 0xff 0x7f 0x75 0x10 0x95 0x02 
0x81 0x06 0x09 0x38 0x15 0x81 0x25 0x7f 0x75 0x08 0x95 0x01 0x81 0x06 0xc0 0xc0 

structure_func_desc: subclass=1, protocol=2, report_length=8, report_desc_length=64
redefine_dev_id: idVendor=0x10c4, idProduct=0x8108
g_hid gadget: HID Gadget, version: 2010/03/16
g_hid gadget: g_hid ready
```

