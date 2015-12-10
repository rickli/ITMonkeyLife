---
layout: post
title: "iOS之玩转字符串"
date: 2014-04-09 16:40:06 +0800
comments: true
categories: [iOS]
---
 <p>在每个应用里我们都大量使用字符串。下面我们将快速看看一些常见的操作字符串的方法，过一遍常见操作的最佳实践。</p>

<h2 id="">字符串的比较、搜索和排序</h2>

<p>排序和比较字符串比第一眼看上去要复杂得多。不只是因为字符串可以包含<strong>代理对（surrogate pairs ）</strong>(详见 <a href="http://objccn.io/issue-9-1/#peculiar-unicode-features">Ole 写的这篇关于 Unicode 的文章</a>) ，而且比较还与字符串的本地化相关。在某些极端情况下相当棘手。</p>

<p>苹果文档中 <em>String Programming Guide</em> 里有一节叫做 <a href="https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Strings/Articles/stringsClusters.html"><strong>“字符与字形集群（Characters and Grapheme Clusters）”</strong></a>，里面提到一些陷阱。例如对于排序来说，一些欧洲语言将序列“ch”当作单个字母。在一些语言里，“ä”被认为等同于 ‘a’ ，而在其它语言里它却被排在 ‘z’ 后面。</p>

<p>而 <code>NSString</code> 有一些方法来帮助我们处理这种复杂性。首先看下面的方法：</p>

<pre><code>- (NSComparisonResult)compare:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(id)locale
</code></pre>

<p>它带给我们充分的灵活性。另外，还有很多<strong>便捷函数（convenience functions）</strong>都使用了这个方法。</p>

<p>与比较有关的可用参数如下：</p>

```objc
NSCaseInsensitiveSearch
NSLiteralSearch
NSNumericSearch
NSDiacriticInsensitiveSearch
NSWidthInsensitiveSearch
NSForcedOrderingSearch
```

<p>它们都可以用逻辑“或”运算符组合在一起。</p>

<p><code>NSCaseInsensitiveSearch</code>：“A”等同于“a”，然而在某些地方还有更复杂的情况。例如，在德国，“ß” 和 “SS”是等价的。</p>

<p><code>NSLiteralSearch</code>：Unicode 的点对点比较。它只在所有字符都用相同的方式组成的情况下才会返回相等（即 <code>NSOrderedSame</code>）。LATIN CAPITAL LETTER A 加上 COMBINING RING ABOVE 并不等同于 LATIN CAPITAL LETTER A WITH RING ABOVE.</p>

<blockquote>
  <p><span class="secondary radius label">编者注</span> 这里要解释一下，首先，每一个Unicode都是有官方名字的！LATIN CAPITAL LETTER A是一个大写“A”，COMBINING RING ABOVE是一个  ̊，LATIN CAPITAL LETTER A WITH RING ABOVE，这是Å。前两者的组合不等同于后者。</p>
</blockquote>

<p><code>NSNumericSearch</code>：它对字符串里的数字排序，所以 “Section 9” &lt; “Section 20” &lt; “Section 100.”</p>

<p><code>NSDiacriticInsensitiveSearch</code>：“A” 等同于 “Å” 等同于 “Ä.”</p>

<p><code>NSWidthInsensitiveSearch</code>：一些东亚文字（平假名和片假名）有全宽与半宽两种形式。</p>

<p>很值得一提的是<code>-localizedStandardCompare:</code>，它排序的方式和 Finder 一样。它对应的选项是 <code>NSCaseInsensitiveSearch</code>、<code>NSNumericSearch</code>、<code>NSWidthInsensitiveSearch</code> 以及 <code>NSForcedOrderingSearch</code>。如果我们要在 UI 上显示一个文件列表，用它就最合适不过了。</p>

