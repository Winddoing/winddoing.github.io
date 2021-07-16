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

![Mesa_layers_of_crap_2016_for_IR](/images/2020/07/mesa_layers_of_crap_2016_for_ir.svg)
> 来自:[wikipedia mesa](https://en.wikipedia.org/wiki/Mesa_(computer_graphics))

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

- `FRAG`:fragment片元着色器
- `VERT`:vertex顶点着色器
- `DCL`: declaration 申明resources
- `IMM`: immediate 立即数
- `PROPERTY` : property 性质

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

- 在tgsi的传输中为什么不直接使用tgsi token进行传输，而要转换为text的形式传输？？？
  - 地址空间的不同是否相关？
  - tgsi text转换为tgsi token的过程中与当前使用到的纹理数据等其他资源进行关联？

``` C
struct tgsi_instruction
{
   unsigned Type       : 4;  /* TGSI_TOKEN_TYPE_INSTRUCTION */
   unsigned NrTokens   : 8;  /* UINT */
   unsigned Opcode     : 8;  /* TGSI_OPCODE_ */
   unsigned Saturate   : 1;  /* BOOL */
   unsigned NumDstRegs : 2;  /* UINT */
   unsigned NumSrcRegs : 4;  /* UINT */
   unsigned Label      : 1;
   unsigned Texture    : 1;
   unsigned Memory     : 1;
   unsigned Precise    : 1;
   unsigned Padding    : 1;
};
```

``` C
struct tgsi_instruction_texture
{
   unsigned Texture  : 8;    /* TGSI_TEXTURE_ */
   unsigned NumOffsets : 4;
   unsigned ReturnType : 3; /* TGSI_RETURN_TYPE_x */
   unsigned Padding : 17;
};
```

```
/*
 * If tgsi_instruction::Label is TRUE, tgsi_instruction_label follows.
 *
 * If tgsi_instruction::Texture is TRUE, tgsi_instruction_texture follows.
 *   if texture instruction has a number of offsets,
 *   then tgsi_instruction::Texture::NumOffset of tgsi_texture_offset follow.
 *
 * Then, tgsi_instruction::NumDstRegs of tgsi_dst_register follow.
 *
 * Then, tgsi_instruction::NumSrcRegs of tgsi_src_register follow.
 *
 * tgsi_instruction::NrTokens contains the total number of words that make the
 * instruction, including the instruction word.
 */
```
>tgsi_instruction_texture:表明存在指令纹理，其与纹理资源数据之间的关系？


### 示例
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

## amdgpu中着色器的转换

在radeonsi用户空间驱动中tgsi的使用

```
Setup actions for TGSI memory opcode, including texture opcodes.
```
> TGSI与texture之间在渲染时，之间的联系？？

### radeonsi for shader

目前LLVM是amdgpu的后端编译器，在mesa19.3中使用`ACO`（AMD COmpiler）编译着色器代码

```
TGSI->LLVM
```

> It was just two days ago that Valve's performance-focused "ACO" shader compiler was submitted for review to be included in Mesa for the "RADV" Radeon Vulkan driver. Just minutes ago that new shader compiler back-end was merged for Mesa 19.3.
>
>ACO, short for the AMD COmpiler, is the effort led by Valve at creating a more performant and optimized shader compiler for the Radeon Linux graphics driver. Besides trying to generate the fastest shaders, ACO also aims to provide speedy shader compilation too, as an alternative to the AMDGPU LLVM shader compiler back-end. Initially ACO is for the RADV Vulkan driver but it may be brought to the RadeonSI OpenGL driver in the future. At the moment ACO is in good shape for Volcanic Islands through Vega while the Navi shader support is in primitive form.
> - [Valve's ACO Shader Compiler For The Mesa Radeon Vulkan Driver Just Landed](https://www.phoronix.com/scan.php?page=news_item&px=Mesa-19.3-Lands-RADV-ACO)

### ISA Code

Instruction Set Architecture(指令集架构) —— ISA

> The AMDGPU backend provides `ISA code` generation for AMD GPUs, starting with the R600 family up until the current GCN families. It lives in the lib/Target/AMDGPU directory.

> - [User Guide for AMDGPU Backend](https://www.llvm.org/docs/AMDGPUUsage.html#amdgpu-intrinsics)

- [“Vega” Instruction Set Architecture](https://rocm-documentation.readthedocs.io/en/latest/GCN_ISA_Manuals/testdocbook.html#testdocbook)
- [GCN ISA Manuals](https://rocm-documentation.readthedocs.io/en/latest/GCN_ISA_Manuals/GCN-ISA-Manuals.html)


### 着色器形式的转换

```
+-------+     +---------+    +---------+     +------+     +------+    +-------+
|       |     |         |    |         |     |      |     |      |    |       |
| GLSL  +-----> GLSL IR +---->   NIR   +-----> TGSI +-----> LLVM +---->  ISA  |
|       |     |         |    |         |     |      |     |      |    |       |
+--+----+     +---------+    +---------+     +--+---+     +------+    +----+--+
   |                                            |                          |
   |                                            |      radeonsi_dri.so     |
   |                common                      |           amdgpu         |
```

## 示例

### GLSL着色器

- vertex shader

```
//vertex顶点着色器
varying vec3 lightDir, normal;

void main()
{
        lightDir = normalize(vec3(gl_LightSource[0].position));
        normal = normalize(gl_NormalMatrix * gl_Normal);

        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
```

- fragment shader

```
//fragment片元着色器
varying vec3 lightDir, normal;

void main()
{
        float intensity;
        vec3 n;
        vec4 color;

        n = normalize(normal);

        intensity = max(dot(lightDir,n),0.0);
        color = vec4(1.0, 0, 1.0, 1) * intensity;

        gl_FragColor = color;
}
```

### TGSI text

通过mesa编译后生成的TGSI token进行dump出的text

```
VIRGL_DEBUG=tgsi ./a.out
```

- vertex shader

```
TGSI:
---8<---
VERT
DCL IN[0]
DCL IN[1]
DCL OUT[0], POSITION
DCL OUT[1], GENERIC[9]
DCL OUT[2].xy, GENERIC[10]
DCL CONST[0..14]
DCL TEMP[0..2], LOCAL
  0: MUL TEMP[0].xyz, CONST[8].xyzz, IN[1].xxxx
  1: MAD TEMP[0].xyz, CONST[9].xyzz, IN[1].yyyy, TEMP[0].xyzz
  2: MAD TEMP[0].xyz, CONST[10].xyzz, IN[1].zzzz, TEMP[0].xyzz
  3: DP3 TEMP[1].x, TEMP[0].xyzz, TEMP[0].xyzz
  4: RSQ TEMP[1].x, TEMP[1].xxxx
  5: MUL TEMP[0].xyz, TEMP[0].xyzz, TEMP[1].xxxx
  6: MUL TEMP[1], CONST[11], IN[0].xxxx
  7: MAD TEMP[1], CONST[12], IN[0].yyyy, TEMP[1]
  8: MAD TEMP[1], CONST[13], IN[0].zzzz, TEMP[1]
  9: MAD TEMP[1], CONST[14], IN[0].wwww, TEMP[1]
 10: DP3 TEMP[2].x, CONST[3].xyzz, CONST[3].xyzz
 11: RSQ TEMP[2].x, TEMP[2].xxxx
 12: MUL TEMP[2].xyz, CONST[3].xyzz, TEMP[2].xxxx
 13: MOV TEMP[2].w, TEMP[0].xxxx
 14: MOV OUT[2].xy, TEMP[0].yzyy
 15: MOV OUT[0], TEMP[1]
 16: MOV OUT[1], TEMP[2]
 17: END

---8<---
```

- fragment shader

```
TGSI:
---8<---
FRAG
PROPERTY FS_COLOR0_WRITES_ALL_CBUFS 1
DCL IN[0], GENERIC[9], PERSPECTIVE
DCL IN[1].xy, GENERIC[10], PERSPECTIVE
DCL OUT[0], COLOR
DCL TEMP[0..1], LOCAL
IMM[0] FLT32 {0x3f800000, 0x00000000, 0x00000000, 0x00000000}
  0: MOV TEMP[0].x, IN[0].wwww
  1: MOV TEMP[0].yz, IN[1].yxyy
  2: DP3 TEMP[1].x, TEMP[0].xyzz, TEMP[0].xyzz
  3: RSQ TEMP[1].x, TEMP[1].xxxx
  4: MUL TEMP[0].xyz, TEMP[0].xyzz, TEMP[1].xxxx
  5: DP3 TEMP[0].x, IN[0].xyzz, TEMP[0].xyzz
  6: MAX TEMP[0].x, TEMP[0].xxxx, IMM[0].yyyy
  7: MUL TEMP[0], IMM[0].xyxx, TEMP[0].xxxx
  8: MOV OUT[0], TEMP[0]
  9: END

---8<---
```

### TGSI转换GLSL

```
VREND_DEBUG=shader virgl_test_server
```

- vertex shader

```
a.out: shader
VERT
DCL IN[0]
DCL IN[1]
DCL OUT[0], POSITION
DCL OUT[1], GENERIC[9]
DCL OUT[2].xy, GENERIC[10]
DCL CONST[0..14]
DCL TEMP[0..2], LOCAL
  0: MUL TEMP[0].xyz, CONST[8].xyzz, IN[1].xxxx
  1: MAD TEMP[0].xyz, CONST[9].xyzz, IN[1].yyyy, TEMP[0].xyzz
  2: MAD TEMP[0].xyz, CONST[10].xyzz, IN[1].zzzz, TEMP[0].xyzz
  3: DP3 TEMP[1].x, TEMP[0].xyzz, TEMP[0].xyzz
  4: RSQ TEMP[1].x, TEMP[1].xxxx
  5: MUL TEMP[0].xyz, TEMP[0].xyzz, TEMP[1].xxxx
  6: MUL TEMP[1], CONST[11], IN[0].xxxx
  7: MAD TEMP[1], CONST[12], IN[0].yyyy, TEMP[1]
  8: MAD TEMP[1], CONST[13], IN[0].zzzz, TEMP[1]
  9: MAD TEMP[1], CONST[14], IN[0].wwww, TEMP[1]
 10: DP3 TEMP[2].x, CONST[3].xyzz, CONST[3].xyzz
 11: RSQ TEMP[2].x, TEMP[2].xxxx
 12: MUL TEMP[2].xyz, CONST[3].xyzz, TEMP[2].xxxx
 13: MOV TEMP[2].w, TEMP[0].xxxx
 14: MOV OUT[2].xy, TEMP[0].yzyy
 15: MOV OUT[0], TEMP[1]
 16: MOV OUT[1], TEMP[2]
 17: END

a.out: GLSL:a.out: #version 140
#extension GL_ARB_shader_bit_encoding : require
in vec4 in_0;
in vec4 in_1;

                             out  vec4 vso_g9A0_f;

                             out  vec4 vso_g10A0_f;
uniform float winsys_adjust_y;
vec4 temp0[3];
uniform uvec4 vsconst0[15];
void main(void)
{
temp0[0].xyz = vec3(((uintBitsToFloat(vsconst0[8].xyzz) * (in_1.xxxx))).xyz);
temp0[0].xyz = vec3((uintBitsToFloat(vsconst0[9].xyzz) * (in_1.yyyy) +  temp0[0].xyzz ).xyz);
temp0[0].xyz = vec3((uintBitsToFloat(vsconst0[10].xyzz) * (in_1.zzzz) +  temp0[0].xyzz ).xyz);
temp0[1].x = float(dot(vec3( temp0[0].xyzz ), vec3( temp0[0].xyzz )));
temp0[1].x = float(inversesqrt( temp0[1].xxxx .x));
temp0[0].xyz = vec3((( temp0[0].xyzz  *  temp0[1].xxxx )).xyz);
temp0[1] = vec4(((uintBitsToFloat(vsconst0[11]) * (in_0.xxxx))));
temp0[1] = vec4((uintBitsToFloat(vsconst0[12]) * (in_0.yyyy) +  temp0[1] ));
temp0[1] = vec4((uintBitsToFloat(vsconst0[13]) * (in_0.zzzz) +  temp0[1] ));
temp0[1] = vec4((uintBitsToFloat(vsconst0[14]) * (in_0.wwww) +  temp0[1] ));
temp0[2].x = float(dot(vec3(uintBitsToFloat(vsconst0[3].xyzz)), vec3(uintBitsToFloat(vsconst0[3].xyzz))));
temp0[2].x = float(inversesqrt( temp0[2].xxxx .x));
temp0[2].xyz = vec3(((uintBitsToFloat(vsconst0[3].xyzz) *  temp0[2].xxxx )).xyz);
temp0[2].w = float(( temp0[0].xxxx .w));
vso_g10A0_f.xy = vec2(( temp0[0].yzyy .xy));
gl_Position = vec4(( temp0[1] ));
vso_g9A0_f = vec4(( temp0[2] ));
gl_Position.y = gl_Position.y * winsys_adjust_y;
}
a.out:
a.out: GLSL:a.out: #version 140

smooth    in  vec4 vso_g9A0_f;

smooth    in  vec4 vso_g10A0_f;
out vec4 fsout_c0;
out vec4 fsout_c1;
out vec4 fsout_c2;
out vec4 fsout_c3;
out vec4 fsout_c4;
out vec4 fsout_c5;
out vec4 fsout_c6;
out vec4 fsout_c7;
vec4 temp0[2];
void main(void)
{
temp0[0].x = float(((vso_g9A0_f.wwww).x));
temp0[0].yz = vec2(((vso_g10A0_f.yxyy).yz));
temp0[1].x = float(dot(vec3( temp0[0].xyzz ), vec3( temp0[0].xyzz )));
temp0[1].x = float(inversesqrt( temp0[1].xxxx .x));
temp0[0].xyz = vec3((( temp0[0].xyzz  *  temp0[1].xxxx )).xyz);
temp0[0].x = float(dot(vec3((vso_g9A0_f.xyzz)), vec3( temp0[0].xyzz )));
temp0[0].x = float((max( temp0[0].xxxx , (vec4(0,0,0,0)))).x);
temp0[0] = vec4((((vec4(1,0,1,1)) *  temp0[0].xxxx )));
fsout_c0 = vec4(( temp0[0] ));
fsout_c1 = fsout_c0;
fsout_c2 = fsout_c0;
fsout_c3 = fsout_c0;
fsout_c4 = fsout_c0;
fsout_c5 = fsout_c0;
fsout_c6 = fsout_c0;
fsout_c7 = fsout_c0;
}
a.out:
a.out: GLSL:a.out: #version 140
#extension GL_ARB_shader_bit_encoding : require
in vec4 in_0;
in vec4 in_1;

  smooth                     out  vec4 vso_g9A0_f;

  smooth                     out  vec4 vso_g10A0_f;
uniform float winsys_adjust_y;
vec4 temp0[3];
uniform uvec4 vsconst0[15];
void main(void)
{
temp0[0].xyz = vec3(((uintBitsToFloat(vsconst0[8].xyzz) * (in_1.xxxx))).xyz);
temp0[0].xyz = vec3((uintBitsToFloat(vsconst0[9].xyzz) * (in_1.yyyy) +  temp0[0].xyzz ).xyz);
temp0[0].xyz = vec3((uintBitsToFloat(vsconst0[10].xyzz) * (in_1.zzzz) +  temp0[0].xyzz ).xyz);
temp0[1].x = float(dot(vec3( temp0[0].xyzz ), vec3( temp0[0].xyzz )));
temp0[1].x = float(inversesqrt( temp0[1].xxxx .x));
temp0[0].xyz = vec3((( temp0[0].xyzz  *  temp0[1].xxxx )).xyz);
temp0[1] = vec4(((uintBitsToFloat(vsconst0[11]) * (in_0.xxxx))));
temp0[1] = vec4((uintBitsToFloat(vsconst0[12]) * (in_0.yyyy) +  temp0[1] ));
temp0[1] = vec4((uintBitsToFloat(vsconst0[13]) * (in_0.zzzz) +  temp0[1] ));
temp0[1] = vec4((uintBitsToFloat(vsconst0[14]) * (in_0.wwww) +  temp0[1] ));
temp0[2].x = float(dot(vec3(uintBitsToFloat(vsconst0[3].xyzz)), vec3(uintBitsToFloat(vsconst0[3].xyzz))));
temp0[2].x = float(inversesqrt( temp0[2].xxxx .x));
temp0[2].xyz = vec3(((uintBitsToFloat(vsconst0[3].xyzz) *  temp0[2].xxxx )).xyz);
temp0[2].w = float(( temp0[0].xxxx .w));
vso_g10A0_f.xy = vec2(( temp0[0].yzyy .xy));
gl_Position = vec4(( temp0[1] ));
vso_g9A0_f = vec4(( temp0[2] ));
gl_Position.y = gl_Position.y * winsys_adjust_y;
}
a.out:
```

- fragment shader

```
a.out: shader
FRAG
PROPERTY FS_COLOR0_WRITES_ALL_CBUFS 1
DCL IN[0], GENERIC[9], PERSPECTIVE
DCL IN[1].xy, GENERIC[10], PERSPECTIVE
DCL OUT[0], COLOR
DCL TEMP[0..1], LOCAL
IMM[0] FLT32 {0x3f800000, 0x00000000, 0x00000000, 0x00000000}
  0: MOV TEMP[0].x, IN[0].wwww
  1: MOV TEMP[0].yz, IN[1].yxyy
  2: DP3 TEMP[1].x, TEMP[0].xyzz, TEMP[0].xyzz
  3: RSQ TEMP[1].x, TEMP[1].xxxx
  4: MUL TEMP[0].xyz, TEMP[0].xyzz, TEMP[1].xxxx
  5: DP3 TEMP[0].x, IN[0].xyzz, TEMP[0].xyzz
  6: MAX TEMP[0].x, TEMP[0].xxxx, IMM[0].yyyy
  7: MUL TEMP[0], IMM[0].xyxx, TEMP[0].xxxx
  8: MOV OUT[0], TEMP[0]
  9: END

a.out: GLSL:a.out: #version 140

smooth    in  vec4 vso_g9A0_f;

smooth    in  vec4 vso_g10A0_f;
out vec4 fsout_c0;
out vec4 fsout_c1;
out vec4 fsout_c2;
out vec4 fsout_c3;
out vec4 fsout_c4;
out vec4 fsout_c5;
out vec4 fsout_c6;
out vec4 fsout_c7;
vec4 temp0[2];
void main(void)
{
temp0[0].x = float(((vso_g9A0_f.wwww).x));
temp0[0].yz = vec2(((vso_g10A0_f.yxyy).yz));
temp0[1].x = float(dot(vec3( temp0[0].xyzz ), vec3( temp0[0].xyzz )));
temp0[1].x = float(inversesqrt( temp0[1].xxxx .x));
temp0[0].xyz = vec3((( temp0[0].xyzz  *  temp0[1].xxxx )).xyz);
temp0[0].x = float(dot(vec3((vso_g9A0_f.xyzz)), vec3( temp0[0].xyzz )));
temp0[0].x = float((max( temp0[0].xxxx , (vec4(0,0,0,0)))).x);
temp0[0] = vec4((((vec4(1,0,1,1)) *  temp0[0].xxxx )));
fsout_c0 = vec4(( temp0[0] ));
fsout_c1 = fsout_c0;
fsout_c2 = fsout_c0;
fsout_c3 = fsout_c0;
fsout_c4 = fsout_c0;
fsout_c5 = fsout_c0;
fsout_c6 = fsout_c0;
fsout_c7 = fsout_c0;
}
```

### 其他

- 打印着色器程序相关的所有参数和字段
```
ST_DEBUG=mesa ./a.out
```
```
/**
 * Print all of a program's parameters/fields to stderr.
 */
void
_mesa_print_program_parameters(struct gl_context *ctx, const struct gl_program *prog)
{
   _mesa_fprint_program_parameters(stderr, ctx, prog);
}
```
> file: mesa/program/prog_print.c


## 参考

- [TGSI](https://gallium.readthedocs.io/en/latest/tgsi.html)
- [gallium3d-xds2007](https://freedesktop.org/wiki/Software/gallium/gallium3d-xds2007.pdf)
- [A beginners guide to TGSI](http://ndesh26.github.io/programming/2016/07/04/A-Beginners-guide-to-TGSI/)
- [The State of Open Source 3D](http://www.informit.com/articles/article.aspx?p=1554200)
- [learnopengl--Shaders](https://learnopengl.com/Getting-started/Shaders)|[【CN】](https://learnopengl-cn.github.io/#)
- [Linux环境下的图形系统和AMD R600显卡编程(11)——R600指令集](https://www.cnblogs.com/shoemaker/p/linux_graphics11.html)
- [GLSL compiler](https://www.x.org/wiki/Events/XDC2015/Program/turner_glsl_compiler.pdf)
- [GSoC 2017 - 3D acceleration using VirtIOGPU](https://studiopixl.com/2017-08-27/3d-acceleration-using-virtio.html)
- [The Linux Graphics Stack](https://blog.mecheye.net/2012/06/the-linux-graphics-stack/#rendering-stack)
- [Testing Out Mesa's GLSL-To-TGSI Translator](https://www.phoronix.com/scan.php?page=article&item=glsl_to_tgsi&num=1)
- [Introduction to GPU Programming with GLSL](https://www.researchgate.net/publication/232626644_Introduction_to_GPU_Programming_with_GLSL)
- [A beginners guide to TGSI](https://ndesh26.github.io/programming/2016/07/04/A-Beginners-guide-to-TGSI/)
- [Implementing Bicubic Scaling in TGSI](https://ndesh26.github.io/programming/2016/09/26/Implementing-Bicubic-Scaling-in-TGSI/)
