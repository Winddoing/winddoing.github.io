---
layout: "post"
title: "[转]An introduction to Mesa’s GLSL compiler (II)[翻译]"
date: "2021-07-20 19:34"
tags:
  - mesa
  - glsl
  - opengl
categories:
  - 多媒体
---

原文： https://blogs.igalia.com/itoral/2015/03/06/an-introduction-to-mesas-glsl-compiler-ii/

<!--more-->

## 回顾

我之前的文章是对 Mesa 的 GLSL 编译器的初步了解，我们在其中讨论了 Mesa IR，它是编译器的一个核心方面。在这篇文章中，我将介绍另一个相关方面：IR lowering​​​​​​​。

## IR lowering

Mesa 中实现了多个降低通道（查看src/glsl/lower_*.cpp以获取完整列表），但它们都有一个共同点：它们的目的是重写 IR 中的某些构造，以便它们更适合底层 GPU硬件。

在这篇文章中，我们将研究lower_instructions.cpp降低传递，它重写了具有不同实现的GPU硬件可能不直接支持的表达式操作。

降低过程涉及遍历 IR，识别我们想要降低的指令并相应地修改 IR，这非常适合我在上一篇文章中讨论的访问者模式策略。在这种情况下，表达式降低由lower_instructions_visitor类处理，该类在visit_leave()方法中为ir_expression 节点实现降低传递。

分层访问者类，作为 Mesa 中大多数访问者的基类，为IR 树中的叶节点定义了visit()方法，为非叶节点定义了visit_leave()/visit_enter()方法。这样，当遍历 IR 中的中间节点时，我们可以决定在进入它们或即将离开它们时立即采取行动。

在我们的lower_instructions_visitor类的情况下，visit_leave()方法实现是一个大的switch()语句，其中包含它可以降低的所有运算符。

此文件中的代码降低了预计对大多数 GPU 驱动程序有用的常见场景，但个别驱动程序仍然可以选择他们想要使用这些降低通道中的哪一个。为此，硬件驱动程序创建了lower_instructions类的实例，传递了要启用的降低通道列表。例如，Intel i965 驱动程序执行以下操作：
```
onst int bitfield_insert = brw->gen >= 7
                            ? BITFIELD_INSERT_TO_BFM_BFI
                            : 0;
lower_instructions(shader->base.ir,
                   MOD_TO_FLOOR |
                   DIV_TO_MUL_RCP |
                   SUB_TO_ADD_NEG |
                   EXP_TO_EXP2 |
                   LOG_TO_LOG2 |
                   bitfield_insert |
                   LDEXP_TO_ARITH);
```

请注意，在英特尔 GPU 的情况下，如何根据所涉及的硬件有条件地选择降低通道之一。在这种情况下，brw->gen >= 7选择自IvyBridge以来的 GPU 代。

让我们来看看其中一些降低通道的实现。例如，SUB_TO_ADD_NEG是一个非常简单的将减法转换为负加法的方法：

```

void
lower_instructions_visitor::sub_to_add_neg(ir_expression *ir)
{
   ir->operation = ir_binop_add;
   ir->operands[1] =
      new(ir) ir_expression(ir_unop_neg, ir->operands[1]->type,
                            ir->operands[1], NULL);
   this->progress = true;
}
```

如我们所见，降低传递简单地改变了ir_expression节点使用的运算符，并使用一元取反运算符 (ir_unop_neg) 取反第二个操作数，从而将原始a = b – c转换为a = b + (-c )。

当然，如果驱动程序没有对减法操作的本机支持，它在处理 IR 以生成本机代码时仍然可以这样做，但这样 Mesa 节省了驱动程序开发人员的工作。此外，一些降低通道可能会在降低驱动程序可能会错过的降低之后启用优化通道。

让我们看一个更复杂的例子：MOD_TO_FLOOR。在这种情况下，降低传递为没有本地模运算的 GPU提供了ir_binop_mod（模）的实现。

模运算采用两个操作数 (op0, op1) 并实现“ op0 % op1 ”的 C 等效项，即它计算 op0 除以 op1 的余数。为了实现这一点，降低传递将模运算分解为mod(op0, op1) = op0 – op1 * floor(op0 / op1)，它只需要乘法、除法和减法。这是实现：

```

ir_variable *x = new(ir) ir_variable(ir->operands[0]->type, "mod_x",
                                     ir_var_temporary);
ir_variable *y = new(ir) ir_variable(ir->operands[1]->type, "mod_y",
                                     ir_var_temporary);
this->base_ir->insert_before(x);
this->base_ir->insert_before(y);

ir_assignment *const assign_x =
   new(ir) ir_assignment(new(ir) ir_dereference_variable(x),
                         ir->operands[0], NULL);
ir_assignment *const assign_y =
   new(ir) ir_assignment(new(ir) ir_dereference_variable(y),
                         ir->operands[1], NULL);

this->base_ir->insert_before(assign_x);
this->base_ir->insert_before(assign_y);

ir_expression *const div_expr =
   new(ir) ir_expression(ir_binop_div, x->type,
                         new(ir) ir_dereference_variable(x),
                         new(ir) ir_dereference_variable(y));

/* Don't generate new IR that would need to be lowered in an additional
 * pass.
 */
if (lowering(DIV_TO_MUL_RCP) && (ir->type->is_float() ||
    ir->type->is_double()))
   div_to_mul_rcp(div_expr);

ir_expression *const floor_expr =
   new(ir) ir_expression(ir_unop_floor, x->type, div_expr);

if (lowering(DOPS_TO_DFRAC) && ir->type->is_double())
   dfloor_to_dfrac(floor_expr);

ir_expression *const mul_expr =
   new(ir) ir_expression(ir_binop_mul,
                         new(ir) ir_dereference_variable(y),
                         floor_expr);

ir->operation = ir_binop_sub;
ir->operands[0] = new(ir) ir_dereference_variable(x);
ir->operands[1] = mul_expr;
this->progress = true;
```

