---
title: About
date: 2016-08-18 23:07:24
comments: false
---

{% cq %}
<!-- 站点运行时间 -->
<div id="days"></div>
{% endcq %}


{% tabs about author %}
<!-- tab 博主相关@user -->

## 联系
email,qq,github and more...
<!-- endtab -->

<!-- tab 站点相关@home -->
## 站点及插件版本
<!-- endtab -->

<!-- tab ️🌱 友情链接 -->
暂时没有友链哟 `(ﾉ*･ω･)ﾉ～`
想添加友链可以在下方留言~
<!-- endtab -->
{% endtabs %}

{% centerquote %} ### 涸辙遗鲋，旦暮成枯；人而无志，与彼何殊 ### {% endcenterquote %}

{% centerquote %} 自由之地，书我所想，记我所需 {% endcenterquote %}

* 2013.04: 第一次接触博客[Chinaunix](http://blog.chinaunix.net/uid/28769209/year-201304-list-1.html)。
* 2013.09: 第二次[CSDN](https://blog.csdn.net/sdreamq)---由于Chinaunix中文章的排版不方便，选择了CSDN。
* 2014.02: 在无意中发现了Github，并且可以搭建静态网站，喜欢折腾的我选择了[github](https://shaowangquan.github.io)。
* 2014.02: 第一个Github上的Jekyll网站的[搭建](https://winddoing.github.io/2014/02/26/2014-02-26-Github+jekyll%E5%8D%9A%E5%AE%A2%E7%BB%88%E4%BA%8E%E6%90%AD%E5%BB%BA%E5%A5%BD%E4%BA%86/),其中有过中断，有过变更，依稀记得还使用过hexo，由于当时的不懂，导致很多在本地的博客文章丢失，在学生时期的我对笔记的记录直接转为[word](https://winddoing.github.io/old_notes/)，博客也就慢慢淡淡了。
* 2016.08: 工作一年以后，由于工作中的一些总结和问题，需要一个可以共享的笔记，想起的github，网上看到了`next`主题，喜欢他的简洁，同时又有`Travic_CI`与Github中的仓库的持续集成后，选择使用`Github`、`hexo`、`next`和`Travic_CI`搭建新的[博客](https://winddoing.github.io)。
* 2016.11: 升级主题`next v5.0.1`。
* 2017.07: 升级主题`next v5.1.1`。
* 2018.02: 升级主题`next v5.1.4`。
* 2018.07: 添加[DaoVoice](http://www.daovoice.io)和开通打赏功能.
* 至今依旧： ***使用，简单方便，升级主要是当时博客出现问题。***

- winddoing@sina.cn #【[BOOK](../books)】#【[ANA](../ana)】#【[MUSIC](../music)】


## 网站配置

* [hexo的next主题个性化教程：打造炫酷网站](https://blog.csdn.net/qq_33699981/article/details/72716951)
* [DaoVoice](https://dashboard.daovoice.io/app/a28f1641/users?segment=all-users)


<script>
/* 站点运行时间 */
function show_date_time(){
	window.setTimeout("show_date_time()", 1000);
	/* 请修改这里的起始时间 */
	BirthDay=new Date("02/26/2014 15:00:00");
	today=new Date();
	timeold=(today.getTime()-BirthDay.getTime());
	sectimeold=timeold/1000
	secondsold=Math.floor(sectimeold);
	msPerDay=24*60*60*1000
	e_daysold=timeold/msPerDay
	daysold=Math.floor(e_daysold);
	e_hrsold=(e_daysold-daysold)*24;
	hrsold=setzero(Math.floor(e_hrsold));
	e_minsold=(e_hrsold-hrsold)*60;
	minsold=setzero(Math.floor((e_hrsold-hrsold)*60));
	seconds=setzero(Math.floor((e_minsold-minsold)*60));
	document.getElementById('days').innerHTML="本站已运行"+daysold+"天"+hrsold+"小时"+minsold+"分"+seconds+"秒";
}

function setzero(i){
	if (i<10) {
		i="0" + i;
	}
	return i;
}

show_date_time();
</script>>)}
