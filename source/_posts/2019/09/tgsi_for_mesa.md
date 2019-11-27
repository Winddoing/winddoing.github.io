---
layout: post
title: TGSI for Mesa
date: '2019-09-26 22:39'
tags:
  - mesa
categories:
  - 多媒体
  - mesa
abbrlink: 58638
---

>`TGSI`	Tungsten Graphics Shader Infrastructure

<!--more-->

>In a Gallium driver, these are first transformed into TGSI by the state tracker and are then transformed into something that will run on the card by the driver.[^link]

[^link]:http://www.informit.com/articles/article.aspx?p=1554200&seqNum=5

> TGSI, Tungsten Graphics Shader Infrastructure, is an intermediate language for describing shaders. Since Gallium is inherently shaderful, shaders are an important part of the API. TGSI is the only intermediate representation used by all drivers.

![shader_IRs_2015](/images/2019/09/shader_irs_2015.png)
![new_shader_ir](/images/2019/09/new_shader_ir.png)

TGSI是Gallium框架中的所有驱动程序使用着色器的唯一中间表示形式,这里`特指`的是`着色器`的中间形式，着色器对驱动而言的所有格式将是TGSI。

## TGSI中间语言

介于在着色器（GLSL）代码与GPU指令之间的一种中间语言，类似与C语言与CPU指令之间存在的汇编语言一样。

在Mesa上，GLSL首先被编译器翻译成tgsi中间语言，然后显卡特定的驱动将这些tgsi语言的代码编译成GPU指令。

![shader_gtsi](/images/2019/09/shader_tgsi.png)

