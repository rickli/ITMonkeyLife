---
layout: post
title: "Mac可执行文件"
date: 2014-04-21 17:51:10 +0800
comments: true
categories: [iOS]
---
<p>我们用 Xcode 构建一个程序的过程中，会把源文件 (<code>.m</code> 和 <code>.h</code>) 文件转换为一个可执行文件。这个可执行文件中包含的字节码会将被 CPU (iOS 设备中的 ARM 处理器或 Mac 上的 Intel 处理器) 执行。</p>

<p>本文将介绍一下上面的过程中编译器都做了些什么，同时深入看看可执行文件内部是怎样的。实际上里面的东西要比我们第一眼看到的多得多。</p>

<p>这里我们把 Xcode 放一边，将使用命令行工具 (command-line tools)。当我们用 Xcode 构建一个程序时，Xcode 只是简单的调用了一系列的工具而已。Florian 对工具调用是如何工作的做了更详细的讨论。本文我们就直接调用这些工具，并看看它们都做了些什么。</p>

<p>真心希望本文能帮助你更好的理解 iOS 或 OS X 中的一个可执行文件 (也叫做 <em>Mach-O executable</em>) 是如何执行，以及怎样组装起来的。</p>

<h2 id="xcrun">xcrun</h2>

<p>先来看一些基础性的东西：这里会大量使用一个名为 <code>xcrun</code> 的命令行工具。看起来可能会有点奇怪，不过它非常的出色。这个小工具用来调用别的一些工具。原先，我们在终端执行如下命令：</p>

<pre><code>% clang -v
</code></pre>

<p>现在我们用下面的命令代替：</p>

<pre><code>% xcrun clang -v
</code></pre>

<p>在这里 <code>xcrun</code> 做的是定位到 <code>clang</code>，并执行它，附带输入 <code>clang</code> 后面的参数。</p>

<p>我们为什么要这样做呢？看起来没有什么意义。不过 <code>xcode</code> 允许我们: (1) 使用多个版本的 Xcode，以及使用某个特定 Xcode 版本中的工具。(2) 针对某个特定的 SDK (software development kit) 使用不同的工具。如果你有 Xcode 4.5 和 Xcode 5，通过 <code>xcode-select</code> 和 <code>xcrun</code> 可以选择使用 Xcode 5 中 iOS SDK 的工具，或者 Xcode 4.5 中的 OS X 工具。在许多其它平台中，这是不可能做到的。查阅 <code>xcrun</code> 和 <code>xcode-select</code> 的主页内容可以了解到详细内容。不用安装 <em>Command Line Tools</em>，就能使用命令行中的开发者工具。</p>

<h2 id="idehelloworld">不使用 IDE 的 Hello World</h2>

<p>回到终端 (Terminal)，创建一个包含一个 C 文件的文件夹：</p>

<pre><code>% mkdir ~/Desktop/objcio-command-line
% cd !$
% touch helloworld.c
</code></pre>

<p>接着使用你喜欢的文本编辑器来编辑这个文件 -- 例如 TextEdit.app：</p>

<pre><code>% open -e helloworld.c
</code></pre>

<p>输入如下代码：</p>

```c
#include <stdio.h>
int main(int argc, char *argv[])
{
    printf("Hello World!\n");
    return 0;
}
```

<p>保存并返回到终端，然后运行如下命令：</p>

<pre><code>% xcrun clang helloworld.c
% ./a.out
</code></pre>
<!-- more -->
<p>现在你能够在终端上看到熟悉的 <code>Hello World!</code>。这里我们编译并运行 C 程序，全程没有使用 IDE。深呼吸一下，高兴高兴。</p>

<p>上面我们到底做了些什么呢？我们将 <code>helloworld.c</code> 编译为一个名为 <code>a.out</code> 的 Mach-O 二进制文件。注意，如果我们没有指定名字，那么编译器会默认的将其指定为 a.out。</p>

<p>这个二进制文件是如何生成的呢？实际上有许多内容需要观察和理解。我们先看看编译器吧。</p>

<h3 id="helloworld">Hello World 和编译器</h3>

<p>时下 Xcode 中编译器默认选择使用 <code>clang</code>(读作 /klæŋ/)。<a href="http://objccn.io/issue-6-2/">关于编译器</a>，Chris 写了更详细的文章。</p>

<p>简单的说，编译器处理过程中，将 <code>helloworld.c</code> 当做输入文件，并生成一个可执行文件 <code>a.out</code>。这个过程有多个步骤/阶段。我们需要做的就是正确的执行它们。</p>

<h5 id="">预处理</h5>

<ul>
<li>符号化 (Tokenization)</li>
<li>宏定义的展开</li>
<li><code>#include</code> 的展开</li>
</ul>

<h5 id="">语法和语义分析</h5>

<ul>
<li>将符号化后的内容转化为一棵解析树 (parse tree)</li>
<li>解析树做语义分析</li>
<li>输出一棵<em>抽象语法树</em>（Abstract Syntax Tree* (AST)）</li>
</ul>

<h5 id="">生成代码和优化</h5>

<ul>
<li>将 AST 转换为更低级的中间码 (LLVM IR)</li>
<li>对生成的中间码做优化</li>
<li>生成特定目标代码</li>
<li>输出汇编代码</li>
</ul>

<h5 id="">汇编器</h5>

<ul>
<li>将汇编代码转换为目标对象文件。</li>
</ul>

<h5 id="">链接器</h5>

