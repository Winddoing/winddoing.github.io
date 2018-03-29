---
title: I2C驱动
date: 2018-03-28 23:07:24
categories: 设备驱动
tags: [driver, I2C]
---

```
                          +---------+
+----------+              |         |
| CPU      |              |  codec1 |
|          |              +-+-----+-+
|      +---+                |     |                       +------+
|      |I2C|                |     |                       |      |
|      |   <----------------------------------------------+ codec|
|      |   <----------------------v-----------------------+      |
|      +---+                                              |      |
|          |                                              +------+
+----------+
```

I2C: 以1根串行数据线`（SDA）`和1根串行时钟线`（SCL）`实 现了双工的同步数据传输。具有接口线少，控制方式简化，器件封装形式小，通信速率较高等优点。在主从通信中，可以有多个I2C总线器件同时接到I2C总线上，通过`地址`来识别通信对象, `应答`来互通数据及命令。

速度模式：
* 标准模式下可达到`100Kbps`
* 快速模式下可达到`400Kbps`
* 高速模式下达到`4Mbps`

<!--more-->

## 协议

## 时序

## 设备定义（DTS）

```
&i2c4 {
	status = "okay";
	clock-frequency = <100000>;
	timeout = <1000>;
	pinctrl-names = "default";
	pinctrl-0 = <&i2c4_pd>;

	ak4458: dac@0x10 {
		compatible = "asahi-kasei,ak4458";
		status = "okay";
		reg = <0x10>;
		reset-gpios = <&gpd 7 GPIO_ACTIVE_HIGH INGENIC_GPIO_NOBIAS>;
		xxmute-gpios = <&gpc 4 GPIO_ACTIVE_HIGH INGENIC_GPIO_NOBIAS>;
	};

	...
}
```

## acpi

## 参考

1. [Linux I2C framework(3)_I2C consumer](http://www.wowotech.net/linux_kenrel/i2c_consumer.html)
2. [示波器分析I2C时序波形图](https://blog.csdn.net/ASKLW/article/details/77834077)
3. [I2C设备调试及波形分析](https://blog.csdn.net/smallmuou/article/details/7183656)