```
glxgears: shader
FRAG
PROPERTY FS_COLOR0_WRITES_ALL_CBUFS 1
DCL IN[0], COLOR, COLOR
DCL OUT[0], COLOR
  0: MOV OUT[0], IN[0]
  1: END

glxgears: shader
VERT
DCL IN[0]
DCL OUT[0], POSITION
DCL OUT[1], COLOR
DCL CONST[0..10]
DCL TEMP[0..3]
IMM[0] FLT32 {0x00000000, 0x3f800000, 0x00000000, 0x00000000}
  0: MUL TEMP[0], IN[0].xxxx, CONST[0]
  1: MAD TEMP[0], IN[0].yyyy, CONST[1], TEMP[0]
  2: MAD TEMP[0], IN[0].zzzz, CONST[2], TEMP[0]
  3: MAD OUT[0], IN[0].wwww, CONST[3], TEMP[0]
  4: DP3 TEMP[1].x, CONST[4], CONST[4]
  5: RSQ TEMP[1].x, |TEMP[1]|
  6: MUL TEMP[0], CONST[4], TEMP[1].xxxx
  7: MOV TEMP[2], CONST[5]
  8: MOV_SAT OUT[1], TEMP[2]
  9: DP3 TEMP[3], TEMP[0], CONST[6]
 10: MAX TEMP[1], IMM[0].xxxy, TEMP[3]
 11: SLT TEMP[1].z, IMM[0].xxxx, TEMP[3]
 12: ADD TEMP[2], CONST[8], TEMP[2]
 13: MAD TEMP[2], TEMP[1].yyyy, CONST[9], TEMP[2]
 14: MAD_SAT OUT[1].xyz, TEMP[1].zzzz, CONST[10], TEMP[2]
 15: END
```
> glxgears在渲染中生成的部分TGSI代码
> - [TGSI specification](https://freedesktop.org/wiki/Software/gallium/tgsi-specification.pdf)
> - [TGSI Instruction Set](https://gallium.readthedocs.io/en/latest/tgsi.html#instruction-set)

## 着色器的编译链接

![glsl_build_link](/images/2019/11/glsl_build_link.png)

>GLSL中则通过两种对象——`着色器对象`和`着色器程序对象`——来分别处理编译过程和连接过程

```
call glShaderSource(shader=58, count=3, )
string[0]={#version 140
#extension GL_ARB_shader_bit_encoding : require
}
string[1]={in vec4 in_0;
in vec4 in_1;

  smooth                     out  vec4 vso_g0A0_f;
uniform float winsys_adjust_y;
vec4 temp0[1];
uniform uvec4 vsconst0[8];
}
string[2]={void main(void)
{
temp0[0] = vec4((((in_0.xxxx) * uintBitsToFloat(vsconst0[0]))));
temp0[0] = vec4(((in_0.yyyy) * uintBitsToFloat(vsconst0[1]) +  temp0[0] ));
temp0[0] = vec4(((in_0.zzzz) * uintBitsToFloat(vsconst0[2]) +  temp0[0] ));
gl_Position = vec4(((in_0.wwww) * uintBitsToFloat(vsconst0[3]) +  temp0[0] ));
temp0[0] = vec4((((in_1.xxxx) * uintBitsToFloat(vsconst0[4]))));
temp0[0] = vec4(((in_1.yyyy) * uintBitsToFloat(vsconst0[5]) +  temp0[0] ));
temp0[0] = vec4(((in_1.zzzz) * uintBitsToFloat(vsconst0[6]) +  temp0[0] ));
vso_g0A0_f = vec4(((in_1.wwww) * uintBitsToFloat(vsconst0[7]) +  temp0[0] ));
gl_Position.y = gl_Position.y * winsys_adjust_y;
}
}
call glCompileShader(58)
call glGetShaderiv(shader=58, pname=0x8b81, params=1)
call glCreateProgram(): 60
call glAttachShader(program=60, shader=58)
call glAttachShader(program=60, shader=59)
call glBindAttribLocation(60, 0, in_0)
call glBindAttribLocation(60, 1, in_1)
call glLinkProgram(program=60)
call glGetProgramiv(60, 0x8b82, 833648032)
call glGetUniformLocation(program=60, name=winsys_adjust_y): val=0
call glUseProgram(60)
```

- `glShaderSource`: 替换着色器对象中的源代码
- `glCompileShader`: 编译一个着色器对象
- `glGetShaderiv`: 从着色器对象返回一个参数
- `glCreateProgram`: 创建一个空program对象并返回一个可以被引用的非零值（program ID）
- `glUseProgram`: 安装program对象作为当前渲染状态的一部分

![shader_create_flowchart](/images/2019/11/shader_create_flowchart.png)

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
## virgl中着色器的转换

amdgpu使用开源驱动

![virgl_shader_switch](/images/2019/11/virgl_shader_switch.png)

>Then, 3D commands. These are close to what we can find in a API like Vulkan. We can setup a viewport, scissor state, create a VBO, and draw it. Shaders are also supported, but we first need to translate them to TGSI; an assembly-like representation. Once on the host, they will be re-translated to GLSL and sent to OpenGL.
>https://studiopixl.com/2017-08-27/3d-acceleration-using-virtio.html

```
glxgears: shader
FRAG
PROPERTY FS_COLOR0_WRITES_ALL_CBUFS 1
DCL IN[0], COLOR, COLOR
DCL OUT[0], COLOR
  0: MOV OUT[0], IN[0]
  1: END

glxgears: GLSL:glxgears: #version 140

   in  vec4 ex_c0;
out vec4 fsout_c0;
out vec4 fsout_c1;
out vec4 fsout_c2;
out vec4 fsout_c3;
out vec4 fsout_c4;
out vec4 fsout_c5;
out vec4 fsout_c6;
out vec4 fsout_c7;
void main(void)
{
fsout_c0 = vec4(((ex_c0)));
fsout_c1 = fsout_c0;
fsout_c2 = fsout_c0;
fsout_c3 = fsout_c0;
fsout_c4 = fsout_c0;
fsout_c5 = fsout_c0;
fsout_c6 = fsout_c0;
fsout_c7 = fsout_c0;
}
glxgears:
```
>TGSI转换成GLSL


## 参考

- [TGSI](https://gallium.readthedocs.io/en/latest/tgsi.html)
- [gallium3d-xds2007](https://freedesktop.org/wiki/Software/gallium/gallium3d-xds2007.pdf)
- [A beginners guide to TGSI](http://ndesh26.github.io/programming/2016/07/04/A-Beginners-guide-to-TGSI/)
- [The State of Open Source 3D](http://www.informit.com/articles/article.aspx?p=1554200)
- [learnopengl--Shaders](https://learnopengl.com/Getting-started/Shaders)|[【CN】](https://learnopengl-cn.github.io/#)
- [Linux环境下的图形系统和AMD R600显卡编程(11)——R600指令集](https://www.cnblogs.com/shoemaker/p/linux_graphics11.html)
- [GLSL compiler](https://www.x.org/wiki/Events/XDC2015/Program/turner_glsl_compiler.pdf)
- [GSoC 2017 - 3D acceleration using VirtIOGPU](https://studiopixl.com/2017-08-27/3d-acceleration-using-virtio.html)