<ul>
<li>将多个目标对象文件合并为一个可执行文件 (或者一个动态库)</li>
</ul>

<p>我们来看一个关于这些步骤的简单的例子。</p>

<h4 id="">预处理</h4>

<p>编译过程中，编译器首先要做的事情就是对文件做处理。预处理结束之后，如果我们停止编译过程，那么我们可以让编译器显示出预处理的一些内容：</p>

<pre><code>% xcrun clang -E helloworld.c
</code></pre>

<p>喔喔。 上面的命令输出的内容有 413 行。我们用编辑器打开这些内容，看看到底发生了什么：</p>

<pre><code>% xcrun clang -E helloworld.c | open -f
</code></pre>

<p>在顶部可以看到的许多行语句都是以 <code>#</code> 开头 (读作 <code>hash</code>)。这些被称为 <em>行标记</em> 的语句告诉我们后面跟着的内容来自哪里。如果再回头看看 <code>helloworld.c</code> 文件，会发现第一行是：</p>

```c
#include <stdio.h>
```

<p>我们都用过 <code>#include</code> 和 <code>import</code>。它们所做的事情是告诉预处理器将文件 <code>stdio.h</code> 中的内容插入到 <code>#include</code> 语句所在的位置。这是一个递归的过程：<code>stdio.h</code> 可能会包含其它的文件。</p>

<p>由于这样的递归插入过程很多，所以我们需要确保记住相关行号信息。为了确保无误，预处理器在发生变更的地方插入以 <code>#</code> 开头的 <code>行标记</code>。跟在 <code>#</code> 后面的数字是在源文件中的行号，而最后的数字是在新文件中的行号。回到刚才打开的文件，紧跟着的是系统头文件，或者是被看做为封装了 <code>extern "C"</code> 代码块的文件。</p>

<p>如果滚动到文件末尾，可以看到我们的 <code>helloworld.c</code> 代码：</p>

```c
# 2 "helloworld.c" 2
int main(int argc, char *argv[])
{
 printf("Hello World!\n");
 return 0;
}
```

<p>在 Xcode 中，可以通过这样的方式查看任意文件的预处理结果：<strong>Product</strong> -> <strong>Perform Action</strong> -> <strong>Preprocess</strong>。注意，编辑器加载预处理后的文件需要花费一些时间 -- 接近 100,000 行代码。</p>

<h4 id="">编译</h4>

<p>下一步：分析和代码生成。我们可以用下面的命令让 <code>clang</code> 输出汇编代码：</p>

<pre><code>% xcrun clang -S -o - helloworld.c | open -f
</code></pre>

<p>我们来看看输出的结果。首先会看到有一些以点 <code>.</code> 开头的行。这些就是汇编指令。其它的则是实际的 x86_64 汇编代码。最后是一些标记 (label)，与 C 语言中的类似。</p>

<p>我们先看看前三行：</p>

<pre><code>    .section    __TEXT,__text,regular,pure_instructions
    .globl  _main
    .align  4, 0x90
</code></pre>

<p>这三行是汇编指令，不是汇编代码。<code>.section</code> 指令指定接下来会执行哪一个段。</p>

<p>第二行的 <code>.globl</code> 指令说明 <code>_main</code> 是一个外部符号。这就是我们的 <code>main()</code> 函数。这个函数对于二进制文件外部来说是可见的，因为系统要调用它来运行可执行文件。</p>

<p><code>.align</code> 指令指出了后面代码的对齐方式。在我们的代码中，后面的代码会按照 16(2^4) 字节对齐，如果需要的话，用 <code>0x90</code> 补齐。</p>

<p>接下来是 main 函数的头部：</p>

<pre><code>_main:                                  ## @main
    .cfi_startproc
## BB#0:
    pushq   %rbp
Ltmp2:
    .cfi_def_cfa_offset 16
Ltmp3:
    .cfi_offset %rbp, -16
    movq    %rsp, %rbp
Ltmp4:
    .cfi_def_cfa_register %rbp
    subq    $32, %rsp
</code></pre>

<p>上面的代码中有一些与 C 标记工作机制一样的一些标记。它们是某些特定部分的汇编代码的符号链接。首先是 <code>_main</code> 函数真正开始的地址。这个符号会被 export。二进制文件会有这个位置的一个引用。</p>

<p><code>.cfi_startproc</code> 指令通常用于函数的开始处。CFI 是调用帧信息 (Call Frame Information) 的缩写。这个调用 <code>帧</code> 以松散的方式对应着一个函数。当开发者使用 debugger 和 <em>step in</em> 或 <em>step out</em> 时，实际上是 stepping in/out 一个调用帧。在 C 代码中，函数有自己的调用帧，当然，别的一些东西也会有类似的调用帧。<code>.cfi_startproc</code> 指令给了函数一个 <code>.eh_frame</code> 入口，这个入口包含了一些调用栈的信息（抛出异常时也是用其来展开调用帧堆栈的）。这个指令也会发送一些和具体平台相关的指令给 CFI。它与后面的 <code>.cfi_endproc</code> 相匹配，以此标记出 <code>main()</code> 函数结束的地方。</p>