<p>大小写不敏感的比较和音调符号不敏感的比较都是相对复杂和昂贵的操作。如果我们需要比较很多次字符串那这就会成为一个性能上的瓶颈（例如对一个大的数据集进行排序），一个常见的解决方法是同时存储原始字符串和折叠字符串。例如，我们的 <code>Contact</code> 类有一个正常的 <code>name</code> 属性，在内部它还有一个 <code>foldedName</code> 属性，它将自动在 name 变化时更新。那么我们就可以使用 <code>NSLiteralSearch</code> 来比较 name 的折叠版本。 <code>NSString</code> 有一个方法来创建折叠版本：</p>

```objc
- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale
```
<!-- more -->
<h3 id="">搜索</h3>

<p>要在一个字符串中搜索子字符串，最灵活性的方法是:</p>

```objc
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale
```

<p>同时，还有一些便捷方法，它们在最终都会调用上面这个方法，我们可以传入上面列出的参数，以及以下这些额外的参数：</p>

```objc
NSBackwardsSearch
NSAnchoredSearch
NSRegularExpressionSearch
```

<p><code>NSBackwardsSearch</code>：在字符串的末尾开始反向搜索。</p>

<p><code>NSAnchoredSearch</code>：只考虑搜索的起始点（单独使用）或终止点（当与 <code>NSBackwardsSearch</code> 结合使用时）。这个方法可以用来检查前缀或者后缀，以及<strong>大小写不敏感（case-insensitive）</strong>或者<strong>音调不敏感（diacritic-insensitive）</strong>的比较。</p>

<p><code>NSRegularExpressionSearch</code>：使用正则表达式搜索，要了解更多与使用正则表达式有关的信息，请关注 Chris 写的字符串解析这篇文章。</p>

<p>另外，还有一个方法：</p>

```objc
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask range:(NSRange)aRange
```

<p>与前面搜索字符串不同的是，它只搜索给定字符集的第一个字符。即使只搜索一个字符，但如果由于此字符是<strong>由元字符组成的序列（composed character sequence）</strong>，所以返回范围的长度也可能大于1。</p>

<h2 id="">大写与小写</h2>

<p>一定不要使用 <code>NSString</code> 的 <code>-uppercaseString</code> 或者 <code>-lowercaseString</code> 的方法来处理 UI 显示的字符串，而应该使用 <code>-uppercaseStringWithLocale</code> 来代替， 比如：</p>

```objc
NSString *name = @"Tómas";
cell.text = [name uppercaseStringWithLocale:[NSLocale currentLocale]];
```

<h2 id="">格式化字符串</h2>

<p>同 C 语言中的 <code>sprintf</code> 函数（ANSI C89 中的一个函数）类似，Objective C 中的 <code>NSString</code> 类也有如下的 3 个方法：</p>

```objc
-initWithFormat:
-initWithFormat:arguments:
+stringWithFormat:
```

<p>需要注意这些格式化方法都是<em>非本地化</em>的。所以这些方法得到的字符串是不能直接拿来显示在用户界面上的。如果需要本地化，那我们需要使用下面这些方法:</p>

```objc
-initWithFormat:locale:
-initWithFormat:locale:arguments:
+localizedStringWithFormat:
```

<p>Florian 有一篇关于<a href="http://objccn.io/issue-9-3/#localized-format-strings">字符串的本地化</a>的文章更详细地讨论了这个问题。</p>

<p><a href="https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/printf.3.html">printf(3)</a> 的 man 页面有关于它如何格式化字符串的全部细节。除了以 <code>%</code> 字符开始的所谓<strong>格式转换符（conversion specification）</strong>，格式化字符串会被逐字复制：</p>

```objc
double a = 25812.8074434;
float b = 376.730313461;
NSString *s = [NSString stringWithFormat:@"%g :: %g", a, b];
// "25812.8 :: 376.73"
```

<p>我们格式化了两个浮点数。注意单精度浮点数 <code>float</code> 和双精度浮点数 <code>double</code> 共同了一个格式转换符。</p>

<h3 id="">对象</h3>

