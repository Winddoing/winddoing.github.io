---
title: 状态机
date: 2017-07-9 23:07:24
categories: 程序设计
tags: [FSM]
---


## 状态机

有限状态机（Finite State Machine或者Finite State Automata)是软件领域中一种重要的工具，很多东西的模型实际上就是有限状态机。

<!--more-->

### FSM的实现方式：

1. switch/case或者if/else

这无意是最直观的方式，使用一堆条件判断，会编程的人都可以做到，对简单小巧的状态机来说最合适，但是毫无疑问，这样的方式比较原始，对庞大的状态机难以维护。

2. 状态表

维护一个二维状态表，横坐标表示当前状态，纵坐标表示输入，表中一个元素存储下一个状态和对应的操作。这一招易于维护，但是运行时间和存储空间的代价较大。

## 实现

有限状态机(finite state machine)是一个数学概念，如果把它运用于程序中，可以发挥很大的作用。它是一种协议，用于有限数量的子程序("状态")的发展变化。每个子程序进行一些处理并选择下一种状态(通常取决于下一段输入)。

有限状态机(FSM)可以用作程序的控制结构。FSM对于那些基于输入的在几个不同的可选动作中进行循环的程序尤其合适。投币售货机就是FSM的一个好例子。另外一个你可以想到的复杂的例子就是你正在用的东西，想到了吗？没错，就是操作系统。在投币售货机的例子中，输入是硬币，输出是待售商品，售货机有"接受硬币"，"选择商品"，"发送商品"和"找零钱"等几种状态。

它的基本思路是用一张表保存所有可能的状态，并列出进入每个状态时可能执行的所有动作，其中最后一个动作就是计算(通常在当前状态和下一次输入字符的基础上，另外再经过一次表查询)下一个应该进入的状态。你从一个"初始状态"开始。在这一过程中，翻译表可能告诉你进入了一个错误状态，直到到达结束状态。

## 实例

``` C
#include <stdio.h>
#include <unistd.h>  

//比如我们定义了小明一天的状态如下
enum
{
	GET_UP,
	GO_TO_SCHOOL,
	HAVE_LUNCH,
	DO_HOMEWORK,
	SLEEP,
};

enum
{
	EVENT1 = 1,
	EVENT2,
	EVENT3,
};

typedef struct FsmTable_s
{
	int event;   //事件
	int CurState;  //当前状态
	void (*eventActFun)();  //函数指针
	int NextState;  //下一个状态
}FsmTable_t;

typedef struct FSM_s
{
	FsmTable_t* FsmTable;   //指向的状态表
	int curState;  //FSM当前所处的状态
}FSM_t;

int g_max_num;  //状态表里含有的状态个数

void GetUp()
{
	// do something
	printf("xiao ming gets up!\n");
}
void Go2School()
{
	// do something
	printf("xiao ming goes to school!\n");
}
void HaveLunch()
{
	// do something
	printf("xiao ming has lunch!\n");
}
void DoHomework()
{
	// do something
	printf("xiao ming does homework!\n");
}
void Go2Bed()
{
	// do something
	printf("xiao ming goes to bed!\n");
}
/*状态机注册*/
void FSM_Regist(FSM_t* pFsm, FsmTable_t* pTable)
{
	pFsm->FsmTable = pTable;
}

/*状态迁移*/
void FSM_StateTransfer(FSM_t* pFsm, int state)
{
	pFsm->curState = state;
}

/*事件处理*/
void FSM_EventHandle(FSM_t* pFsm, int event)
{
	FsmTable_t* pActTable = pFsm->FsmTable;
	void (*eventActFun)() = NULL;  //函数指针初始化为空
	int NextState;
	int CurState = pFsm->curState;
	int flag = 0; //标识是否满足条件
	int i;

	/*获取当前动作函数*/
	for (i = 0; i<g_max_num; i++) {
		//当且仅当当前状态下来个指定的事件，我才执行它
		if (event == pActTable[i].event && 
				CurState == pActTable[i].CurState) {
			flag = 1;
			eventActFun = pActTable[i].eventActFun;
			NextState = pActTable[i].NextState;
			break;
		}
	}

	if (flag) {
		/*动作执行*/
		if (eventActFun) {
			eventActFun();
		}
		//跳转到下一个状态
		FSM_StateTransfer(pFsm, NextState);
	} else {
		// do nothing
	}
}

FsmTable_t XiaoMingTable[] =
{
	//{到来的事件，当前的状态，将要要执行的函数，下一个状态}
	{ EVENT1,  SLEEP,           GetUp,        GET_UP },
	{ EVENT2,  GET_UP,          Go2School,    GO_TO_SCHOOL },
	{ EVENT3,  GO_TO_SCHOOL,    HaveLunch,    HAVE_LUNCH },
	{ EVENT1,  HAVE_LUNCH,      DoHomework,   DO_HOMEWORK },
	{ EVENT2,  DO_HOMEWORK,     Go2Bed,       SLEEP },
	//add your codes here
};

//初始化FSM
void InitFsm(FSM_t* pFsm)
{
	g_max_num = sizeof(XiaoMingTable) / sizeof(FsmTable_t);
	pFsm->curState = SLEEP;
	FSM_Regist(pFsm, XiaoMingTable);
}

//测试
void test(int *event)
{
	if (*event == 3) {
		*event = 1;
	} else {
		(*event)++;
	}

}

int main()
{
	FSM_t fsm;
	InitFsm(&fsm);
	int event = EVENT1; 
	//小明的一天,周而复始的一天又一天，进行着相同的活动
	while (1) {
		printf("event %d is coming...\n", event);
		FSM_EventHandle(&fsm, event);
		printf("fsm current state %d\n", fsm.curState);
		test(&event); 
		sleep(1);  //休眠1秒，方便观察
	}

	return 0;
}
```