<p>接着是另外一个 label <code>## BB#0:</code>。然后，终于，看到第一句汇编代码：<code>pushq %rbp</code>。从这里开始事情开始变得有趣。在 OS X上，我们会有 X86_64 的代码，对于这种架构，有一个东西叫做 <em>ABI</em> ( 应用二进制接口 application binary interface)，ABI 指定了函数调用是如何在汇编代码层面上工作的。在函数调用期间，ABI 会让 <code>rbp</code> 寄存器 (基础指针寄存器 base pointer register) 被保护起来。当函数调用返回时，确保 <code>rbp</code> 寄存器的值跟之前一样，这是属于 main 函数的职责。<code>pushq %rbp</code> 将 <code>rbp</code> 的值 push 到栈中，以便我们以后将其 pop 出来。</p>

<p>接下来是两个 CFI 指令：<code>.cfi_def_cfa_offset 16</code> 和 <code>.cfi_offset %rbp, -16</code>。这将会输出一些关于生成调用堆栈展开和调试的信息。我们改变了堆栈和基础指针，而这两个指令可以告诉编译器它们都在哪儿，或者更确切的，它们可以确保之后调试器要使用这些信息时，能找到对应的东西。</p>

<p>接下来，<code>movq %rsp, %rbp</code> 将把局部变量放置到栈上。<code>subq $32, %rsp</code> 将栈指针移动 32 个字节，也就是函数会调用的位置。我们先将老的栈指针存储到 <code>rbp</code> 中，然后将此作为我们局部变量的基址，接着我们更新堆栈指针到我们将会使用的位置。</p>

<p>之后，我们调用了 <code>printf()</code>：</p>

<pre><code>leaq    L_.str(%rip), %rax
movl    $0, -4(%rbp)
movl    %edi, -8(%rbp)
movq    %rsi, -16(%rbp)
movq    %rax, %rdi
movb    $0, %al
callq   _printf
</code></pre>

<p>首先，<code>leaq</code> 会将 <code>L_.str</code> 的指针加载到 <code>rax</code> 寄存器中。留意 <code>L_.str</code> 标记在后面的汇编代码中是如何定义的。它就是 C 字符串<code>"Hello World!\n"</code>。 <code>edi</code> 和 <code>rsi</code> 寄存器保存了函数的第一个和第二个参数。由于我们会调用别的函数，所以首先需要将它们的当前值保存起来。这就是为什么我们使用刚刚存储的 <code>rbp</code> 偏移32个字节的原因。第一个 32 字节的值是 0，之后的 32 字节的值是 <code>edi</code> 寄存器的值 (存储了 <code>argc</code>)。然后是 64 字节 的值：<code>rsi</code> 寄存器的值 (存储了 <code>argv</code>)。我们在后面并没有使用这些值，但是编译器在没有经过优化处理的时候，它们还是会被存下来。</p>

<p>现在我们把第一个函数 <code>printf()</code> 的参数 <code>rax</code> 设置给第一个函数参数寄存器 <code>edi</code> 中。<code>printf()</code> 是一个可变参数的函数。ABI 调用约定指定，将会把使用来存储参数的寄存器数量存储在寄存器 <code>al</code> 中。在这里是 0。最后 <code>callq</code> 调用了 <code>printf()</code> 函数。</p>

<pre><code>    movl    $0, %ecx
    movl    %eax, -20(%rbp)         ## 4-byte Spill
    movl    %ecx, %eax
</code></pre>

<p>上面的代码将 <code>ecx</code> 寄存器设置为 0，并把 <code>eax</code> 寄存器的值保存至栈中，然后将 <code>ect</code> 中的 0 拷贝至 <code>eax</code> 中。ABI 规定 <code>eax</code> 将用来保存一个函数的返回值，或者此处 <code>main()</code> 函数的返回值 0：</p>

<pre><code>    addq    $32, %rsp
    popq    %rbp
    ret
    .cfi_endproc
</code></pre>

<p>函数执行完成后，将恢复堆栈指针 —— 利用上面的指令 <code>subq $32, %rsp</code> 把堆栈指针 <code>rsp</code> 上移 32 字节。最后，把之前存储至 <code>rbp</code> 中的值从栈中弹出来，然后调用 <code>ret</code> 返回调用者， <code>ret</code> 会读取出栈的返回地址。 <code>.cfi_endproc</code> 平衡了 <code>.cfi_startproc</code> 指令。</p>

<p>接下来是输出字符串 <code>"Hello World!\n"</code>:</p>

<pre><code>    .section    __TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
    .asciz   "Hello World!\n"
</code></pre>

<p>同样，<code>.section</code> 指令指出下面将要进入的段。<code>L_.str</code> 标记运行在实际的代码中获取到字符串的一个指针。<code>.asciz</code> 指令告诉编译器输出一个以 ‘\0’ (null) 结尾的字符串。</p>

<p><code>__TEXT __cstring</code> 开启了一个新的段。这个段中包含了 C 字符串：</p>

<pre><code>L_.str:                                 ## @.str
    .asciz     "Hello World!\n"
</code></pre>

<p>上面两行代码创建了一个 null 结尾的字符串。注意 <code>L_.str</code> 是如何命名，之后会通过它来访问字符串。</p>

<p>最后的 <code>.subsections_via_symbols</code> 指令是静态链接编辑器使用的。</p>

<p>更过关于汇编指令的资料可以在 苹果的 <a href="https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/Assembler/">OS X Assembler Reference</a> 中看到。AMD 64 网站有关于 <a href="http://www.x86-64.org/documentation/abi.pdf">ABI for x86 的文档</a>。另外还有 <a href="http://www.x86-64.org/documentation/assembly.html">Gentle Introduction to x86-64 Assembly</a>。</p>

