---
layout: post
title: Linux基本目录规范——XDG
date: '2020-03-27 16:34'
tags:
  - XDG
categories:
  - 系统应用
abbrlink: ef694e1f
---

`XDG` Base Directory Specification

>该规范定义了一套指向应用程序的环境变量，这些变量指明的就是这些程序应该存储的基准目录。而变量的具体值取决于用户，若用户未指定，将由程序本身指向一个默认目录，该默认目录也应该遵从标准，而不是用户主目录。

<!--more-->

## 环境变量清单：用户层面变量（User-Level Variables）

### `$XDG_DATA_HOME`

`$XDG_DATA_HOME` 定义了应存储用户特定的数据文件的基准目录。默认值是 `$HOME/.local/share`。

使用场景：

- 用户下载的插件；
- 程序产生的数据库；
- 用户输入历史、书签、邮件等。

### `$XDG_CONFIG_HOME`

`$XDG_CONFIG_HOME` 定义了应存储用户特定的配置文件的基准目录。默认值是 `$HOME/.config`。

使用场景：

- 用户配置。

> 一般来说，这个地方可以在程序初始化的时候存储一个默认的配置文件供加载和修改。

### `$XDG_CACHE_HOME`

`$XDG_CACHE_HOME` 定义了应存储用户特定的非重要性数据文件的基准目录。默认值是 `$HOME/.cache`。

使用场景：

- 缓存的缩略图、歌曲文件、视频文件等。

> 程序应该做到哪怕这个目录被用户删了也能正常运行。

### `$XDG_RUNTIME_DIR`

`$XDG_RUNTIME_DIR` 定义了应存储用户特定的非重要性运行时文件和一些其他文件对象。

使用场景：

- 套接字 (socket)、命名管道 (named pipes) 等。

> 该目录必须由用户拥有，并且该用户必须是唯一具有读写访问权限的。 目录的 Unix 访问模式必须是 `0700`。

## 环境变量清单：系统层面变量（System-Level Variables）

### `$XDG_CONFIG_DIRS`

`$XDG_CONFIG_DIRS` 定义了一套按照偏好顺序的基准目录集，用来搜索除了 `$XDG_CONFIG_HOME` 目录之外的配置文件。该目录中的文件夹应该用冒号（`:`）隔开。默认值是 `/etc/xdg`。

使用场景：

- 可以被用户特定的配置文件所覆盖的系统层面的配置文件。

> 一般来说，应用程序安装的时候可以加载配置文件到这个目录。

### `$XDG_DATA_DIRS`

`$XDG_DATA_DIRS` 定义了一套按照偏好顺序的基准目录集，用来搜索除了 `$XDG_DATA_HOME` 目录之外的数据文件。该目录中的文件夹应该用冒号（`:`）隔开。默认值是 `/usr/local/share/:/usr/share/`。

使用场景：

- 可以被所有用户使用的插件或者主题。

> 一般来说，应用程序安装的时候可以加载插件、主题等文件到这个目录。


## 参考

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [消灭泛滥的点文件：XDG 基准目录规范](https://songkeys.github.io/posts/xdc-spec/)