<p>除了来自 <code>printf(3)</code> 的转换规范，我们还可以使用 <code>%@</code> 来输出一个对象。在<a href="#object-description">对象描述</a>那一节中有述，如果对象响应 <code>-descriptionWithLocale:</code> 方法，则调用它，否则调用 <code>-description</code>。<code>%@</code> 被结果替换。</p>

<h3 id="">整数</h3>

<p>使用整形数字时，有些需要注意的细节。首先，有符号数（<code>d</code> 和 <code>i</code>）和无符号数（<code>o</code>、<code>u</code>、<code>x</code>和<code>X</code>）的格式转换符是不一样的，需要使用者根据具体情况来选择。</p>

<p>如果我们使用 printf 支持的类型列表之外的类型，就必须要做类型转换。<code>NSUInteger</code> 正是这样一个例子，它在 64 位和 32 位平台上是不一样的。下面的例子可以同时工作在 32 位和 64 位平台上：</p>

```objc
uint64_t p = 2305843009213693951;
NSString *s = [NSString stringWithFormat:@"The ninth Mersenne prime is %llu", (unsigned long long) p];
// "The ninth Mersenne prime is 2305843009213693951"
```

<table>  
  <thead>
  <tr><th style='text-align: left'>Modifier          </th><th style='text-align: left'>d, i           </th><th style='text-align: left'>o, u, x, X</th></tr>
  </thead>
  <tbody>
  <tr><td>hh                </td><td>signed char    </td><td>unsigned char</td></tr>
  <tr><td>h                 </td><td>short          </td><td>unsigned short</td></tr>
  <tr><td>(none)            </td><td>int            </td><td>unsigned int</td></tr>
  <tr><td>l (ell)           </td><td>long           </td><td>unsigned long</td></tr>
  <tr><td>ll (ell ell)      </td><td>long long      </td><td>unsigned long long</td></tr>
  <tr><td>j                 </td><td>intmax_t       </td><td>uintmax_t</td></tr>
  <tr><td>t                 </td><td>ptrdiff_t      </td><td></td></tr>
  <tr><td>z                 </td><td>               </td><td>size_t</td></tr>
  </tbody>
</table>

<p>适用于整数的转换规则有：</p>

```objc
int m = -150004021;
uint n = 150004021U;
NSString *s = [NSString stringWithFormat:@"d:%d i:%i o:%o u:%u x:%x X:%X", m, m, n, n, n, n];
// "d:-150004021 i:-150004021 o:1074160465 u:150004021 x:8f0e135 X:8F0E135"
```

<p><code>%d</code> 和 <code>%i</code> 具有一样的功能，它们都打印出有符号十进制数。<code>%o</code> 就较为晦涩了：它使用<a href="https://en.wikipedia.org/wiki/Octal">八进制</a>表示。<code>%u</code> 输出无符号十进制数——它是我们常用的。最后 <code>%x</code> 和 <code>%X</code> 使用十六进制表示——后者使用大写字母。</p>

<p>对于 <code>x%</code> 和 <code>X%</code>，我们可以在 <code>0x</code> 前面添加 <code>#</code> 前缀，增加可读性。</p>

<p>我们可以传入特定参数，来设置最小字段宽度和最小数字位数（默认两者都是 0），以及左/右对齐。请查看 man 页面获取详细信息。下面是一些例子：</p>

```objc
int m = 42;
NSString *s = [NSString stringWithFormat:@"'%4d' '%-4d' '%+4d' '%4.3d' '%04d'", m, m, m, m, m];
// "[  42] [42  ] [ +42] [ 042] [0042]"
m = -42;
NSString *s = [NSString stringWithFormat:@"'%4d' '%-4d' '%+4d' '%4.3d' '%04d'", m, m, m, m, m];
// "[ -42] [-42 ] [ -42] [-042] [-042]"
```

<p><code>%p</code> 可用于打印出指针——它和 <code>%#x</code> 相似但可同时在 32 位和 64 位平台上正常工作。</p>

<h3 id="">浮点数</h3>

<p>浮点数的格式转符有8个：<code>eEfFgGaA</code>。但除了 <code>%f</code> 和 <code>%g</code> 外我们很少使用其它的。对于指数部分，小写的版本使用小写 <code>e</code>，大写的版本就使用大写 <code>E</code>。</p>