<p>重申一下，通过下面的选择操作，我们可以用 Xcode 查看任意文件的汇编输出结果：<strong>Product</strong> -> <strong>Perform Action</strong> -> <strong>Assemble</strong>.</p>

<h4 id="">汇编器</h4>

<p>汇编器将可读的汇编代码转换为机器代码。它会创建一个目标对象文件，一般简称为 <em>对象文件</em>。这些文件以 <code>.o</code> 结尾。如果用 Xcode 构建应用程序，可以在工程的 <em>derived data</em> 目录中，<code>Objects-normal</code> 文件夹下找到这些文件。</p>

<h4 id="">链接器</h4>

<p>稍后我们会对链接器做更详细的介绍。这里简单介绍一下：链接器解决了目标文件和库之间的链接。什么意思呢？还记得下面的语句吗：</p>

<pre><code>callq   _printf
</code></pre>

<p><code>printf()</code> 是 <em>libc</em> 库中的一个函数。无论怎样，最后的可执行文件需要能需要知道 <code>printf()</code> 在内存中的具体位置：例如，<code>_printf</code> 的地址符号是什么。链接器会读取所有的目标文件 (此处只有一个) 和库 (此处是 <em>libc</em>)，并解决所有未知符号 (此处是 <code>_printf</code>) 的问题。然后将它们编码进最后的可执行文件中  （可以在 <em>libc</em> 中找到符号 <code>_printf</code>），接着链接器会输出可以运行的执行文件：<code>a.out</code>。</p>

<h2 id="section">Section</h2>

<p>就像我们上面提到的一样，这里有些东西叫做 section。一个可执行文件包含多个段，也就是多个 section。可执行文件不同的部分将加载进不同的 section，并且每个 section 会转换进某个 segment 里。这个概念对于所有的可执行文件都是成立的。</p>

<p>我们来看看 <code>a.out</code> 二进制中的 section。我们可以使用 <code>size</code> 工具来观察：</p>

<pre><code>% xcrun size -x -l -m a.out 
Segment __PAGEZERO: 0x100000000 (vmaddr 0x0 fileoff 0)
Segment __TEXT: 0x1000 (vmaddr 0x100000000 fileoff 0)
    Section __text: 0x37 (addr 0x100000f30 offset 3888)
    Section __stubs: 0x6 (addr 0x100000f68 offset 3944)
    Section __stub_helper: 0x1a (addr 0x100000f70 offset 3952)
    Section __cstring: 0xe (addr 0x100000f8a offset 3978)
    Section __unwind_info: 0x48 (addr 0x100000f98 offset 3992)
    Section __eh_frame: 0x18 (addr 0x100000fe0 offset 4064)
    total 0xc5
Segment __DATA: 0x1000 (vmaddr 0x100001000 fileoff 4096)
    Section __nl_symbol_ptr: 0x10 (addr 0x100001000 offset 4096)
    Section __la_symbol_ptr: 0x8 (addr 0x100001010 offset 4112)
    total 0x18
Segment __LINKEDIT: 0x1000 (vmaddr 0x100002000 fileoff 8192)
total 0x100003000
</code></pre>

<p>如上代码所示，我们的 <code>a.out</code> 文件有 4 个 segment。有些 segment 中有多个 section。</p>

<p>当运行一个可执行文件时，虚拟内存 (VM - virtual memory) 系统将 segment 映射到进程的地址空间上。映射完全不同于我们一般的认识，如果你对虚拟内存系统不熟悉，可以简单的想象虚拟内存系统将整个可执行文件加载进内存 -- 虽然在实际上不是这样的。VM 使用了一些技巧来避免全部加载。</p>

<p>当虚拟内存系统进行映射时，segment 和 section 会以不同的参数和权限被映射。</p>

<p>上面的代码中，<code>__TEXT</code> segment 包含了被执行的代码。它被以只读和可执行的方式映射。进程被允许执行这些代码，但是不能修改。这些代码也不能对自己做出修改，因此这些被映射的页从来不会被改变。</p>

<p><code>__DATA</code> segment 以可读写和不可执行的方式映射。它包含了将会被更改的数据。</p>

<p>第一个 segment 是 <code>__PAGEZERO</code>。它的大小为 4GB。这 4GB 并不是文件的真实大小，但是规定了进程地址空间的前 4GB 被映射为 不可执行、不可写和不可读。这就是为什么当读写一个 <code>NULL</code> 指针或更小的值时会得到一个 <code>EXC_BAD_ACCESS</code> 错误。这是操作系统在尝试防止<a href="http://www.xkcd.com/371/">引起系统崩溃</a>。</p>

<p>在 segment中，一般都会有多个 section。它们包含了可执行文件的不同部分。在 <code>__TEXT</code> segment 中，<code>__text</code> section 包含了编译所得到的机器码。<code>__stubs</code> 和 <code>__stub_helper</code> 是给动态链接器 (<code>dyld</code>) 使用的。通过这两个 section，在动态链接代码中，可以允许延迟链接。<code>__const</code> (在我们的代码中没有) 是常量，不可变的，就像 <code>__cstring</code> (包含了可执行文件中的字符串常量 -- 在源码中被双引号包含的字符串) 常量一样。</p>

<p><code>__DATA</code> segment 中包含了可读写数据。在我们的程序中只有 <code>__nl_symbol_ptr</code> 和 <code>__la_symbol_ptr</code>，它们分别是 <em>non-lazy</em> 和 <em>lazy</em> 符号指针。延迟符号指针用于可执行文件中调用未定义的函数，例如不包含在可执行文件中的函数，它们将会延迟加载。而针对非延迟符号指针，当可执行文件被加载同时，也会被加载。</p>

