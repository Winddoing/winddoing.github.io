---
layout: post
title: TGSI for Mesa
date: '2019-09-26 22:39'
tags:
  - mesa
categories:
  - 多媒体
  - mesa
---

>`TGSI`	Tungsten Graphics Shader Infrastructure

<!--more-->

>In a Gallium driver, these are first transformed into TGSI by the state tracker and are then transformed into something that will run on the card by the driver.[^link]

[^link]:http://www.informit.com/articles/article.aspx?p=1554200&seqNum=5

> TGSI, Tungsten Graphics Shader Infrastructure, is an intermediate language for describing shaders. Since Gallium is inherently shaderful, shaders are an important part of the API. TGSI is the only intermediate representation used by all drivers.

![shader_IRs_2015](/images/2019/09/shader_irs_2015.png)
![new_shader_ir](/images/2019/09/new_shader_ir.png)

TGSI是所有驱动程序使用的唯一中间表示形式,这里`特指`的是着色器的中间形式，着色器对驱动而言的所有格式将是TGSI。

## TGSI中间语言

介于在着色器（GLSL）代码与GPU指令之间的一种中间语言，类似与C语言与CPU指令之间存在的汇编语言一样。

在Mesa上，GLSL首先被编译器翻译成tgsi中间语言，然后显卡特定的驱动将这些tgsi语言的代码编译成GPU指令。

![shader_gtsi](/images/2019/09/shader_gtsi.png)


## GLSL使用

着色器代码：

``` C
static const char vertex_shader[] =
"attribute vec3 position;\n"
"attribute vec3 normal;\n"
"\n"
"uniform mat4 ModelViewProjectionMatrix;\n"
"uniform mat4 NormalMatrix;\n"
"uniform vec4 LightSourcePosition;\n"
"uniform vec4 MaterialColor;\n"
"\n"
"varying vec4 Color;\n"
"\n"
"void main(void)\n"
"{\n"
"    // Transform the normal to eye coordinates\n"
"    vec3 N = normalize(vec3(NormalMatrix * vec4(normal, 1.0)));\n"
"\n"
"    // The LightSourcePosition is actually its direction for directional light\n"
"    vec3 L = normalize(LightSourcePosition.xyz);\n"
"\n"
"    // Multiply the diffuse value by the vertex color (which is fixed in this case)\n"
"    // to get the actual color that we will use to draw this vertex with\n"
"    float diffuse = max(dot(N, L), 0.0);\n"
"    Color = diffuse * MaterialColor;\n"
"\n"
"    // Transform the position to clip coordinates\n"
"    gl_Position = ModelViewProjectionMatrix * vec4(position, 1.0);\n"
"}";

static const char fragment_shader[] =
"precision mediump float;\n"
"varying vec4 Color;\n"
"\n"
"void main(void)\n"
"{\n"
"    gl_FragColor = Color;\n"
"}";
```

``` C
 /* Compile the vertex shader */
 p = vertex_shader;
 v = glCreateShader(GL_VERTEX_SHADER);
 glShaderSource(v, 1, &p, NULL);
 glCompileShader(v);
 glGetShaderInfoLog(v, sizeof msg, NULL, msg);
 printf("vertex shader info: %s\n", msg);
```

`glCompileShader`主要编译着色器的源代码（即vertex_shader中的GLSL代码）
- 编译后的代码是TGSI中间代码？
- 如果是在哪个阶段进行的转换？
- 在virgl驱动中的着色器代码是否进行了转换？

### glCompileShader

> `glCompileShader` compiles the source code strings that have been stored in the shader object specified by shader.

在mesa中的函数调用流程：
```
_mesa_CompileShader (src/mesa/main/shaderapi.c)
 \->_mesa_compile_shader
     \->ensure_builtin_types
     |->_mesa_glsl_compile_shader
```
>版本：19.3.0-devel 237c7636ca4c429d4dbfce95b6e3281a8309eac7


``` C
/**
 * Shader intermediate representation.
 *
 * Note that if the driver requests something other than TGSI, it must
 * always be prepared to receive TGSI in addition to its preferred IR.
 * If the driver requests TGSI as its preferred IR, it will *always*
 * get TGSI.
 *
 * Note that PIPE_SHADER_IR_TGSI should be zero for backwards compat with
 * state trackers that only understand TGSI.
 */
enum pipe_shader_ir
{
   PIPE_SHADER_IR_TGSI = 0,
   PIPE_SHADER_IR_NATIVE,
   PIPE_SHADER_IR_NIR,
   PIPE_SHADER_IR_NIR_SERIALIZED,
};
```

``` C
/**
 * Plug in the program and shader-related device driver functions.
 */
void
st_init_program_functions(struct dd_function_table *functions)
{
   functions->NewProgram = st_new_program;
   functions->DeleteProgram = st_delete_program;
   functions->ProgramStringNotify = st_program_string_notify;
   functions->NewATIfs = st_new_ati_fs;
   functions->LinkShader = st_link_shader;
   functions->SetMaxShaderCompilerThreads = st_max_shader_compiler_threads;
   functions->GetShaderProgramCompletionStatus =
      st_get_shader_program_completion_status;
}
```
>file:  src/mesa/state_tracker/st_cb_program.c

``` C
/**
 * Link a shader.
 * Called via ctx->Driver.LinkShader()
 * This is a shared function that branches off to either GLSL IR -> TGSI or
 * GLSL IR -> NIR
 */
GLboolean
st_link_shader(struct gl_context *ctx, struct gl_shader_program *prog)
```
>file: src/mesa/state_tracker/st_glsl_to_ir.cpp

``` C
/**
 * Link a shader.
 * This actually involves converting GLSL IR into an intermediate TGSI-like IR
 * with code lowering and other optimizations.
 */
 GLboolean
 st_link_tgsi(struct gl_context *ctx, struct gl_shader_program *prog)
```
>file: src/mesa/state_tracker/st_glsl_to_tgsi.cpp


```
st_link_shader
\/
st_link_tgsi
```

## 参考

- [TGSI](https://gallium.readthedocs.io/en/latest/tgsi.html)
- [A beginners guide to TGSI](http://ndesh26.github.io/programming/2016/07/04/A-Beginners-guide-to-TGSI/)
- [The State of Open Source 3D](http://www.informit.com/articles/article.aspx?p=1554200)
- [learnopengl--Shaders](https://learnopengl.com/Getting-started/Shaders)|[【CN】](https://learnopengl-cn.github.io/#)
- [Linux环境下的图形系统和AMD R600显卡编程(11)——R600指令集](https://www.cnblogs.com/shoemaker/p/linux_graphics11.html)
- [GLSL compiler](https://www.x.org/wiki/Events/XDC2015/Program/turner_glsl_compiler.pdf)
