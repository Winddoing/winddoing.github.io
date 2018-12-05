---
title: Frame Buffer
date: 2018-12-04 8:07:24
comments: true
---

{% centerquote %} Frame Bufferr 子系统 {% endcenterquote %}

版本：`linux 4.4.y`

## 整体框架

![fb_frame](/images/2018/12/fb_frame.png)
>filr: drivers/video/fbdev/core

## 方向

驱动代码的分析，一方面结合内核自身的结构，另一方面是驱动设备的`数据流`（从应用的角度）

1. 从fb子系统的注册和对应用层的接口API
2. 控制器结合子系统的`数据流`和控制结构

## 初始化－－fbmem_init

``` C
static int __init                                                                                    
fbmem_init(void)                                                                                     
{                                                                                                    
    proc_create("fb", 0, NULL, &fb_proc_fops);  //proc目录下创建fb, ???                                                     

    if (register_chrdev(FB_MAJOR,"fb",&fb_fops))                                                     
        printk("unable to get major %d for fb devs\n", FB_MAJOR);                                    

    fb_class = class_create(THIS_MODULE, "graphics");                                                
    if (IS_ERR(fb_class)) {                                                                          
        printk(KERN_WARNING "Unable to create fb class; errno = %ld\n", PTR_ERR(fb_class));          
        fb_class = NULL;                                                                             
    }                                                                                                
    return 0;                                                                                        
}                                                                                                    
```
>file: drivers/video/fbdev/core/fbmem.c

### /proc/fb

帧缓冲设备列表，代表的`帧缓冲设备编号`和`驱动程序`

>This file contains a list of frame buffer devices, with the frame buffer device number and the driver that controls it. [^/proc/fb](https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-proc-fb.html)

```
=====>$cat /proc/fb
0 radeondrmfb
```
> PC测试

## 数据结构

### fb_info

``` C
struct fb_info {
	atomic_t count;
	int node;
	int flags;
	struct mutex lock;		/* Lock for open/release/ioctl funcs */
	struct mutex mm_lock;		/* Lock for fb_mmap and smem_* fields */
	struct fb_var_screeninfo var;	/* Current var */
	struct fb_fix_screeninfo fix;	/* Current fix */
	struct fb_monspecs monspecs;	/* Current Monitor specs */
	struct work_struct queue;	/* Framebuffer event queue */
	struct fb_pixmap pixmap;	/* Image hardware mapper */
	struct fb_pixmap sprite;	/* Cursor hardware mapper */
	struct fb_cmap cmap;		/* Current cmap */
	struct list_head modelist;      /* mode list */
	struct fb_videomode *mode;	/* current mode */

#ifdef CONFIG_FB_BACKLIGHT
	/* assigned backlight device */
	/* set before framebuffer registration,
	   remove after unregister */
	struct backlight_device *bl_dev;

	/* Backlight level curve */
	struct mutex bl_curve_mutex;
	u8 bl_curve[FB_BACKLIGHT_LEVELS];
#endif
#ifdef CONFIG_FB_DEFERRED_IO
	struct delayed_work deferred_work;
	struct fb_deferred_io *fbdefio;
#endif

	struct fb_ops *fbops;
	struct device *device;		/* This is the parent */
	struct device *dev;		/* This is this fb device */
	int class_flag;                    /* private sysfs flags */
#ifdef CONFIG_FB_TILEBLITTING
	struct fb_tile_ops *tileops;    /* Tile Blitting */
#endif
	union {
		char __iomem *screen_base;	/* Virtual address */
		char *screen_buffer;
	};
	unsigned long screen_size;	/* Amount of ioremapped VRAM or 0 */
	void *pseudo_palette;		/* Fake palette of 16 colors */
#define FBINFO_STATE_RUNNING	0
#define FBINFO_STATE_SUSPENDED	1
	u32 state;			/* Hardware state i.e suspend */
	void *fbcon_par;                /* fbcon use-only private area */
	/* From here on everything is device dependent */
	void *par;
	/* we need the PCI or similar aperture base/size not
	   smem_start/size as smem_start may just be an object
	   allocated inside the aperture so may not actually overlap */
	struct apertures_struct {
		unsigned int count;
		struct aperture {
			resource_size_t base;
			resource_size_t size;
		} ranges[0];
	} *apertures;

	bool skip_vt_switch; /* no VT switch on suspend/resume required */
};
```

``` C
struct fb_info *registered_fb[FB_MAX] __read_mostly;
```
定义全局的`fb_info`的数组用于管理,fb驱动



## 参考

* [Framebuffer 驱动学习总结（一） ---- 总体架构及关键结构体](http://www.cnblogs.com/EaIE099/p/5175979.html)