<p>在 <code>_DATA</code> segment 中的其它常见 section 包括 <code>__const</code>，在这里面会包含一些需要重定向的常量数据。例如 <code>char * const p = "foo";</code> -- <code>p</code> 指针指向的数据是可变的。<code>__bss</code> section 没有被初始化的静态变量，例如 <code>static int a;</code> -- ANSI C 标准规定静态变量必须设置为 0。并且在运行时静态变量的值是可以修改的。<code>__common</code> section 包含未初始化的外部全局变量，跟 <code>static</code> 变量类似。例如在函数外面定义的 <code>int a;</code>。最后，<code>__dyld</code> 是一个 section 占位符，被用于动态链接器。</p>

<p>苹果的 <a href="https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/Assembler/">OS X Assembler Reference</a> 文档有更多关于 section 类型的介绍。</p>

<h3 id="section">Section 中的内容</h3>

<p>下面，我们用 <code>otool(1)</code> 来观察一个 section 中的内容：</p>

<pre><code>% xcrun otool -s __TEXT __text a.out 
a.out:
(__TEXT,__text) section
0000000100000f30 55 48 89 e5 48 83 ec 20 48 8d 05 4b 00 00 00 c7 
0000000100000f40 45 fc 00 00 00 00 89 7d f8 48 89 75 f0 48 89 c7 
0000000100000f50 b0 00 e8 11 00 00 00 b9 00 00 00 00 89 45 ec 89 
0000000100000f60 c8 48 83 c4 20 5d c3 
</code></pre>

<p>上面是我们 app 中的代码。由于 <code>-s __TEXT __text</code> 很常见，<code>otool</code> 对其设置了一个缩写 <code>-t</code> 。我们还可以通过添加 <code>-v</code> 来查看反汇编代码：</p>

<pre><code>% xcrun otool -v -t a.out
a.out:
(__TEXT,__text) section
_main:
0000000100000f30    pushq   %rbp
0000000100000f31    movq    %rsp, %rbp
0000000100000f34    subq    $0x20, %rsp
0000000100000f38    leaq    0x4b(%rip), %rax
0000000100000f3f    movl    $0x0, 0xfffffffffffffffc(%rbp)
0000000100000f46    movl    %edi, 0xfffffffffffffff8(%rbp)
0000000100000f49    movq    %rsi, 0xfffffffffffffff0(%rbp)
0000000100000f4d    movq    %rax, %rdi
0000000100000f50    movb    $0x0, %al
0000000100000f52    callq   0x100000f68
0000000100000f57    movl    $0x0, %ecx
0000000100000f5c    movl    %eax, 0xffffffffffffffec(%rbp)
0000000100000f5f    movl    %ecx, %eax
0000000100000f61    addq    $0x20, %rsp
0000000100000f65    popq    %rbp
0000000100000f66    ret
</code></pre>

<p>上面的内容是一样的，只不过以反汇编形式显示出来。你应该感觉很熟悉，这就是我们在前面编译时候的代码。唯一的不同就是，在这里我们没有任何的汇编指令在里面。这是纯粹的二进制执行文件。</p>

<p>同样的方法，我们可以查看别的 section：</p>

<pre><code>% xcrun otool -v -s __TEXT __cstring a.out
a.out:
Contents of (__TEXT,__cstring) section
0x0000000100000f8a  Hello World!\n
</code></pre>

<p>或:</p>

<pre><code>% xcrun otool -v -s __TEXT __eh_frame a.out 
a.out:
Contents of (__TEXT,__eh_frame) section
0000000100000fe0    14 00 00 00 00 00 00 00 01 7a 52 00 01 78 10 01 
0000000100000ff0    10 0c 07 08 90 01 00 00 
</code></pre>

<h4 id="">性能上需要注意的事项</h4>

<p>从侧面来讲，<code>__DATA</code> 和 <code>__TEXT</code> segment对性能会有所影响。如果你有一个很大的二进制文件，你可能得去看看苹果的文档：<a href="https://developer.apple.com/library/mac/documentation/Performance/Conceptual/CodeFootprint/Articles/MachOOverview.html">关于代码大小性能指南</a>。将数据移至 <code>__TEXT</code> 是个不错的选择，因为这些页从来不会被改变。</p>

<h4 id="">任意的片段</h4>

<p>使用链接符号 <code>-sectcreate</code> 我们可以给可执行文件以 section 的方式添加任意的数据。这就是如何将一个 Info.plist 文件添加到一个独立的可执行文件中的方法。Info.plist 文件中的数据需要放入到 <code>__TEXT</code> segment 里面的一个 <code>__info_plist</code> section 中。可以将 <code>-sectcreate segname sectname file</code> 传递给链接器（通过将下面的内容传递给 clang）：</p>

<pre><code>-Wl,-sectcreate,__TEXT,__info_plist,path/to/Info.plist
</code></pre>

<p>同样，<code>-sectalign</code> 规定了对其方式。如果你添加的是一个全新的 segment，那么需要通过 <code>-segprot</code> 来规定 segment 的保护方式 (读/写/可执行)。这些所有内容在链接器的帮助文档中都有，例如 <code>ld(1)</code>。</p>

