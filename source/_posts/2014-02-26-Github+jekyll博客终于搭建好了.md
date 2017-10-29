---
date: 2014-02-26
layout: post
title: Github搭建博客的简单记录
thread: 146
categories: Git
tags: Git
---

### 起源

  * 自从想写博客开始，就一直在找一个网站写一些自己的博文。把自己的在学习中的一些体验与心得记录下来。之前在一些网站上注册过一些[博客](http://blog.csdn.net/sdreamq)，可是广告太多了，文本格式编排很麻烦。后来看到了[搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)这篇文章，就一直想这搭建一个这样的博客，终于在这个寒假接近尾声之际搭建好了。其中遇到了各种麻烦真是一言难尽，在这里简单记录一些搭建过程。

### 博客搭建

##### 1. 安装[jekyll](http://jekyllrb.com/)进行博客站点的本地预览
  * jekyll的安装需要提前安装ruby
  * $ sudo apt-get ruby1.9.1-dev
  *	$ gem install rdiscount
  *	$ gem install RedCloth

<!--more-->
##### 2. 安装Git将站点文件提交到[Github](http://github.com)
  * 在本地站点库目录下
  *	$ git init
  *	$ git add .
  *	$ git commit -m "first page"
  *	$ git remote add origin https://github.com/username/username.github.com.git
  * $ git push -u origin master

##### 3. 利用jekyll进行本地预览
  * 终端执行：

  * $ jekyll serve

  然后在浏览器访问[http://0.0.0.0:4000/]

### 参考
  * 本站主题是直接从[Luyf](https://github.com/december)clone下来的。
  * [搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)
  * [使用Jekyll在GitHub上架设Blog](http://blog.it580.com/%E4%BD%BF%E7%94%A8jekyll%E5%9C%A8github%E4%B8%8A%E6%9E%B6%E8%AE%BEblog/)
  * [像黑客一样写博客——Jekyll入门](http://www.soimort.org/posts/101/)
  * [Markdown 语法说明 (简体中文版) ](http://wowubuntu.com/markdown/)