<p>通常 <code>%g</code> 是浮点数的全能转换符 ，它与 <code>%f</code> 的不同在下面的例子里显示得很清楚：</p>

```objc
double v[5] = {12345, 12, 0.12, 0.12345678901234, 0.0000012345678901234};
NSString *s = [NSString stringWithFormat:@"%g %g %g %g %g", v[0], v[1], v[2], v[3], v[4]];
// "12345 12 0.12 0.123457 1.23457e-06"
NSString *s = [NSString stringWithFormat:@"%f %f %f %f %f", v[0], v[1], v[2], v[3], v[4]];
// "12345.000000 12.000000 0.120000 0.123457 0.000001"
```

<p>和整数一样，我们依然可以指定最小字段宽度和最小数字数。</p>

<h3 id="">指定位置</h3>

<p>格式化字符串允许使用参数来改变顺序：</p>

<p>[NSString stringWithFormat:@"%2$@ %1$@", @"1st", @"2nd"];</p>

<p>// "2nd 1st"</p>

<p>我们只需将从 1 开始的参数与一个 <code>$</code> 接在 <code>%</code> 后面。这种写法在进行本地化的时候极其常见，因为在不同语言中，各个参数所处的顺序位置可能不尽相同。</p>

<h3 id="nslog">NSLog()</h3>

<p><code>NSLog()</code> 函数与 <code>+stringWithFormat:</code> 的工作方式一样。我们可以调用：</p>

```objc
int magic = 42;
NSLog(@"The answer is %d", magic);
```

<p>下面的代码可以用同样的方式构造字符串：</p>

```objc
int magic = 42;
NSString *output = [NSString stringWithFormat:@"The answer is %d", magic];
```

<p>显然 <code>NSLog()</code> 会输出字符串，并且它会加上时间戳、进程名、进程 ID 以及线程 ID 作为前缀。</p>

<h3 id="">实现能接受格式化字符串的方法</h3>

<p>有时在我们自己的类中提供一个能接受格式化字符串的方法会很方便使用。假设我们要实现的是一个 To Do 类的应用，它包含一个  <code>Item</code> 类。我们想要提供：</p>

```objc
+ (instancetype)itemWithTitleFormat:(NSString *)format, ...
```

<p>如此我们就可以使用：</p>

```objc
Item *item = [Item itemWithFormat:@"Need to buy %@ for %@", food, pet];
```

<p>这种类型的方法接受可变数量的参数，所以被称为可变参数方法。我们必须使用一个定义在 <code>stdarg.h</code> 里的宏来使用可变参数。上面方法的实现代码可能会像下面这样：</p>

```objc
+ (instancetype)itemWithTitleFormat:(NSString *)format, ...;
{
    va_list ap;
    va_start(ap, format);
    NSString *title = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    return [self itemWithTitle:title];
}
```

<p>进一步，我们要添加 <code>NS_FORMAT_FUNCTION</code> 到方法的定义里（即头文件中），如下所示：</p>

```objc
+ (instancetype)itemWithTitleFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
```

<p><code>NS_FORMAT_FUNCTION</code> 展开为一个方法 <code>__attribute__</code>，它会告诉编译器在索引 <strong>1</strong> 处的参数是一个格式化字符串，而实际参数从索引 <strong>2</strong> 开始。这将允许编译器检查格式化字符串而且会像 <code>NSLog()</code> 和 <code>-[NSString stringWithFormat:]</code> 一样输出警告信息。</p>

<h2 id="">字符与字符串组件</h2>

<p>如有一个字符串 “bird” ，找出组成它的独立字母是很简单的。第二个字母是“i”（Unicode: LATIN SMALL LETTER I）。而对于像<a href="https://en.wikipedia.org/wiki/Åse">Åse</a>这样的字符串就没那么简单了。看起来像三个字母的组合可有多种方式，例如：</p>

