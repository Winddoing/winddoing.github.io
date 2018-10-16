---
title: 阅读排行
date: 2018-10-16 22:43:10
type: "top"
comments: false
---

<div id="top"></div>
<script src="https://cdn1.lncld.net/static/js/av-core-mini-0.6.4.js"></script>
<script>AV.initialize("Q8qpjA3fOO7FEUBqcmcQFptF-gzGzoHsz", "tgUTq5bX3fVmn916EMRe65eJ");</script>
<script type="text/javascript">
	var time=0
	var title=""
	var url=""
	var query = new AV.Query('Counter');
	query.notEqualTo('id',0);
	query.descending('time');
	query.limit(1000);
	query.find().then(function (todo) {
	for (var i=0;i<20;i++){
		var result=todo[i].attributes;
		time=result.time;
		title=result.title;
		url=result.url;
		var content="<p>"+"<font color='#1C1C1C'>"+"【文章热度:"+time+"℃】"+"</font>"+"<a href='"+"https://winddoing.github.io"+url+"'>"+title+"</a>"+"</p>";
		document.getElementById("top").innerHTML+=content
		}
	}, function (error) {
		console.log("error");
	});
</script>