<p>我们可以利用定义在 <code>/usr/include/mach-o/getsect.h</code> 中的函数 <code>getsectdata()</code> 得到 section，例如 <code>getsectdata()</code> 可以得到指向 section 数据的一个指针，并返回相关 section 的长度。</p>

<h3 id="macho">Mach-O</h3>

<p>在 OS X 和 iOS 中可执行文件的格式为 <a href="https://en.wikipedia.org/wiki/Mach-o">Mach-O</a>：</p>

<pre><code>% file a.out 
a.out: Mach-O 64-bit executable x86_64
</code></pre>

<p>对于 GUI 程序也是一样的：</p>

<pre><code>% file /Applications/Preview.app/Contents/MacOS/Preview 
/Applications/Preview.app/Contents/MacOS/Preview: Mach-O 64-bit executable x86_64
</code></pre>

<p>关于 <a href="https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/MachORuntime/index.html">Mach-O 文件格式</a> 苹果有详细的介绍。</p>

<p>我们可以使用 <code>otool(1)</code> 来观察可执行文件的头部 -- 规定了这个文件是什么，以及文件是如何被加载的。通过 <code>-h</code> 可以打印出头信息：</p>

<pre><code>% otool -v -h a.out           a.out:
Mach header
      magic cputype cpusubtype  caps    filetype ncmds sizeofcmds      flags
MH_MAGIC_64  X86_64        ALL LIB64     EXECUTE    16       1296   NOUNDEFS DYLDLINK TWOLEVEL PIE
</code></pre>

<p><code>cputype</code> 和 <code>cpusubtype</code> 规定了这个可执行文件能够运行在哪些目标架构上。<code>ncmds</code> 和 <code>sizeofcmds</code> 是加载命令，可以通过 <code>-l</code> 来查看这两个加载命令：</p>

<pre><code>% otool -v -l a.out | open -f
a.out:
Load command 0
      cmd LC_SEGMENT_64
  cmdsize 72
  segname __PAGEZERO
   vmaddr 0x0000000000000000
   vmsize 0x0000000100000000
...
</code></pre>

<p>加载命令规定了文件的逻辑结构和文件在虚拟内存中的布局。<code>otool</code> 打印出的大多数信息都是源自这里的加载命令。看一下 <code>Load command 1</code> 部分，可以找到 <code>initprot r-x</code>，它规定了之前提到的保护方式：只读和可执行。</p>

<p>对于每一个 segment，以及segment 中的每个 section，加载命令规定了它们在内存中结束的位置，以及保护模式等。例如，下面是 <code>__TEXT __text</code> section 的输出内容：</p>

<pre><code>Section
  sectname __text
   segname __TEXT
      addr 0x0000000100000f30
      size 0x0000000000000037
    offset 3888
     align 2^4 (16)
    reloff 0
    nreloc 0
      type S_REGULAR
attributes PURE_INSTRUCTIONS SOME_INSTRUCTIONS
 reserved1 0
 reserved2 0
</code></pre>

<p>上面的代码将在 0x100000f30 处结束。它在文件中的偏移量为 3888。如果看一下之前 <code>xcrun otool -v -t a.out</code> 输出的反汇编代码，可以发现代码实际位置在 0x100000f30。</p>

<p>我们同样看看在可执行文件中，动态链接库是如何使用的：</p>

<pre><code>% otool -v -L a.out
a.out:
    /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 169.3.0)
    time stamp 2 Thu Jan  1 01:00:02 1970
</code></pre>

<p>上面就是我们可执行文件将要找到 <code>_printf</code> 符号的地方。</p>

<h2 id="">一个更复杂的例子</h2>

<p>我们来看看有三个文件的复杂例子：</p>

<p><code>Foo.h</code>:</p>

```objc
#import <Foundation/Foundation.h>

@interface Foo : NSObject

- (void)run;

@end
```

<p><code>Foo.m</code>:</p>

```objc
#import "Foo.h"

@implementation Foo

- (void)run
{
    NSLog(@"%@", NSFullUserName());
}

@end
```

<p><code>helloworld.m</code>:</p>

```objc
#import "Foo.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        Foo *foo = [[Foo alloc] init];
        [foo run];
        return 0;
    }
}
```

<h3 id="">编译多个文件</h3>

<p>在上面的示例中，有多个源文件。所以我们需要让 clang 对输入每个文件生成对应的目标文件：</p>

<pre><code>% xcrun clang -c Foo.m
% xcrun clang -c helloworld.m
</code></pre>

<p>我们从来不编译头文件。头文件的作用就是在被编译的实现文件中对代码做简单的共享。<code>Foo.m</code> 和 <code>helloworld.m</code> 都是通过 <code>#import</code> 语句将 <code>Foo.h</code> 文件中的内容添加到实现文件中的。</p>

<p>最终得到了两个目标文件：</p>

<pre><code>% file helloworld.o Foo.o
helloworld.o: Mach-O 64-bit object x86_64
Foo.o:        Mach-O 64-bit object x86_64
</code></pre>

<p>为了生成一个可执行文件，我们需要将这两个目标文件和 Foundation framework 链接起来：</p>

<pre><code>xcrun clang helloworld.o Foo.o -Wl,`xcrun --show-sdk-path`/System/Library/Frameworks/Foundation.framework/Foundation
</code></pre>

<p>现在可以运行我们的程序了:</p>

<pre><code>% ./a.out 
2013-11-03 18:03:03.386 a.out[8302:303] Daniel Eggert
</code></pre>

<h3 id="">符号表和链接</h3>

