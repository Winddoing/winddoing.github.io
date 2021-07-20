---
layout: post
title: '[转]An introduction to Mesa’s GLSL compiler (I)[翻译]'
date: '2021-07-20 19:26'
tags:
  - mesa
  - glsl
  - opengl
categories:
  - 多媒体
---

原文：https://blogs.igalia.com/itoral/2015/03/03/an-introduction-to-mesas-glsl-compiler-i/

<!--more-->

## 回顾

在我的上一篇文章中，我解释了现代 3D 管道是可编程的，以及这如何影响图形驱动程序。在接下来的文章中，我们将通过查看 Mesa GLSL 编译器的不同部分来更深入地研究这个方面。具体来说，这篇文章将涵盖 GLSL 解析器、Mesa IR 以及内置变量和函数。

## GLSL解析器

解析器的工作是处理通过glShaderSource提供的shader源代码字符串，并将其转换为存储在RAM中的合适的二进制表示，并可以在后期由编译器的其他部分有效处理。

解析器由一组Lex/Yacc规则组成，用于处理传入的shader source。词法分析器 ( glsl_parser.ll ) 负责对源代码进行标记，解析器 ( glsl_parser.yy ) 为词法分析器阶段识别的标记流添加含义。

类似地，就像在C或c++中一样，GLSL包含了一个预处理程序，在主解析器启动之前，它将遍历着色器源代码。Mesa的GLSL预处理程序的实现存在于src/glsl/glcpp中，也基于Lex/Yacc规则。

解析器的输出是一个驻留在RAM内存中的抽象语法树 (AST)，它是着色器源代码的二进制表示。生成这棵树的节点在src/glsl/ast.h中定义。

对于熟悉所有Lex/Yacc内容的人来说，Mesa 中的解析器实现应该足够熟悉了。

下一步是将AST转换为更适合驱动程序处理的那种操作,这种新的表示，称为IR（中间表示），在 Mesa 中通常被称为Mesa IR、GLSL IR或简称HIR。

在AST到Mesa IR转化是通过在代码src/glsl/ast_to_hir.cpp。

## Mesa IR

Mesa IR是在编译器中使用的主要数据结构。编译器所做的大部分工作可以总结为：

- IR 中的优化
- 修改 IR 以更好地/更容易地与GPU硬件集成
- 将多个着色器（多个 IR 实例）链接到一个程序中。
- 从 IR 为目标 GPU 生成本机汇编代码

正如我们所见，Mesa IR 是编译器必须完成的所有工作的核心，因此了解它是如何设置的对于在 Mesa 的这一部分工作是必要的。

Mesa IR 树中的节点在src/glsl/ir.h中定义。让我们来看看最重要的：

在 IR 节点的类层次结构的顶部，我们有exec_node，这是 Mesa 将独立指令链接到列表中以制作程序的方式。这意味着每条指令都有上一个和下一个指针，分别指向它之前和之后的指令。所以，我们有ir_instruction，树中所有节点的基类，继承自exec_node。

另一个重要节点是ir_rvalue，它是用于表示表达式的基类。通常，任何可以放在赋值右侧的东西都是ir_rvalue。ir_rvalue 的子类包括ir_expression，用于表示各种一元、二元或三元运算（支持的运算符在ir_expression_operation枚举中定义），ir_texture，用于表示纹理查找等纹理操作，ir_swizzle，用于swizzling向量中的值，所有ir_dereference 节点，用于访问存储在变量、数组、结构等中的值和ir_constant, 用于表示所有基本类型（bool、float、integer 等）的常量。

我们还有ir_variable，它代表着色器代码中的变量。请注意，ir_variable的定义非常大……事实上，在大型游戏/应用程序中编译着色器时，这是对编译器内存占用影响最大的节点。另请注意，IR 区分变量和变量取消引用（查看变量值的事实），它们表示为ir_rvalue。

同样，IR 也为其他语言结构定义了节点，如ir_loop、ir_if、ir_assignment等。

调试 IR 并不容易，因为在 IR 节点中表示着色器程序可能非常复杂，无法使用调试器进行遍历和检查。为了帮助解决这个问题，Mesa 提供了将 IR 打印为人类可读文本格式的方法。我们可以通过使用环境变量MESA_GLSL=dump来启用它。这将指示 Mesa 打印原始着色器源代码及其 IR 表示。例如：

