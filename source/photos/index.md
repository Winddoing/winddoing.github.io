---
title: 摄影
date: 2019-3-30 22:32:22
type: "photos"
comments: false
---

<link rel="stylesheet" href="./ins.css">
<link rel="stylesheet" href="./photoswipe.css">
<link rel="stylesheet" href="./default-skin/default-skin.css">

<script src="./photoswipe.js"></script>
<script src="./photoswipe-ui-default.js"></script>

<!---
<div class="photos-btn-wrap">
    <a class="photos-btn active" href="javascript:void(0)">Photos</a>
    <a class="photos-btn" href="/photos/videos.html">Videos</a>
</div>
--->

{% centerquote %}
   ** 一个人的行走范围，就是他的世界。**——北岛
{% endcenterquote %}


<div class="instagram itemscope">
    <a href="https://winddoing.github.io" target="_blank" class="open-ins">图片正在加载中…</a>
</div>

<script>
    (function() {
        var loadScript = function(path) {
            var $script = document.createElement('script')
            document.getElementsByTagName('body')[0].appendChild($script)
            $script.setAttribute('src', path)
        }
        setTimeout(function() {
            loadScript('./ins.js')
        }, 0)
    })()
</script>

<span id="busuanzi_container_page_pv">
    浏览量: <span id="busuanzi_value_page_pv"></span>次
</span>


<!-- Root element of PhotoSwipe. Must have class pswp. -->
<div class="pswp" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="pswp__bg"></div>
    <div class="pswp__scroll-wrap">
        <div class="pswp__container">
            <div class="pswp__item"></div>
            <div class="pswp__item"></div>
            <div class="pswp__item"></div>
        </div>
        <div class="pswp__ui pswp__ui--hidden">
            <div class="pswp__top-bar">
                <div class="pswp__counter"></div>
                <button class="pswp__button pswp__button--close" title="Close (Esc)"></button>
                <button class="pswp__button pswp__button--share" title="Share"></button>
                <button class="pswp__button pswp__button--fs" title="Toggle fullscreen"></button>
                <button class="pswp__button pswp__button--zoom" title="Zoom in/out"></button>
                <!-- Preloader demo http://codepen.io/dimsemenov/pen/yyBWoR -->
                <!-- element will get class pswp__preloader--active when preloader is running -->
                <div class="pswp__preloader">
                    <div class="pswp__preloader__icn">
                        <div class="pswp__preloader__cut">
                            <div class="pswp__preloader__donut"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="pswp__share-modal pswp__share-modal--hidden pswp__single-tap">
                <div class="pswp__share-tooltip"></div>
            </div>
            <button class="pswp__button pswp__button--arrow--left"
                    title="Previous (arrow left)">
            </button>
            <button class="pswp__button
                                       pswp__button--arrow--right"
                    title="Next (arrow right)">
            </button>
            <div
                class="pswp__caption">
                <div
                    class="pswp__caption__center"></div>
            </div>
        </div>
    </div>
</div>