<p>我们这个简单的程序是将两个目标文件合并到一起的。<code>Foo.o</code> 目标文件包含了 <code>Foo</code> 类的实现，而 <code>helloworld.o</code> 目标文件包含了 <code>main()</code> 函数，以及调用/使用 <code>Foo</code> 类。</p>

<p>另外，这两个目标对象都使用了 Foundation framework。<code>helloworld.o</code> 目标文件使用了它的 autorelease pool，并间接的使用了  <code>libobjc.dylib</code> 中的 Objective-C 运行时。它需要运行时函数来进行消息的调用。<code>Foo.o</code> 目标文件也有类似的原理。</p>

<p>所有的这些东西都被形象的称之为符号。我们可以把符号看成是一些在运行时将会变成指针的东西。虽然实际上并不是这样的。</p>

<p>每个函数、全局变量和类等都是通过符号的形式来定义和使用的。当我们将目标文件链接为一个可执行文件时，链接器 (<code>ld(1)</code>) 在目标文件盒动态库之间对符号做了解析处理。</p>

<p>可执行文件和目标文件有一个符号表，这个符号表规定了它们的符号。如果我们用 <code>nm(1)</code> 工具观察一下 <code>helloworld.0</code> 目标文件，可以看到如下内容：</p>

<pre><code>% xcrun nm -nm helloworld.o
                 (undefined) external _OBJC_CLASS_$_Foo
0000000000000000 (__TEXT,__text) external _main
                 (undefined) external _objc_autoreleasePoolPop
                 (undefined) external _objc_autoreleasePoolPush
                 (undefined) external _objc_msgSend
                 (undefined) external _objc_msgSend_fixup
0000000000000088 (__TEXT,__objc_methname) non-external L_OBJC_METH_VAR_NAME_
000000000000008e (__TEXT,__objc_methname) non-external L_OBJC_METH_VAR_NAME_1
0000000000000093 (__TEXT,__objc_methname) non-external L_OBJC_METH_VAR_NAME_2
00000000000000a0 (__DATA,__objc_msgrefs) weak private external l_objc_msgSend_fixup_alloc
00000000000000e8 (__TEXT,__eh_frame) non-external EH_frame0
0000000000000100 (__TEXT,__eh_frame) external _main.eh
</code></pre>

<p>上面就是那个目标文件的所有符号。<code>_OBJC_CLASS_$_Foo</code> 是 <code>Foo</code> Objective-C 类的符号。该符号是 <em>undefined, external</em> 。<em>External</em> 的意思是指对于这个目标文件该类并不是私有的，相反，<code>non-external</code> 的符号则表示对于目标文件是私有的。我们的 <code>helloworld.o</code> 目标文件引用了类 <code>Foo</code>，不过这并没有实现它。因此符号表中将其标示为 undefined。</p>

<p>接下来是 <code>_main</code> 符号，它是表示 <code>main()</code> 函数，同样为 <em>external</em>，这是因为该函数需要被调用，所以应该为可见的。由于在 <code>helloworld.o</code> 文件中实现了 这个 main 函数。这个函数地址位于 0处，并且需要转入到  <code>__TEXT,__text</code> section。接着是 4 个 Objective-C 运行时函数。它们同样是 undefined的，需要链接器进行符号解析。</p>

<p>如果我们转而观察 <code>Foo.o</code> 目标文件，可以看到如下输出：</p>

<pre><code>% xcrun nm -nm Foo.o
0000000000000000 (__TEXT,__text) non-external -[Foo run]
                 (undefined) external _NSFullUserName
                 (undefined) external _NSLog
                 (undefined) external _OBJC_CLASS_$_NSObject
                 (undefined) external _OBJC_METACLASS_$_NSObject
                 (undefined) external ___CFConstantStringClassReference
                 (undefined) external __objc_empty_cache
                 (undefined) external __objc_empty_vtable
000000000000002f (__TEXT,__cstring) non-external l_.str
0000000000000060 (__TEXT,__objc_classname) non-external L_OBJC_CLASS_NAME_
0000000000000068 (__DATA,__objc_const) non-external l_OBJC_METACLASS_RO_$_Foo
00000000000000b0 (__DATA,__objc_const) non-external l_OBJC_$_INSTANCE_METHODS_Foo
00000000000000d0 (__DATA,__objc_const) non-external l_OBJC_CLASS_RO_$_Foo
0000000000000118 (__DATA,__objc_data) external _OBJC_METACLASS_$_Foo
0000000000000140 (__DATA,__objc_data) external _OBJC_CLASS_$_Foo
0000000000000168 (__TEXT,__objc_methname) non-external L_OBJC_METH_VAR_NAME_
000000000000016c (__TEXT,__objc_methtype) non-external L_OBJC_METH_VAR_TYPE_
00000000000001a8 (__TEXT,__eh_frame) non-external EH_frame0
00000000000001c0 (__TEXT,__eh_frame) non-external -[Foo run].eh
</code></pre>

<p>第五行至最后一行显示了 <code>_OBJC_CLASS_$_Foo</code> 已经定义了，并且对于 <code>Foo.o</code> 是一个外部符号 -- ·Foo.o· 包含了这个类的实现。</p>

<p><code>Foo.o</code> 同样有 undefined 的符号。首先是使用了符号 <code>NSFullUserName()</code>，<code>NSLog()</code>和 <code>NSObject</code>。</p>