```

$ MESA_GLSL=dump ./test_program

GLSL source for vertex shader 1:
#version 140
#extension GL_ARB_explicit_attrib_location : enable

layout(location = 0) in vec3 inVertexPosition;
layout(location = 1) in vec3 inVertexColor;

uniform mat4 MVP;
smooth out vec3 out0;

void main()
{
  gl_Position = MVP * vec4(inVertexPosition, 1);
  out0 = inVertexColor;
}

GLSL IR for shader 1:
(
(declare (sys ) int gl_InstanceID)
(declare (sys ) int gl_VertexID)
(declare (shader_out ) (array float 0) gl_ClipDistance)
(declare (shader_out ) float gl_PointSize)
(declare (shader_out ) vec4 gl_Position)
(declare (uniform ) (array vec4 56) gl_CurrentAttribFragMESA)
(declare (uniform ) (array vec4 33) gl_CurrentAttribVertMESA)
(declare (uniform ) gl_DepthRangeParameters gl_DepthRange)
(declare (uniform ) int gl_NumSamples)
(declare () int gl_MaxVaryingComponents)
(declare () int gl_MaxClipDistances)
(declare () int gl_MaxFragmentUniformComponents)
(declare () int gl_MaxVaryingFloats)
(declare () int gl_MaxVertexUniformComponents)
(declare () int gl_MaxDrawBuffers)
(declare () int gl_MaxTextureImageUnits)
(declare () int gl_MaxCombinedTextureImageUnits)
(declare () int gl_MaxVertexTextureImageUnits)
(declare () int gl_MaxVertexAttribs)
(declare (shader_in ) vec3 inVertexPosition)
(declare (shader_in ) vec3 inVertexColor)
(declare (uniform ) mat4 MVP)
(declare (shader_out smooth) vec3 out0)
(function main
  (signature void
    (parameters
    )
    (
      (declare (temporary ) vec4 vec_ctor)
      (assign  (w) (var_ref vec_ctor)  (constant float (1.000000)) )
      (assign  (xyz) (var_ref vec_ctor)  (var_ref inVertexPosition) )
      (assign  (xyzw) (var_ref gl_Position)
            (expression vec4 * (var_ref MVP) (var_ref vec_ctor) ) )
      (assign  (xyz) (var_ref out0)  (var_ref inVertexColor) )
    ))
)
)
```

但是请注意，我们得到的 IR 表示不是解析器生成的。正如我们稍后将看到的，Mesa 将通过多种方式修改初始 IR，例如通过添加不同类型的优化，因此我们看到的 IR 是所有这些处理通过原始 IR 后的结果。Mesa 将这个经过后处理的 IR 版本称为LIR（低级 IR），并将解析器生成的 IR 的初始版本称为HIR（高级 IR）。如果我们想打印HIR（或 IR 转换为最终LIR 的任何中间版本），我们可以编辑编译器并根据需要添加对 _mesa_print_ir 的调用。

## 穿越 Mesa IR

我们之前提到过编译器的一些工作（实际上是很大一部分）与 IR 的优化和修改有关。这意味着编译器需要遍历 IR 树并识别与此类操作相关的子树。为了实现这一点，Mesa 使用了访问者设计模式。

基本上，这个想法是我们有一个可以遍历 IR 树的访问者对象，我们可以定义当它找到特定节点时我们想要执行的行为。

例如，在src/glsl/linker.cpp 中有一个非常简单的例子：find_deref_visitor，它检测变量是否被读取。这涉及遍历 IR，识别ir_dereference_variable节点（访问变量值的节点）并检查该变量的名称是否与我们要查找的名称匹配。这是访问者类定义：

```
/**
 * Visitor that determines whether or not a variable is ever read.
 */
class find_deref_visitor : public ir_hierarchical_visitor {
public:
   find_deref_visitor(const char *name)
      : name(name), found(false)
   {
      /* empty */
   }

   virtual ir_visitor_status visit(ir_dereference_variable *ir)
   {
      if (strcmp(this->name, ir->var->name) == 0) {
         this->found = true;
         return visit_stop;
      }

      return visit_continue;
   }

   bool variable_found() const
   {
      return this->found;
   }

private:
   const char *name;       /**< Find writes to a variable with this name. */
   bool found;             /**< Was a write to the variable found? */
};
```
这就是我们如何使用它，例如检查着色器代码是否曾经读取gl_Vertex：
```
find_deref_visitor find("gl_Vertex");
find.run(sh->ir);
if (find.variable_found()) {
  (...)
}
```

Mesa 中的大多数优化和降低通道都是作为访问者实现的，并遵循类似的想法。我们将在后面的文章中查看这些示例

## 内置变量和函数

GLSL 为 Mesa 自动注入着色器代码的每个着色器阶段定义了一组内置变量（带有“gl_”前缀）。如果您查看我们使用`MESA_GLSL=dump`获取生成的Mesa IR的示例，您可以看到其中一些变量。

Mesa 在_mesa_glsl_initialize_variables() 中实现了对内置变量的支持，定义在src/glsl/builtin_variables.cpp 中。