注意它做的第一件事是如何将操作数分配给变量。这样做的原因有点棘手：由于我们要将ir_binop_mod实现为op0 – op1 * floor(op0 / op1)，因此我们需要在树中两次引用 IR 节点 op0 和 op1。但是，我们不能直接这样做，因为这意味着我们有从 IR 表达式树中的两个不同位置链接的相同节点（即相同的指针）。也就是说，我们想要这棵树：

```
   sub
 /     \
op0     mult
       /    \
    op1     floor
              |
             div
            /   \
         op0     op1
```

而不是这棵树：

```
                    sub
                  /     \
                  |      mult
                  |     /   \
                  |   floor  |
                  |     |    |
                  |    div   |
                  |   /   \  |
                   op0     op1
```

树的第二个版本是有问题的。例如，假设一个假设的优化过程检测到op1是一个值为1的常量整数，并意识到在这种情况下div(op0/op1) == op0。在进行优化时，我们的div子树被删除，这样，op1也可以被删除（并且可能被释放），在 IR 中留下对该操作数的另一个引用指向一个无效的内存位置……我们刚刚破坏了我们的 IR：

```
                             sub
                           /     \
                           |      mult
                           |     /    \
                           |   floor   op1 [invalid pointer reference]
                           |     |
                           |    /
                           |   /
                            op0
```

相反，我们在这里要做的是每次在 IR 中需要对节点的新引用时克隆节点。为此，所有 IR 节点都有一个clone()方法。但是，在这种特殊情况下，克隆节点会产生一个新问题：op0和op1是ir_expression节点，因此，例如，op0可能是表达式a + b * c，因此克隆表达式将产生次优代码，其中表达式被复制. 这充其量会导致更慢
由于优化传递需要检测和修复的编译时间，更糟糕的是，优化器不会检测到，并导致性能更差，我们多次计算表达式的值：

```

                              sub
                           /        \
                         add         mult
                        /   \       /    \
                      a     mult  op1     floor
                            /   \          |
                           b     c        div
                                         /   \
                                      add     op1
                                     /   \
                                    a    mult
                                        /    \
                                        b     c
```

这个问题的解决方案是将表达式分配给一个变量，然后在我们需要的任何地方取消引用该变量（即读取它的值）。因此，实现定义了两个变量(x, y)，将op0和op1分配给它们，并在我们需要访问op0和op1表达式的值的任何地方创建新的解引用节点：

```
                       =               =
                     /   \           /   \
                    x     op0       y     op1


                             sub
                           /     \
                         *x       mult
                                 /    \
                               *y     floor
                                        |
                                       div
                                      /   \
                                    *x     *y
```

在上图中，每个变量解引用都标有'*'，每个变量都是一个新的 IR 节点（因此'*x' 的两次出现都指代不同的 IR 节点，都代表对同一变量的两个不同读取）。使用这个解决方案，我们只计算op0和op1表达式一次（当它们被分配给相应的变量时），我们从不从不同的地方两次引用同一个 IR 节点（因为每个变量取消引用都是一个新的 IR 节点）。

现在我们知道为什么要分配这两个变量了，让我们继续看降低传递的代码：

在下一步中，我们使用 ir_binop_div 表达式实现op0 / op1。为了加快编译速度，如果驱动程序启用了DIV_TO_MUL_RCP降低传递，将a / b转换为a * 1 / b（其中1 / b可能是本机指令），我们立即执行该表达式的降低传递。如果我们在这里不这样做，则生成的 IR 将包含一个除法运算，该运算可能必须在以后的传递中降低，从而使编译过程变慢。

下一步使用ir_unop_floor表达式来计算floor(op0/op1)，并再次测试此操作是否也应该降低，如果操作数的类型是 64 位双精度数而不是常规的 32 位浮点数，则可能是这种情况，因为 GPU 可能只有 32 位浮点数的本机楼层指令。

接下来，我们将结果乘以op1得到op1 * floor(op0 / op1)。

现在我们只需要从 op0 中减去它，这将是这个表达式的根 IR 节点。因为我们希望新的IR树从这个根节点产卵，以取代旧的实现，我们直接编辑，我们正在降低，以取代红外节点ir_binop_mod与运营商ir_binop_sub，做一个提领来OP1于第一运算和链接式保持OP1 * floor(op0 / op1)在第二个操作数中，有效地附加了我们的新实现来代替旧版本。这是原始和降低的 IR 的样子：​​​​​​​

Original IR:

```
[prev inst] -> mod -> [next inst]
              /   \            
           op0     op1  
```

Lowered IR:

```
[prev inst] -> var x -> var y ->   =   ->   =   ->   sub   -> [next inst]
                                  / \      / \      /   \
                                 x  op0   y  op1  *x     mult
                                                        /    \
                                                      *y      floor
                                                                |
                                                               div
                                                              /   \
                                                            *x     *y
```

最后，我们返回 true 以让编译器知道我们已经优化了 IR，因此我们引入了可能会进一步降低传递的新节点，因此它可以运行新的传递。例如，我们刚刚添加的减法可能会再次降低到我们之前看到的负加法。

## 接下来的是
现在我们了解了降低通道，我们还可以讨论优化通道，它们非常相似，因为它们也基于 Mesa 中的访问者实现，并且也以类似的方式转换Mesa IR。