<pre><code>A    LATIN CAPITAL LETTER A
 ̊    COMBINING RING ABOVE
s    LATIN SMALL LETTER S
e    LATIN SMALL LETTER E
</code></pre>

<p>或者</p>

<pre><code>Å    LATIN CAPITAL LETTER A WITH RING ABOVE
s    LATIN SMALL LETTER S
e    LATIN SMALL LETTER E
</code></pre>

<p>从 <a href="http://objccn.io/issue-9-1/#peculiar-unicode-features">Ole 写的这篇关于 Unicode 的文章</a> 里可以读到更多关于<strong>联合标记（combining marks）</strong>的信息，其他语言文字有更多复杂的<strong>代理对（complicated surrogate pairs）</strong>。</p>

<p>如果我们要在字符层面处理一个字符串，那我们就要小心翼翼。苹果的文档中 String Programming Guide 里有一节叫做 <a href="https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Strings/Articles/stringsClusters.html">“Characters and Grapheme Clusters”</a>，里面有更多关于这一点的细节。</p>

<p><code>NSString</code> 有两个方法：</p>

```objc
-rangeOfComposedCharacterSequencesForRange:
-rangeOfComposedCharacterSequenceAtIndex:
```

<p>上面这两个方法在有的时候很有帮助，例如，拆分一个字符串时保证我们不会把所谓的<strong>代理对（surrogate pairs）</strong>拆散。</p>

<p>如果我们要针对字符串中的字符做文章， NSString 提供了下面这个方法：</p>

```objc
-enumerateSubstringsInRange:options:usingBlock:
```

<p>options 这里传入 <code>NSStringEnumerationByComposedCharacterSequences</code> 这个参数，就可以扫描所有的字符。例如，用下面的方法，我们可将字符串 “International Business Machines” 变成 “IBM”：</p>

```objc
- (NSString *)initials;
{
    NSMutableString *result = [NSMutableString string];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords | NSStringEnumerationLocalized usingBlock:^(NSString *word, NSRange wordRange, NSRange enclosingWordRange, BOOL *stop1) {
        __block NSString *firstLetter = nil;
          [self enumerateSubstringsInRange:NSMakeRange(0, word.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *letter, NSRange letterRange, NSRange enclosingLetterRange, BOOL *stop2) {
              firstLetter = letter;
              *stop2 = YES;
          }];
          if (firstLetter != nil) {
              [result appendString:firstLetter];
        };
    }];
    return result;
}
```

<p>如文档所示，词和句的分界可能基于地区的变化而变化。因此有 <code>NSStringEnumerationLocalized</code> 这个选项。</p>

<h2 id="">多行文字字面量</h2>

<p>编译器的确有一个隐蔽的特性：把空格分隔开的字符串衔接到一起。这是什么意思呢？这段代码：</p>

```objc
NSString *limerick = @"A lively young damsel named Menzies\n"
@"Inquired: «Do you know what this thenzies?»\n"
@"Her aunt, with a gasp,\n"
@"Replied: "It's a wasp,\n"
@"And you're holding the end where the stenzies.\n";
```

<p>与下面这段代码是完全等价的：</p>

```objc
NSString *limerick = @"A lively young damsel named Menzies\nInquired: «Do you know what this thenzies?»\nHer aunt, with a gasp,\nReplied: "It's a wasp,\nAnd you're holding the end where the stenzies.\n";
```

<p>前者看起来更舒服，但是有一点要注意：千万不要在任意一行末尾加入逗号或者分号。</p>

<p>你也可以这样做：</p>

```objc
NSString * string = @"The man " @"who knows everything " @"learns nothing" @".";
```

<p>编译器只是为我们提供了一个便捷的方式，将多个字符串在编译期组合在了一起。</p>

<h2 id="">可变字符串</h2>

<p>可变字符串有两个常见的使用场景：（1）拼接字符串（2）替换子字符串</p>

<h3 id="">拼接字符串</h3>

<p>可变字符串可以很轻易地把多个字符串按照你的需要组合起来。</p>

