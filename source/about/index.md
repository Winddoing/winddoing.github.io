---
title: 关于
date: 2016-08-18 23:07:24
comments: true
---

{% centerquote %} *** 涸辙遗鲋，旦暮成枯；人而无志，与彼何殊 *** {% endcenterquote %}

{% centerquote %} 自由之地，书我所想，记我所需 {% endcenterquote %}


* 2013.04: 第一次接触博客[Chinaunix](http://blog.chinaunix.net/uid/28769209.html)。
* 2013.09: 第二次[CSDN](https://blog.csdn.net/sdreamq)---由于Chinaunix中文章的排版不方便，选择了CSDN。
* 2014.02: 在无意中发现了Github，并且可以搭建静态网站，喜欢折腾的我选择了[github](https://xxx.github.io)。
* 2014.02: 第一个Github上的Jekyll网站的[搭建](https://winddoing.github.io/post/32555.html),其中有过中断，有过变更，依稀记得还使用过hexo，由于当时的不懂，导致很多在本地的博客文章丢失，在学生时期的我对笔记的记录直接转为[word](https://winddoing.github.io/old_notes/)，博客也就慢慢淡淡了。
* 2016.08: 工作一年以后，由于工作中的一些总结和问题，需要一个可以共享的笔记，想起的github，网上看到了`next`主题，喜欢他的简洁，同时又有`Travic_CI`与Github中的仓库的持续集成后，选择使用`Github`、`hexo`、`next`和`Travic_CI`搭建新的[博客](https://winddoing.github.io)。
* 2016.11: 升级主题`next v5.0.1`。
* 2017.07: 升级主题`next v5.1.1`。
* 2018.02: 升级主题`next v5.1.4`。
* 2018.07: 添加[DaoVoice](http://www.daovoice.io)和开通打赏功能.
* 2018.09: 添加[CNZZ统计](http://www.cnzz.com/stat/website.php?web_id=1254703532)
* 2019.11: 重写`Travic_ci`自动构建脚本，升级`hexo`与`nodejs`等，为缩短自动构建时间和部分构建错误。同时将网站镜像备份到[https://winddoing.gitee.io](https://winddoing.gitee.io)
* 2020.01: 升级主题`next v7.7.0`, 为了提高网站的加载速度和构建速度。
* 至今依旧： ***使用，简单方便，升级主要是当时博客出现问题。***

其他： {% button ../books,阅读,book fa-fw,books%} {% button ../ana,ANA,book fa-fw,books%} {% button ../top,阅读排列,line-chart fa-fw,books%} {% button ../software,常用软件,cogs fa-fw,books%} {% button ../downloads,下载,download fa-fw,books%}

{% centerquote %} 合抱之木，生于毫末；九层之台，起于累土；千里之行，始于足下。{% endcenterquote %}

{% note success %}
网站构建，源码大小：`data_SZ MB`, 构建次数：`build_CN`, 最后一次构建时间：`xdate`;
{% endnote %}

{% tabs First unique name %}
<!-- tab 网站配置 -->

* [hexo的next主题个性化教程：打造炫酷网站](https://blog.csdn.net/qq_33699981/article/details/72716951)
* [DaoVoice](https://dashboard.daovoice.io/app/a28f1641/users?segment=all-users)
* [小图标](https://fontawesome.com/icons?from=io)

<!-- endtab -->

<!-- tab 联系方式 -->

- 邮箱：winddoing@sina.cn

<!-- endtab -->

<!-- tab 捐助 -->

![alipay](/images/alipay.jpg)

<!-- endtab -->

<!-- tab 自动构建 -->

| 模块  | 图标  |
|:-----:|:-----:|
| 本站 | <a href="https://travis-ci.org/Winddoing/Winddoing.github.io"><img src="https://travis-ci.org/Winddoing/Winddoing.github.io.svg?branch=web_source"></a> |
| 相册 | <a href="https://winddoing.coding.net/p/photos-data/ci/job"><img src="https://winddoing.coding.net/badges/photos-data/job/264981/master/build.svg"></a> |

<!-- endtab -->

{% endtabs %}

>**每日一言**:
<span id="hitokoto" style="margin-left:7px;"> :D 获取中一言...</span>
<p align="right" id="afrom"></p>
<script src="https://cdn.jsdelivr.net/npm/bluebird@3/js/browser/bluebird.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/whatwg-fetch@2.0.3/fetch.min.js"></script>
<script>
    fetch('https://v1.hitokoto.cn/?c=d&c=e&c=i&c=k')
    .then(function (res){
        return res.json();
    })
    .then(function (data) {
        var hitokoto = document.getElementById('hitokoto');
        var afrom = document.getElementById('afrom');
        hitokoto.innerText = data.hitokoto;
        afrom.innerText =  '——【' + data.from + ' ' + data.from_who + '】';
    })
    .catch(function (err) {
        console.error(err);
    })
</script>
