---
layout: post
title: meson构建系统
date: '2019-10-25 22:33'
tags:
  - meson
  - build
categories:
  - 编译工具
abbrlink: 28042
---

转载：https://stackoverflow.com/questions/5837764/autotools-vs-cmake-for-both-windows-and-linux-compilation

<!--more-->

**Meson**

Pros:

- The DSL does not get in the way at all. In fact, it is very nice and familiar, based in python.
- Well-thought cross compilation support.
- The objects are all strongly typed: you cannot make string  substitution mistakes easily, since objects are entities such as  'depencency', 'include directory', etc.
- It is very obviuos how to add a module for one of your tools.
- Cross-compilation seems more straightforward to use.
- Really well-thought. The designer and main writer of Meson knows what  he talks about very well when designing a build system.
- Very, very fast, especially in incremental builds.
- The documentation is 10 times better that what you can find in cmake. Go visit <http://mesonbuild.com> and you will find tutorial, howtos and a good reference. It is not perfect but it is really discoverable.

Cons:

- Not as mature as CMake, though, I consider it already fully usable for C++.
- Not so many modules available, though, gnome, qt and the common ones are already there.
- Project generators: seems VS generator is not working that well as of now. CMake project generators are far more mature.
- Has a python3 + ninja dependency.

**Cmake**

Pros:

- Generates projects for many different IDEs. This is a *very* nice feature for teams.
- Plays well with windows tools, unlike autotools.
- Mature, almost de-facto standard.
- Microsoft is working on CMake integration for Visual Studio.

Cons:

- It does not follow any well known standard or guidelines.
- No uninstall target.
- The DSL is weird, when you start to do comparisons and such, and the  strings vs list thing or escape chars, you will make many mistakes, I  am pretty sure.
- Cross compilation sucks.

**Autotools**

Pros:

- Most powerful system for cross-compilation, IMHO.
- The generated scripts don't need anything else than make, a shell and, if you need it to build, a compiler.
- The command-line is really nice and consistent.
- A standard in unix world, lots of docs.
- Really powerful command-line: changing directories of installation, uninstall, renaming binaries...
- If you target unix, packaging sources with this tool is really convenient.

Cons:

- It won't play well with microsoft tools. A real showstopper.
- The learning curve is... well... But actually I can say that CMake was not that easy either.
- The use of recursive make is pervasive in legacy projects. Automake [supports non-recursive builds](https://autotools.io/automake/nonrecursive.html), but it's not a very widely used approach.

About the learning curve, there are two very good sources to learn from:

- The website [here](https://www.flameeyes.eu/autotools-mythbuster/)
- The book [here](http://www.nostarch.com/autotools.htm)

The first source will get you up and running faster. The book is a more in-depth discussion.

From Scons, waf and tup, Scons and tup are more like make. Waf is  more like CMake and the autotools. I tried waf instead of cmake at  first. I think it is overengineered in the sense that it has a full OOP  API. The scripts didn't look short at all and it was really confusing  for me the working directory stuff and related things. At the end, I  found that autotools and CMake are a better choice. My favourite from  these 3 build systems is tup.

**Tup**

Pros

- Really correct.
- **Insanely fast**. You should try it to believe it.
- The scripting language relies on a very easy idea that can be understood in 10 minutes.

Cons

- It does not have a full-featured config framework.
- I couldn't find the way to make targets such as `doc`,  since  they generate files I don't know of and they must be listed in the  output before being generated, or at least, that's my conclusion for  now. This was a really annoying limitation, if it is, since I am not  sure.

All in all, the only things I am considering right now for new  projects is are Cmake and Meson. When I have a chance I will try tup  also, but it lacks the config framework, which means that it makes  things more complex when you need all of that stuff. On the other hand,  it is really fast.

## 参考

- [Comparing Meson with other build systems](https://mesonbuild.com/Comparisons.html)
- [A simple comparison for meson](https://mesonbuild.com/Simple-comparison.html)