```objc
- (NSString *)magicToken
{
    NSMutableString *string = [NSMutableString string];
    if (usePrefix) {
        [string appendString:@"&gt;&gt;&gt;"];
    }
    [string appendFormat:@"%d--%d", self.foo, self.bar];
    if (useSuffix) {
        [string appendString:@"&gt;&gt;&gt;"];
    }
    return string;
}
```

<p>这里要注意的是，虽然原本返回值应该是一个 <code>NSString</code> 类型的对象，我们在这里只是简单地返回一个 <code>NSMutableString</code> 类型的对象。</p>

<h3 id="">替换子字符串</h3>

<p>除了追加组合之外，<code>NSMutableString</code> 还提供了以下4个方法：</p>

```objc
-deleteCharactersInRange:
-insertString:atIndex:
-replaceCharactersInRange:withString:
-replaceOccurrencesOfString:withString:options:range:
```

<p><code>NSString</code> 也有类似的方法：</p>

```objc
-stringByReplacingOccurrencesOfString:withString:
-stringByReplacingOccurrencesOfString:withString:options:range:
-stringByReplacingCharactersInRange:withString:
```

<p>但是 <code>NSMutableString</code> 的那些方法不会创建新的字符串，而仅仅改变当前字符串。这样会让代码更容易阅读，有时也会提升一些性能。</p>

```objc
NSMutableString *string; // 假设我们已经有了一个名为 string 的字符串
// 现在要去掉它的一个前缀，做法如下:
NSString *prefix = @"WeDon’tWantThisPrefix"
NSRange r = [string rangeOfString:prefix options:NSAnchoredSearch range:NSMakeRange(0, string.length) locale:nil];
if (r.location != NSNotFound) {
    [string deleteCharactersInRange:r];
}
```

<h2 id="">连接组件</h2>

<p>一个看似微不足道但很常见的情况是字符串连接。比如现在有这样几个字符串：</p>

<pre><code>Hildr
Heidrun
Gerd
Guðrún
Freya
Nanna
Siv
Skaði
Gróa
</code></pre>

<p>我们想用它们来创建下面这样的一个字符串：</p>

<pre><code>Hildr, Heidrun, Gerd, Guðrún, Freya, Nanna, Siv, Skaði, Gróa
</code></pre>

<p>那么就可以这样做：</p>

```objc
NSArray *names = @["Hildr", @"Heidrun", @"Gerd", @"Guðrún", @"Freya", @"Nanna", @"Siv", @"Skaði", @"Gróa"];
NSString *result = [names componentsJoinedByString:@", "];
```

<p>如果我们将其显示给用户，我们就要使用本地化表达，确保将最后一部分替换相应语言的 “, and” ：</p>

```
@implementation NSArray (ObjcIO_GroupedComponents)

- (NSString *)groupedComponentsWithLocale:(NSLocale *)locale;
{
    if (self.count &lt; 1) {
        return @"";
    } else if (self.count &lt; 2) {
        return self[0];
    } else if (self.count &lt; 3) {
        NSString *joiner = NSLocalizedString(@"joiner.2components", @"");
        return [NSString stringWithFormat:@"%@%@%@", self[0], joiner, self[1]];
    } else {
        NSString *joiner = [NSString stringWithFormat:@"%@ ", [locale objectForKey:NSLocaleGroupingSeparator]];
        NSArray *first = [self subarrayWithRange:NSMakeRange(0, self.count - 1)];
        NSMutableString *result = [NSMutableString stringWithString:[first componentsJoinedByString:joiner]];

        NSString *lastJoiner = NSLocalizedString(@"joiner.3components", @"");
        [result appendString:lastJoiner];
        [result appendString:self.lastObject];
        return result;
    }
}

@end
```

<p>那么在本地化的时候，如果是英语，应该是：</p>

<pre><code>"joiner.2components" = " and ";
"joiner.3components" = ", and ";
</code></pre>

<p>如果是德语，则应该是：</p>

