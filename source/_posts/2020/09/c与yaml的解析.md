---
layout: post
title: C与YAML的解析
date: '2020-09-13 22:49'
tags:
  - YAML
  - 配置文件
categories:
  - 工具
abbrlink: 865ecfcc
---

`YAML`是"YAML Ain't a Markup Language"（YAML不是一种标记语言）的递归缩写。在开发的这种语言时，YAML 的意思其实是："Yet Another Markup Language"（仍是一种标记语言），但为了强调这种语言以数据做为中心，而不是以标记语言为重点，而用反向缩略语重命名。

YAML 的语法和其他高级语言类似，并且可以简单表达清单、散列表，标量等数据形态

适用场景:
- 脚本语言
- 序列化
- 配置文件

<!--more-->

C语言解析库:https://pyyaml.org/wiki/LibYAML

``` shell
git clone https://github.com/yaml/libyaml
```

## 安装依赖库

- ubuntu
``` shell
sudo apt install libyaml-dev
```


## 示例

### 配置文件

```
# config/public.yaml

title   : Finex 2011
img_url : /finex/html/img/
css_url : /finex/html/style/
js_url  : /finex/html/js/

template_dir: html/templ/

default_act : idx    # used for invalid/missing act=

pages:
  - act   : idx
    title : Welcome
    html  : public/welcome.phtml
  - act   : reg
    title : Register
    html  : public/register.phtml
  - act   : log
    title : Log in
    html  : public/login.phtml
  - act   : out
    title : Log out
    html  : public/logout.phtml
```


### 解析代码

``` C
#include <stdio.h>
#include <yaml.h>

int main(void)
{
    FILE *fh = fopen("public.yaml", "r");
    yaml_parser_t parser;
    yaml_token_t  token;   /* new variable */

    /* Initialize parser */
    if(!yaml_parser_initialize(&parser))
        fputs("Failed to initialize parser!\n", stderr);
    if(fh == NULL)
        fputs("Failed to open file!\n", stderr);

    /* Set input file */
    yaml_parser_set_input_file(&parser, fh);

    /* BEGIN new code */
    do {
        yaml_parser_scan(&parser, &token);
        switch(token.type){
        /* Stream start/end */
        case YAML_STREAM_START_TOKEN:
            puts("STREAM START"); break;
        case YAML_STREAM_END_TOKEN:
            puts("STREAM END");   break;
        /* Token types (read before actual token) */
        case YAML_KEY_TOKEN:
            printf("(Key token)   "); break;
        case YAML_VALUE_TOKEN:
            printf("(Value token) "); break;
        /* Block delimeters */
        case YAML_BLOCK_SEQUENCE_START_TOKEN:
            puts("<b>Start Block (Sequence)</b>"); break;
        case YAML_BLOCK_ENTRY_TOKEN:
            puts("<b>Start Block (Entry)</b>");    break;
        case YAML_BLOCK_END_TOKEN:
            puts("<b>End block</b>");              break;
        /* Data */
        case YAML_BLOCK_MAPPING_START_TOKEN:
            puts("[Block mapping]"); break;
        case YAML_SCALAR_TOKEN:
            printf("scalar %s \n", token.data.scalar.value); break;
        /* Others */
        default:
            printf("Got token of type %d\n", token.type);
        }
        if(token.type != YAML_STREAM_END_TOKEN)
            yaml_token_delete(&token);
    } while(token.type != YAML_STREAM_END_TOKEN);
    yaml_token_delete(&token);
    /* END new code */

    /* Cleanup */
    yaml_parser_delete(&parser);
    fclose(fh);
    return 0;
}
```

### 解析结果

```
$./a.out
STREAM START
[Block mapping]
(Key token)   scalar title
(Value token) scalar Finex 2011
(Key token)   scalar img_url
(Value token) scalar /finex/html/img/
(Key token)   scalar css_url
(Value token) scalar /finex/html/style/
(Key token)   scalar js_url
(Value token) scalar /finex/html/js/
(Key token)   scalar template_dir
(Value token) scalar html/templ/
(Key token)   scalar default_act
(Value token) scalar idx
(Key token)   scalar pages
(Value token) <b>Start Block (Sequence)</b>
<b>Start Block (Entry)</b>
[Block mapping]
(Key token)   scalar act
(Value token) scalar idx
(Key token)   scalar title
(Value token) scalar Welcome
(Key token)   scalar html
(Value token) scalar public/welcome.phtml
<b>End block</b>
<b>Start Block (Entry)</b>
[Block mapping]
(Key token)   scalar act
(Value token) scalar reg
(Key token)   scalar title
(Value token) scalar Register
(Key token)   scalar html
(Value token) scalar public/register.phtml
<b>End block</b>
<b>Start Block (Entry)</b>
[Block mapping]
(Key token)   scalar act
(Value token) scalar log
(Key token)   scalar title
(Value token) scalar Log in
(Key token)   scalar html
(Value token) scalar public/login.phtml
<b>End block</b>
<b>Start Block (Entry)</b>
[Block mapping]
(Key token)   scalar act
(Value token) scalar out
(Key token)   scalar title
(Value token) scalar Log out
(Key token)   scalar html
(Value token) scalar public/logout.phtml
<b>End block</b>
<b>End block</b>
<b>End block</b>
STREAM END
```


## 参考

- [YAML C语言范例](https://blog.csdn.net/vc66vcc/article/details/79497466)