<p>当我们将这两个目标文件和 Foundation framework (是一个动态库) 进行链接处理时，链接器会尝试解析所有的 undefined 符号。它可以解析  <code>_OBJC_CLASS_$_Foo</code>。另外，它将使用 Foundation framework。</p>

<p>当链接器通过动态库 (此处是 Foundation framework) 解析成功一个符号时，它会在最终的链接图中记录这个符号是通过动态库进行解析的。链接器会记录输出文件是依赖于哪个动态链接库，并连同其路径一起进行记录。在我们的例子中，<code>_NSFullUserName</code>，<code>_NSLog</code>，<code>_OBJC_CLASS_$_NSObject</code>，<code>_objc_autoreleasePoolPop</code> 等符号都是遵循这个过程。</p>

<p>我们可以看一下最终可执行文件 <code>a.out</code> 的符号表，并注意观察链接器是如何解析所有符号的：</p>

<pre><code>% xcrun nm -nm a.out 
                 (undefined) external _NSFullUserName (from Foundation)
                 (undefined) external _NSLog (from Foundation)
                 (undefined) external _OBJC_CLASS_$_NSObject (from CoreFoundation)
                 (undefined) external _OBJC_METACLASS_$_NSObject (from CoreFoundation)
                 (undefined) external ___CFConstantStringClassReference (from CoreFoundation)
                 (undefined) external __objc_empty_cache (from libobjc)
                 (undefined) external __objc_empty_vtable (from libobjc)
                 (undefined) external _objc_autoreleasePoolPop (from libobjc)
                 (undefined) external _objc_autoreleasePoolPush (from libobjc)
                 (undefined) external _objc_msgSend (from libobjc)
                 (undefined) external _objc_msgSend_fixup (from libobjc)
                 (undefined) external dyld_stub_binder (from libSystem)
0000000100000000 (__TEXT,__text) [referenced dynamically] external __mh_execute_header
0000000100000e50 (__TEXT,__text) external _main
0000000100000ed0 (__TEXT,__text) non-external -[Foo run]
0000000100001128 (__DATA,__objc_data) external _OBJC_METACLASS_$_Foo
0000000100001150 (__DATA,__objc_data) external _OBJC_CLASS_$_Foo
</code></pre>

<p>可以看到所有的 Foundation 和 Objective-C 运行时符号依旧是 undefined，不过现在的符号表中已经多了如何解析它们的信息，例如在哪个动态库中可以找到对应的符号。</p>

<p>可执行文件同样知道去哪里找到所需库：</p>

<pre><code>% xcrun otool -L a.out
a.out:
    /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 1056.0.0)
    /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1197.1.1)
    /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 855.11.0)
    /usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
</code></pre>

<p>在运行时，动态链接器  <code>dyld(1)</code> 可以解析这些 undefined 符号，<code>dyld</code> 将会确定好 <code>_NSFullUserName</code> 等符号，并指向它们在 Foundation 中的实现等。</p>

<p>我们可以针对 Foundation 运行 <code>nm(1)</code>，并检查这些符号的定义情况： </p>

<pre><code>% xcrun nm -nm `xcrun --show-sdk-path`/System/Library/Frameworks/Foundation.framework/Foundation | grep NSFullUserName
0000000000007f3e (__TEXT,__text) external _NSFullUserName 
</code></pre>

<h3 id="">动态链接编辑器</h3>

<p>有一些环境变量对于 <code>dyld</code> 的输出信息非常有用。首先，如果设置了 <code>DYLD_PRINT_LIBRARIES</code>，那么 <code>dyld</code> 将会打印出什么库被加载了：</p>

<pre><code>% (export DYLD_PRINT_LIBRARIES=; ./a.out )
dyld: loaded: /Users/deggert/Desktop/command_line/./a.out
dyld: loaded: /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
dyld: loaded: /usr/lib/libSystem.B.dylib
dyld: loaded: /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
dyld: loaded: /usr/lib/libobjc.A.dylib
dyld: loaded: /usr/lib/libauto.dylib
[...]
</code></pre>

<p>上面将会显示出在加载 Foundation 时，同时会加载的 70 个动态库。这是由于 Foundation 依赖于另外一些动态库。运行下面的命令：</p>

<pre><code>% xcrun otool -L `xcrun --show-sdk-path`/System/Library/Frameworks/Foundation.framework/Foundation
</code></pre>

<p>可以看到 Foundation 使用了 15 个动态库。</p>

<h3 id="dyld">dyld 的共享缓存</h3>

<p>当你构建一个真正的程序时，将会链接各种各样的库。它们又会依赖其他一些 framework 和 动态库。需要加载的动态库会非常多。而对于相互依赖的符号就更多了。可能将会有上千个符号需要解析处理，这将花费很长的时间：一般是好几秒钟。</p>

<p>为了缩短这个处理过程所花费时间，在 OS X 和 iOS 上的动态链接器使用了共享缓存，共享缓存存于 <code>/var/db/dyld/</code>。对于每一种架构，操作系统都有一个单独的文件，文件中包含了绝大多数的动态库，这些库都已经链接为一个文件，并且已经处理好了它们之间的符号关系。当加载一个 Mach-O 文件 (一个可执行文件或者一个库) 时，动态链接器首先会检查 <em>共享缓存</em> 看看是否存在其中，如果存在，那么就直接从共享缓存中拿出来使用。每一个进程都把这个共享缓存映射到了自己的地址空间中。这个方法大大优化了 OS X 和 iOS 上程序的启动时间。</p>

<hr />