<pre><code>"joiner.2components" = " und ";
"joiner.3components" = " und ";
</code></pre>

<p>结合组件的逆过程可以用 <code>-componentsSeparatedByString:</code>，这个方法会将字符串变成一个数组。例如，将 “12|5|3” 变成 “12”、“5” 和 “3”。</p>

<p><a name="object-description"> </a>  </p>

<h2 id="">对象描述</h2>

<p>在许多面向对象编程语言里，对象有一个叫做 <code>toString()</code> 或类似的方法。在 Objective C 里，这个方法是：</p>

```objc
- (NSString *)description
```

<p>以及它的兄弟方法:</p>

```objc
- (NSString *)debugDescription
```

<p>当自定义模型对象时，覆写 <code>-description</code> 方法是一个好习惯，在 UI 上显示该对象时调用的就是该方法的返回值。假定我们有一个 <code>Contact</code> 类，下面是它的 <code>-description</code> 方法的实现：</p>

```objc
- (NSString *)description
{
    return self.name;
}
```

<p>我们可以像下面代码这样格式化字符串：</p>

```objc
label.text = [NSString stringWithFormat:NSLocalizedString(@"%@ has been added to the group “%@”.", @""), contact, group];
```

<p>因为该字符串是用来做 UI 显示的，我们可能需要做本地化，那么我们就需要覆写下面这个方法：</p>

```objc
- (NSString *)descriptionWithLocale:(NSLocale *)locale;
```

<p>格式转换符 <code>%@</code> 会首先调用 <code>-descriptionWithLocale</code>，如果没有返回值，再调用 <code>-description</code>。</p>

<p>在调试时，打印一个对象，我们用 <code>po</code> 这个命令（它是 print object 的缩写）：</p>

<pre><code>(lldb) po contact
</code></pre>

<p>它会调用对象的 <code>debugDescription</code> 方法。默认情况下 <code>debugDescription</code> 是直接调用 <code>description</code>。如果你希望输出不同的信息，那么就分别覆写两个方法。大多数情况下，尤其是对于非数据模型的对象，你只需要覆写 <code>-description</code> 就能满足需求了。</p>

<p>实际上对象的标准格式化输出是这样的：</p>

```objc
- (NSString *)description;
{
    return [NSString stringWithFormat:@"&lt;%@: %p&gt;", self.class, self];
}
```

<p><code>NSObject</code> 这个类内部就是这么实现的。当你覆写该方法时，也可以像这样写。假定我们有一个 <code>DetailViewController</code>，在它的UI上要显示一个 <code>contact</code>，我们可能会这样覆写该方法：</p>

```objc
- (NSString *)description;
{
    return [NSString stringWithFormat:@"&lt;%@: %p&gt; contact = %@", self.class, self, self.contact.debugDescription];
}
```

<h3 id="nsmanagedobject"><code>NSManagedObject</code> 子类的描述</h3>

<p>我们将特别注意向 <code>NSManagedObject</code> 的子类添加 <code>-description</code>/<code>-debugDescription</code> 的情况。由于 Core Data 的<strong>惰性加载机制（faulting mechanism）</strong>允许未加载数据的对象存在，所以当我们调用 <code>-debugDescription</code> 时我们并不希望改变应用程序的状态，因此需要检查 <code>isFault</code> 这个属性。例如，我们可如下这样实现它：</p>

```objc
- (NSString *)debugDescription;
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"&lt;%@: %p&gt;", self.class, self];
    if (! self.isFault) {
        [description appendFormat:@" %@ \"%@\" %gL", self.identifier, self.name, self.metricVolume];
    }
    return description;
}
```

<p>再次，因为它们是模型对象，重载 <code>-description</code> 简单地返回描述实例的属性名就可以了。</p>

<h3 id="">文件路径</h3>

<p>简单来说就是我们不应该使用 <code>NSString</code> 来描述文件路径。对于 OS X 10.7 和 iOS 5，<code>NSURL</code> 更便于使用，而且更有效率，它还能缓存文件系统的属性。</p>