请注意，其中一些变量对所有着色器阶段都是通用的，而有些变量特定于特定阶段或仅在特定版本的 GLSL 中可用。

根据变量的类型，Mesa 或硬件驱动程序可能能够立即提供值（例如，对于保存常量值的变量，如gl_MaxVertexAttribs或gl_MaxDrawBuffers）。否则，驱动程序可能必须在程序运行时通过生成添加到用户程序的本机代码从硬件中获取（或生成）变量的值。例如，使用gl_PrimitiveID的几何着色器将需要为绘制调用中几何着色器单元处理的每个图元更新该变量。为了实现这一点，驱动程序可能必须生成本机代码，从硬件获取当前原始 ID 值并将其存储在寄存器中，该寄存器为执行用户代码之前的gl_PrimitveID变量。

GLSL 语言还定义了许多必须由实现者提供的可用内置函数，例如texture()、mix() 或 dot() 等，仅举几例。Mesa 的 GLSL 编译器中内置函数的入口点是src/glsl/builtin_functions.cpp。

方法builtin_builder::create_builtins()负责注册内置函数，就像内置变量一样，并非所有函数都始终可用：某些函数可能仅在某些着色单元中可用，而其他函数可能仅在某些 GLSL 版本等。为此，每个内置函数都注册了一个谓词，该谓词可用于测试该函数在特定场景中是否完全可用。

内置函数通过调用add_function()方法注册，该方法注册特定函数的所有版本。例如，用于 float、vec2、vec3、vec4 等的mix()这些版本中的每一个都有自己的可用性谓词。例如，mix()始终可用于浮点参数，但将其与整数一起使用需要GLSL 1.30和EXT_shader_integer_mix扩展。

除了可用性谓词之外，add_function()还接受一个ir_function_signature，它告诉 Mesa 正在注册的函数的特定签名。请注意，当 Mesa 为函数创建签名时，它还定义了函数体。例如，以下代码片段定义了modf()的签名：

```
ir_function_signature *
builtin_builder::_modf(builtin_available_predicate avail,
                       const glsl_type *type)
{
   ir_variable *x = in_var(type, "x");
   ir_variable *i = out_var(type, "i");
   MAKE_SIG(type, avail, 2, x, i);

   ir_variable *t = body.make_temp(type, "t");
   body.emit(assign(t, expr(ir_unop_trunc, x)));
   body.emit(assign(i, t));
   body.emit(ret(sub(x, t)));

   return sig;
}
```

GLSL 的modf()将数字拆分为整数和小数部分。它将整数部分分配给输出参数，函数返回值是小数部分。

我们在上面看到的这个签名定义了类型为“type”的输入参数“x”（我们想要分割的数字）、一个相同类型的输出参数“i”（它将保存“x”的整数部分）和一个返回值输入“类型”。

函数实现基于一元运算符ir_unop_trunc的存在，它可以取一个数字并提取其整数部分。然后它通过从原始数字中减去小数部分来计算小数部分。

当使用modf()内置函数时，调用将被扩展以包含此 IR 代码，稍后将通过相应的硬件驱动程序将其转换为 GPU 的本机代码。在这种情况下，这意味着硬件驱动预计将提供所述的实现ir_unop_trunc操作者，例如，其在Intel i965的驱动器的情况下，作为一个单一的硬件指令被实现（见brw_vec4_visitor.cpp或brw_fs_visitor.cpp,在src/mesa/drivers/dri/i965）。

在某些情况下，无法在 IR 级别定义内置函数的实现。在这种情况下，实现只是发出一个临时 IR 节点，驱动程序可以适当地识别和扩展。一个例子是几何着色器中的EmitVertex()。这并不是传统意义上的真正函数调用，而是一种向驱动程序发出信号的方式，即我们已经定义了一个顶点的所有属性，是时候将该顶点“推”到当前图元中了。“推动顶点”的含义无法在 IR 级别定义，因为每个驱动程序/硬件都会有所不同。因此，内置函数只需注入一个 IR 节点ir_emit_vertex驾驶员可以在时机成熟时识别并正确实施。在英特尔代码的情况下，推送顶点涉及许多与硬件非常交织的步骤，但它基本上相当于生成实现硬件期望发生的行为的本机代码。如果您很好奇，可以在brw_vec4_gs_visitor.cpp中的 i965 驱动程序代码中找到它的实现，该方法在将ir_emit_vertex IR 节点作为参数的visit()方法中。

## 接下来的事

在这篇文章中，我们讨论了解析器，它是编译器的入口点，并介绍了主要数据结构Mesa IR。在接下来的文章中，我们将深入研究 GLSL 编译器的实现。具体来说，我们将研究降低和优化过程以及链接过程和处理本机代码生成的硬件驱动程序的钩子。
