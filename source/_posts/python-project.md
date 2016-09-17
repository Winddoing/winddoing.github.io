---
title: 【转】pyton练习项目
date: 2016-09-10 23:07:24
categories: Python
tags: [python]
---

转载再次，自己实现练习python
本书链接 http://aosabook.org/blog/
目录页：http://aosabook.org/blog/
以下是章节目录，每一章都让你热血澎湃，看完介绍你就向往下读。
1. A Template Engine （http://aosabook.org/en/500L/a-template-engine.html）
MVC模型中的view层如何解析html中的静态变量和简单的语句，如下：

<p>Welcome, {name}!</p>
<p>Products:</p>
<ul>
{products}
</ul>
<!---more--->

web中的view层不只是html代码，还有支持其他的代码。比如 {products}是一个变量。 同时view层还支持{if} , {for}, {foreach}等等。django，velocity等是如何解析他们的？
大牛用不到500行代码告诉你，是如何实现的？ （不是替换，替换需要每次请求都需要解析）

2. Web Spreadsheet （http://aosabook.org/en/500L/web-spreadsheet.html）
web的电子表格如何实现的？ 好像比较简单，但是介绍了 web storage 和 web worker，还是很值得一看的

3. A Web Crawler http://aosabook.org/en/500L/a-web-crawler-with-asyncio-coroutines.html
不多说，几百行代码实现高效的网络爬虫， 高效！

4. Static Analysis http://aosabook.org/en/500L/static-analysis.html
成熟的IDE都有代码检查和代码提示，怎么做的？ 看这章

5. Clustering by Consensus http://aosabook.org/en/500L/clustering-by-consensus.html
分布式系统 paxos原理与实现。不知道paxos说明你没接触过分布式体统，接触过分布式还不懂，说明你只会用分布式系统

6. A Simple Object Modle http://aosabook.org/en/500L/a-simple-object-model.html
Python是面向对象语言，对象，继承，多态，怎么用代码实现的，不到500行代码，实际不到400 行， 666.。。

7. An Archaeology-Inspired Database http://aosabook.org/en/500L/an-archaeology-inspired-database.html
如何用python实现一个数据库，支持 query，index, transaction， 2，3百行代码和对每个函数的讲解。看完你就知道知道数据库原理，太值了

8. Dog Bed Database http://aosabook.org/en/500L/dbdb-dog-bed-database.html
类似上一章，不过这次实现的是key-value的非关系型数据库，详细的讲解和2，3百行代码

9. A 3D Modeller http://aosabook.org/en/500L/a-3d-modeller.html
用python实现一个3D设计，显示到屏幕，可以交互。不是很懂，但不明觉厉

10. A Python Interpreter Written in Python http://aosabook.org/en/500L/a-python-interpreter-written-in-python.html
手把手教你如何实现python解析器。

11. A Pedometer in the Real World http://aosabook.org/en/500L/a-pedometer-in-the-real-world.html
你用过手机应用记录你每天走的步数，然后发送到朋友圈吗？ （没有？ 没关系。）这章告诉你如何实现步数记录，怎么算走一步。手机中有加速记，很容易获得你某一时刻在x,y,z三个方向的加速度，用这些参数，如何计算你走了多少步？ 知道吗？ 不知道，看这章，讲解加实现

12. A Continuous Intergration System http://aosabook.org/en/500L/a-continuous-integration-system.html
CI System是一个专门用来测试新代码的系统，根据代码提交记录，拿到新的代码，测试，生成报告。这不是关键，关键是 如果test失败，它还会 恢复，然后从失败的那个点在跑，相当于把出错环境重现了。。。

13 A Rejection Sampler http://aosabook.org/en/500L/a-rejection-sampler.html
不是很懂，和机器学习相关，如何 计算你赢得象棋比赛的概率，天气对飞机的影响等类似的问题

14 A visual programming toolkit http://aosabook.org/en/500L/blockcode-a-visual-programming-toolkit.html
不太明白

15. A Flow Shop Scheduler http://aosabook.org/en/500L/a-flow-shop-scheduler.html
flowshop调度问题，好像很出名的样子，最优化问题，如何从局部最优解找全局最优解

16 Optical Character Recognition
几百行代码使用人工神经网络实现识别手写字母。。。

github源码：500lines/README.md at master · aosabook/500lines · GitHub

作者：小小搬运工
链接：http://www.zhihu.com/question/29372574/answer/88624507
来源：知乎
著作权归作者所有，转载请联系作者获得授权。
