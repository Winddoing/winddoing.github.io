---
layout: post
title: Travis CI的部署与发布
date: '2020-06-15 23:25'
tags:
  - travis-ci
  - github
categories:
  - 工具
abbrlink: 768dddf0
---

由于国内对一些资源的限制，在无法翻墙的情况下，借助于Travis CI的部署发布功能进行代码的编译，将最终的二进制文件发布后下载使用。
比如编译[libwebrtc](https://github.com/aisouard/libwebrtc)，生产静态库和一些头文件，供本地开发使用。

<!--more-->



## The Job Lifecycle [#](https://docs.travis-ci.com/user/job-lifecycle#the-job-lifecycle)

Each *job* is a sequence of [phases](https://docs.travis-ci.com/for-beginners/#builds-jobs-stages-and-phases). The *main phases* are:

1. `install` - install any dependencies required
2. `script` - run the build script

Travis CI can run custom commands in the phases:

1. `before_install` - before the install phase
2. `before_script` - before the script phase
3. `after_script` - after the script phase.
4. `after_success` - when the build *succeeds* (e.g. building documentation), the result is in `TRAVIS_TEST_RESULT` environment variable
5. `after_failure` - when the build *fails* (e.g. uploading log files), the result is in `TRAVIS_TEST_RESULT` environment variable

There are three optional *deployment phases*.

The complete sequence of phases of a job is the lifecycle. The steps are:

1. OPTIONAL Install [`apt addons`](https://docs.travis-ci.com/user/installing-dependencies/#installing-packages-with-the-apt-addon)
2. OPTIONAL Install [`cache components`](https://docs.travis-ci.com/user/caching)
3. `before_install`
4. `install`
5. `before_script`
6. `script`
7. OPTIONAL `before_cache` (if and only if caching is effective)
8. `after_success` or `after_failure`
9. OPTIONAL `before_deploy` (if and only if deployment is active)
10. OPTIONAL `deploy`
11. OPTIONAL `after_deploy` (if and only if deployment is active)
12. `after_script`

> A *build* can be composed of many jobs.



## Travis CI关键字

| 关键字 | 描述  |
|:-:|:-:|
| `dist`  | 指定系统版本,dist: bionic(ubuntu18.04)  |

## 添加python

```
python:
   - "3.6"
```

## deploy

```
deploy:
  provider: releases
  api_key: $GITHUB_TOKEN
  file_glob: true
  file: "${TRAVIS_ARTIFACTS}"
  skip_cleanup: true
  on:
    tags: true
    repo: Winddoing/libwebrtc
```
> https://raw.githubusercontent.com/Winddoing/libwebrtc/mydev/.travis.yml

- `GITHUB_TOKEN`: setting->Developer settings->Personal access tokens:Generate new token


## 参考

- [Travis CI Tutorial](https://docs.travis-ci.com/user/tutorial/)