<p>再者，<code>NSURL</code> 有八个方法来访问被称为 <em>resource values</em> 的东西。这些方法提供了一个稳定的接口，使我们可以用来获取和设置文件与目录的各种属性，例如本地化文件名（<code>NSURLLocalizedNameKey</code>）、文件大小（<code>NSURLFileSizeKey</code>），以及创建日期（<code>NSURLCreationDateKey</code>），等等。</p>

<p>尤其是在遍历目录内容时，使用 
<code>-[NSFileManager </p>enumeratorAtURL:includingPropertiesForKeys:options:errorHandler:]</code>，并传入一个<strong>关键词（keys）</strong>列表，然后用 <code>-getResourceValue:forKey:error:</code> 检索它们，能带来显著的性能提升。

<p>下面是一个简短的例子展示了如何将它们组合在一起：</p>

```objc
NSError *error = nil;
NSFileManager *fm = [[NSFileManager alloc] init];
NSURL *documents = [fm URLForDirectory:NSDocumentationDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&amp;error];
NSArray *properties = @[NSURLLocalizedNameKey, NSURLCreationDateKey];
NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:documents
                                includingPropertiesForKeys:properties
                                                   options:0
                                              errorHandler:nil];
for (NSURL *fileURL in dirEnumerator) {
    NSString *name = nil;
    NSDate *creationDate = nil;
    if ([fileURL getResourceValue:&amp;name forKey:NSURLLocalizedNameKey error:NULL] &amp;&amp;
        [fileURL getResourceValue:&amp;creationDate forKey:NSURLCreationDateKey error:NULL])
    {
        NSLog(@"'%@' was created at %@", name, creationDate);
    }
}
```

<p>我们把属性的键传给 <code>-enumeratorAtURL:...</code> 方法中，在遍历目录内容时，这个方法能确保用非常高效的方式获取它们。在循环中，调用 <code>-getResourceValue:...</code> 能简单地从 <code>NSURL</code> 得到已缓存的值，而不用去访问文件系统。</p>

<h2 id="unixapi">传递路径到 UNIX API</h2>

<p>因为 Unicode 非常复杂，同一个字母有多种表示方式，所以我们在传递路径给 UNIX API 时需要非常小心。在这些情况里，一定不能使用 <code>UTF8String</code>，正确的做法是使用 <code>-fileSystemRepresentation</code> 这个方法，如下：</p>

```objc
NSURL *documentURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
documentURL = [documentURL URLByAppendingPathComponent:name];
int fd = open(documentURL.fileSystemRepresentation, O_RDONLY);
```

<p>与 <code>NSURL</code> 类似，同样的情况也发生在 <code>NSString</code> 上。如果我们不这么做，在打开一个文件名或路径名包含合成字符的文件时我们将看到随机错误。在 OS X 上，当用户的短名刚好包含合成字符时就会显得特别糟糕，比如 <code>tómas</code>。</p>

<p>有时我们可能需要路径是一个不可变的常量，即 <code>char const *</code>，一个常见的例子就是 UNIX 的 <code>open()</code> 和 <code>close()</code> 指令。但这种需求也可能发生在使用 GCD / libdispatch 的 I/O API 上。</p>

```objc
dispatch_io_t
dispatch_io_create_with_path(dispatch_io_type_t type,
    const char *path, int oflag, mode_t mode,
    dispatch_queue_t queue,
    void (^cleanup_handler)(int error));
```

<p>如果我们要使用 <code>NSString</code> 来做这件事，那我们要保证像下面这样做：</p>

```objc
NSString *path = ... // 假设这个字符串已经存在
io = dispatch_io_create_with_path(DISPATCH_IO_STREAM,
    path.fileSystemRepresentation,
    O_RDONLY, 0, queue, cleanupHandler);
```

<p><code>-fileSystemRepresentation</code> 所做的是它首先将这个字符串转换成文件系统的<a href="http://objccn.io/issue-9-1/#normalization-forms">规范形式</a>然后用 UTF-8 编码。</p>

<hr />