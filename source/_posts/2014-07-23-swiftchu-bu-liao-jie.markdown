---
layout: post
title: "Swift初步了解"
date: 2014-07-23 17:35:44 +0800
comments: true
categories: [Swift]
---
<div class="entry-content"><h2>关于</h2>

<p>这篇文章简要介绍了苹果于<a href="https://developer.apple.com/wwdc/">WWDC 2014</a>发布的编程语言——Swift。</p>

<p>原文作者：</p>

<ul>
<li><a href="http://zh.lucida.me/">Lucida Blog</a></li>
<li><a href="http://www.weibo.com/pegong/">新浪微博</a></li>
<li><a href="http://www.douban.com/people/figure9/">豆瓣</a></li>
</ul>


<p>转载前请保留出处链接，谢谢。</p>

<h2>前言</h2>

<p>在这里我认为有必要提一下<a href="http://worrydream.com/">Bret Victor</a>的<a href="http://vimeo.com/36579366">Inventing on Principle</a>，Swift编程环境的大部分概念都源自于<a href="http://worrydream.com/">Bret</a>这个演讲。</p>

<p>接下来进入正题。</p>

<h2>Swift是什么？</h2>

<p>Swift是苹果于WWDC 2014发布的编程语言，这里引用<strong><a href="https://itunes.apple.com/gb/book/swift-programming-language/id881256329?mt=11">The Swift Programming Language</a></strong>的原话：</p>

<blockquote><p>Swift is a new programming language for iOS and OS X apps that builds on the best of C and Objective-C, without the constraints of C compatibility.</p>

<p>Swift adopts safe programming patterns and adds modern features to make programming easier, more flexible and more fun.</p>

<p>Swift&rsquo;s clean slate, backed by the mature and much-loved Cocoa and Cocoa Touch frameworks, is an opportunity to imagine how software development works.</p>

<p>Swift is the first industrial-quality systems programming language that is as expressive and enjoyable as a scripting language.</p></blockquote>

<p>简单的说：</p>

<ol>
<li>Swift用来写iOS和OS X程序。（估计也不会支持其它屌丝系统）</li>
<li>Swift吸取了C和Objective-C的优点，且更加强大易用。</li>
<li>Swift可以使用现有的Cocoa和Cocoa Touch框架。</li>
<li>Swift兼具编译语言的高性能（Performance）和脚本语言的交互性（Interactive）。</li>
</ol>


<h2>Swift语言概览</h2>

<!-- more -->


<h3>基本概念</h3>

<p>注：这一节的代码源自<strong><a href="https://itunes.apple.com/gb/book/swift-programming-language/id881256329?mt=11">The Swift Programming Language</a></strong>中的<em>A Swift Tour</em>。</p>

<h4>Hello, world</h4>

<p>类似于脚本语言，下面的代码即是一个完整的Swift程序。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">println</span><span class="p">(</span><span class="s">&quot;Hello, world&quot;</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<h4>变量与常量</h4>

<p>Swift使用<code>var</code>声明变量，<code>let</code>声明常量。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">myVariable</span> <span class="p">=</span> <span class="m">42</span>
</span><span class='line'><span class="n">myVariable</span> <span class="p">=</span> <span class="m">50</span>
</span><span class='line'><span class="n">let</span> <span class="n">myConstant</span> <span class="p">=</span> <span class="m">42</span>
</span></code></pre></td></tr></table></div></figure>


<h4>类型推导</h4>

<p>Swift支持类型推导（Type Inference），所以上面的代码不需指定类型，如果需要指定类型：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">explicitDouble</span> <span class="p">:</span> <span class="n">Double</span> <span class="p">=</span> <span class="m">70</span>
</span></code></pre></td></tr></table></div></figure>


<p>Swift不支持隐式类型转换（Implicitly casting），所以下面的代码需要显式类型转换（Explicitly casting）：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">label</span> <span class="p">=</span> <span class="s">&quot;The width is &quot;</span>
</span><span class='line'><span class="n">let</span> <span class="n">width</span> <span class="p">=</span> <span class="m">94</span>
</span><span class='line'><span class="n">let</span> <span class="n">labelWidth</span> <span class="p">=</span> <span class="n">label</span> <span class="p">+</span> <span class="n">String</span><span class="p">(</span><span class="n">width</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<h4>字符串格式化</h4>

<p>Swift使用<code>\(item)</code>的形式进行字符串格式化：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">apples</span> <span class="p">=</span> <span class="m">3</span>
</span><span class='line'><span class="n">let</span> <span class="n">oranges</span> <span class="p">=</span> <span class="m">5</span>
</span><span class='line'><span class="n">let</span> <span class="n">appleSummary</span> <span class="p">=</span> <span class="s">&quot;I have \(apples) apples.&quot;</span>
</span><span class='line'><span class="n">let</span> <span class="n">fruitSummary</span> <span class="p">=</span> <span class="s">&quot;I have \(apples + oranges) pieces of fruit.&quot;</span>
</span></code></pre></td></tr></table></div></figure>


<h3>数组和字典</h3>

<p>Swift使用<code>[]</code>操作符声明数组（array）和字典（dictionary）：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">shoppingList</span> <span class="p">=</span> <span class="p">[</span><span class="s">&quot;catfish&quot;</span><span class="p">,</span> <span class="s">&quot;water&quot;</span><span class="p">,</span> <span class="s">&quot;tulips&quot;</span><span class="p">,</span> <span class="s">&quot;blue paint&quot;</span><span class="p">]</span>
</span><span class='line'><span class="n">shoppingList</span><span class="p">[</span><span class="m">1</span><span class="p">]</span> <span class="p">=</span> <span class="s">&quot;bottle of water&quot;</span>
</span><span class='line'>
</span><span class='line'><span class="kt">var</span> <span class="n">occupations</span> <span class="p">=</span> <span class="p">[</span>
</span><span class='line'>    <span class="s">&quot;Malcolm&quot;</span><span class="p">:</span> <span class="s">&quot;Captain&quot;</span><span class="p">,</span>
</span><span class='line'>    <span class="s">&quot;Kaylee&quot;</span><span class="p">:</span> <span class="s">&quot;Mechanic&quot;</span><span class="p">,</span>
</span><span class='line'><span class="p">]</span>
</span><span class='line'><span class="n">occupations</span><span class="p">[</span><span class="s">&quot;Jayne&quot;</span><span class="p">]</span> <span class="p">=</span> <span class="s">&quot;Public Relations&quot;</span>
</span></code></pre></td></tr></table></div></figure>


<p>一般使用初始化器（initializer）语法创建空数组和空字典：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">emptyArray</span> <span class="p">=</span> <span class="n">String</span><span class="p">[]()</span>
</span><span class='line'><span class="n">let</span> <span class="n">emptyDictionary</span> <span class="p">=</span> <span class="n">Dictionary</span><span class="p">&lt;</span><span class="n">String</span><span class="p">,</span> <span class="n">Float</span><span class="p">&gt;()</span>
</span></code></pre></td></tr></table></div></figure>


<p>如果类型信息已知，则可以使用<code>[]</code>声明空数组，使用<code>[:]</code>声明空字典。</p>

<h3>控制流</h3>

<h4>概览</h4>

<p>Swift的条件语句包含<code>if</code>和<code>switch</code>，循环语句包含<code>for-in</code>、<code>for</code>、<code>while</code>和<code>do-while</code>，循环/判断条件不需要括号，但循环/判断体（body）必需括号：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">individualScores</span> <span class="p">=</span> <span class="p">[</span><span class="m">75</span><span class="p">,</span> <span class="m">43</span><span class="p">,</span> <span class="m">103</span><span class="p">,</span> <span class="m">87</span><span class="p">,</span> <span class="m">12</span><span class="p">]</span>
</span><span class='line'><span class="kt">var</span> <span class="n">teamScore</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'><span class="k">for</span> <span class="n">score</span> <span class="k">in</span> <span class="n">individualScores</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">if</span> <span class="n">score</span> <span class="p">&gt;</span> <span class="m">50</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">teamScore</span> <span class="p">+=</span> <span class="m">3</span>
</span><span class='line'>    <span class="p">}</span> <span class="k">else</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">teamScore</span> <span class="p">+=</span> <span class="m">1</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<h4>可空类型</h4>

<p>结合<code>if</code>和<code>let</code>，可以方便的处理可空变量（nullable variable）。对于空值，需要在类型声明后添加<code>?</code>显式标明该类型可空。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">optionalString</span><span class="p">:</span> <span class="n">String</span><span class="p">?</span> <span class="p">=</span> <span class="s">&quot;Hello&quot;</span>
</span><span class='line'><span class="n">optionalString</span> <span class="p">==</span> <span class="n">nil</span>
</span><span class='line'>
</span><span class='line'><span class="kt">var</span> <span class="n">optionalName</span><span class="p">:</span> <span class="n">String</span><span class="p">?</span> <span class="p">=</span> <span class="s">&quot;John Appleseed&quot;</span>
</span><span class='line'><span class="kt">var</span> <span class="n">gretting</span> <span class="p">=</span> <span class="s">&quot;Hello!&quot;</span>
</span><span class='line'><span class="k">if</span> <span class="n">let</span> <span class="n">name</span> <span class="p">=</span> <span class="n">optionalName</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">gretting</span> <span class="p">=</span> <span class="s">&quot;Hello, \(name)&quot;</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<h4>灵活的switch</h4>

<p>Swift中的<code>switch</code>支持各种各样的比较操作：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">vegetable</span> <span class="p">=</span> <span class="s">&quot;red pepper&quot;</span>
</span><span class='line'><span class="k">switch</span> <span class="n">vegetable</span> <span class="p">{</span>
</span><span class='line'><span class="k">case</span> <span class="s">&quot;celery&quot;</span><span class="p">:</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">vegetableComment</span> <span class="p">=</span> <span class="s">&quot;Add some raisins and make ants on a log.&quot;</span>
</span><span class='line'><span class="k">case</span> <span class="s">&quot;cucumber&quot;</span><span class="p">,</span> <span class="s">&quot;watercress&quot;</span><span class="p">:</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">vegetableComment</span> <span class="p">=</span> <span class="s">&quot;That would make a good tea sandwich.&quot;</span>
</span><span class='line'><span class="k">case</span> <span class="n">let</span> <span class="n">x</span> <span class="k">where</span> <span class="n">x</span><span class="p">.</span><span class="n">hasSuffix</span><span class="p">(</span><span class="s">&quot;pepper&quot;</span><span class="p">):</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">vegetableComment</span> <span class="p">=</span> <span class="s">&quot;Is it a spicy \(x)?&quot;</span>
</span><span class='line'><span class="k">default</span><span class="p">:</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">vegetableComment</span> <span class="p">=</span> <span class="s">&quot;Everything tastes good in soup.&quot;</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<h4>其它循环</h4>

<p><code>for-in</code>除了遍历数组也可以用来遍历字典：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">interestingNumbers</span> <span class="p">=</span> <span class="p">[</span>
</span><span class='line'>    <span class="s">&quot;Prime&quot;</span><span class="p">:</span> <span class="p">[</span><span class="m">2</span><span class="p">,</span> <span class="m">3</span><span class="p">,</span> <span class="m">5</span><span class="p">,</span> <span class="m">7</span><span class="p">,</span> <span class="m">11</span><span class="p">,</span> <span class="m">13</span><span class="p">],</span>
</span><span class='line'>    <span class="s">&quot;Fibonacci&quot;</span><span class="p">:</span> <span class="p">[</span><span class="m">1</span><span class="p">,</span> <span class="m">1</span><span class="p">,</span> <span class="m">2</span><span class="p">,</span> <span class="m">3</span><span class="p">,</span> <span class="m">5</span><span class="p">,</span> <span class="m">8</span><span class="p">],</span>
</span><span class='line'>    <span class="s">&quot;Square&quot;</span><span class="p">:</span> <span class="p">[</span><span class="m">1</span><span class="p">,</span> <span class="m">4</span><span class="p">,</span> <span class="m">9</span><span class="p">,</span> <span class="m">16</span><span class="p">,</span> <span class="m">25</span><span class="p">],</span>
</span><span class='line'><span class="p">]</span>
</span><span class='line'><span class="kt">var</span> <span class="n">largest</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'><span class="k">for</span> <span class="p">(</span><span class="n">kind</span><span class="p">,</span> <span class="n">numbers</span><span class="p">)</span> <span class="k">in</span> <span class="n">interestingNumbers</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">for</span> <span class="n">number</span> <span class="k">in</span> <span class="n">numbers</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">if</span> <span class="n">number</span> <span class="p">&gt;</span> <span class="n">largest</span> <span class="p">{</span>
</span><span class='line'>            <span class="n">largest</span> <span class="p">=</span> <span class="n">number</span>
</span><span class='line'>        <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">largest</span>
</span></code></pre></td></tr></table></div></figure>


<p><code>while</code>循环和<code>do-while</code>循环：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">n</span> <span class="p">=</span> <span class="m">2</span>
</span><span class='line'><span class="k">while</span> <span class="n">n</span> <span class="p">&lt;</span> <span class="m">100</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">n</span> <span class="p">=</span> <span class="n">n</span> <span class="p">*</span> <span class="m">2</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">n</span>
</span><span class='line'>
</span><span class='line'><span class="kt">var</span> <span class="n">m</span> <span class="p">=</span> <span class="m">2</span>
</span><span class='line'><span class="k">do</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">m</span> <span class="p">=</span> <span class="n">m</span> <span class="p">*</span> <span class="m">2</span>
</span><span class='line'><span class="p">}</span> <span class="k">while</span> <span class="n">m</span> <span class="p">&lt;</span> <span class="m">100</span>
</span><span class='line'><span class="n">m</span>
</span></code></pre></td></tr></table></div></figure>


<p>Swift支持传统的<code>for</code>循环，此外也可以通过结合<code>..</code>（生成一个区间）和<code>for-in</code>实现同样的逻辑。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">firstForLoop</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'><span class="k">for</span> <span class="n">i</span> <span class="k">in</span> <span class="m">0.</span><span class="p">.</span><span class="m">3</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">firstForLoop</span> <span class="p">+=</span> <span class="n">i</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">firstForLoop</span>
</span><span class='line'>
</span><span class='line'><span class="kt">var</span> <span class="n">secondForLoop</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'><span class="k">for</span> <span class="kt">var</span> <span class="n">i</span> <span class="p">=</span> <span class="m">0</span><span class="p">;</span> <span class="n">i</span> <span class="p">&lt;</span> <span class="m">3</span><span class="p">;</span> <span class="p">++</span><span class="n">i</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">secondForLoop</span> <span class="p">+=</span> <span class="m">1</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">secondForLoop</span>
</span></code></pre></td></tr></table></div></figure>


<p>注意：Swift除了<code>..</code>还有<code>...</code>：<code>..</code>生成前闭后开的区间，而<code>...</code>生成前闭后闭的区间。</p>

<h3>函数和闭包</h3>

<h4>函数</h4>

<p>Swift使用<code>func</code>关键字声明函数：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">greet</span><span class="p">(</span><span class="n">name</span><span class="p">:</span> <span class="n">String</span><span class="p">,</span> <span class="n">day</span><span class="p">:</span> <span class="n">String</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">return</span> <span class="s">&quot;Hello \(name), today is \(day).&quot;</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">greet</span><span class="p">(</span><span class="s">&quot;Bob&quot;</span><span class="p">,</span> <span class="s">&quot;Tuesday&quot;</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<p>通过元组（Tuple）返回多个值：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">getGasPrices</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="p">(</span><span class="n">Double</span><span class="p">,</span> <span class="n">Double</span><span class="p">,</span> <span class="n">Double</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">return</span> <span class="p">(</span><span class="m">3.59</span><span class="p">,</span> <span class="m">3.69</span><span class="p">,</span> <span class="m">3.79</span><span class="p">)</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">getGasPrices</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>支持带有变长参数的函数：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">sumOf</span><span class="p">(</span><span class="n">numbers</span><span class="p">:</span> <span class="n">Int</span><span class="p">...)</span> <span class="p">-&gt;</span> <span class="n">Int</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">sum</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'>    <span class="k">for</span> <span class="n">number</span> <span class="k">in</span> <span class="n">numbers</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">sum</span> <span class="p">+=</span> <span class="n">number</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">sum</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">sumOf</span><span class="p">()</span>
</span><span class='line'><span class="n">sumOf</span><span class="p">(</span><span class="m">42</span><span class="p">,</span> <span class="m">597</span><span class="p">,</span> <span class="m">12</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<p>函数也可以嵌套函数：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">returnFifteen</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">Int</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">y</span> <span class="p">=</span> <span class="m">10</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">add</span><span class="p">()</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">y</span> <span class="p">+=</span> <span class="m">5</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">add</span><span class="p">()</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">y</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">returnFifteen</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>作为头等对象，函数既可以作为返回值，也可以作为参数传递：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">makeIncrementer</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="p">(</span><span class="n">Int</span> <span class="p">-&gt;</span> <span class="n">Int</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">addOne</span><span class="p">(</span><span class="n">number</span><span class="p">:</span> <span class="n">Int</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">Int</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="m">1</span> <span class="p">+</span> <span class="n">number</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">addOne</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">increment</span> <span class="p">=</span> <span class="n">makeIncrementer</span><span class="p">()</span>
</span><span class='line'><span class="n">increment</span><span class="p">(</span><span class="m">7</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>




<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="nf">hasAnyMatches</span><span class="p">(</span><span class="n">list</span><span class="p">:</span> <span class="n">Int</span><span class="p">[],</span> <span class="n">condition</span><span class="p">:</span> <span class="n">Int</span> <span class="p">-&gt;</span> <span class="n">Bool</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">Bool</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">for</span> <span class="n">item</span> <span class="k">in</span> <span class="n">list</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">if</span> <span class="nf">condition</span><span class="p">(</span><span class="n">item</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>            <span class="k">return</span> <span class="k">true</span>
</span><span class='line'>        <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">return</span> <span class="k">false</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">func</span> <span class="nf">lessThanTen</span><span class="p">(</span><span class="n">number</span><span class="p">:</span> <span class="n">Int</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">Bool</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">number</span> <span class="p">&lt;</span> <span class="m">10</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">numbers</span> <span class="p">=</span> <span class="p">[</span><span class="m">20</span><span class="p">,</span> <span class="m">19</span><span class="p">,</span> <span class="m">7</span><span class="p">,</span> <span class="m">12</span><span class="p">]</span>
</span><span class='line'><span class="n">hasAnyMatches</span><span class="p">(</span><span class="n">numbers</span><span class="p">,</span> <span class="n">lessThanTen</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<h4>闭包</h4>

<p>本质来说，函数是特殊的闭包，Swift中可以利用<code>{}</code>声明匿名闭包：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">numbers</span><span class="p">.</span><span class="n">map</span><span class="p">({</span>
</span><span class='line'>    <span class="p">(</span><span class="n">number</span><span class="p">:</span> <span class="n">Int</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">Int</span> <span class="k">in</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">result</span> <span class="p">=</span> <span class="m">3</span> <span class="p">*</span> <span class="n">number</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">result</span>
</span><span class='line'>    <span class="p">})</span>
</span></code></pre></td></tr></table></div></figure>


<p>当闭包的类型已知时，可以使用下面的简化写法：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">numbers</span><span class="p">.</span><span class="n">map</span><span class="p">({</span> <span class="n">number</span> <span class="k">in</span> <span class="m">3</span> <span class="p">*</span> <span class="n">number</span> <span class="p">})</span>
</span></code></pre></td></tr></table></div></figure>


<p>此外还可以通过参数的位置来使用参数，当函数最后一个参数是闭包时，可以使用下面的语法：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">sort</span><span class="p">([</span><span class="m">1</span><span class="p">,</span> <span class="m">5</span><span class="p">,</span> <span class="m">3</span><span class="p">,</span> <span class="m">12</span><span class="p">,</span> <span class="m">2</span><span class="p">])</span> <span class="p">{</span> <span class="err">$</span><span class="m">0</span> <span class="p">&gt;</span> <span class="err">$</span><span class="m">1</span> <span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<h3>类和对象</h3>

<h4>创建和使用类</h4>

<p>Swift使用<code>class</code>创建一个类，类可以包含字段和方法：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">Shape</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">numberOfSides</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;A shape with \(numberOfSides) sides.&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<p>创建<code>Shape</code>类的实例，并调用其字段和方法。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="kt">var</span> <span class="n">shape</span> <span class="p">=</span> <span class="n">Shape</span><span class="p">()</span>
</span><span class='line'><span class="n">shape</span><span class="p">.</span><span class="n">numberOfSides</span> <span class="p">=</span> <span class="m">7</span>
</span><span class='line'><span class="kt">var</span> <span class="n">shapeDescription</span> <span class="p">=</span> <span class="n">shape</span><span class="p">.</span><span class="n">simpleDescription</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>通过<code>init</code>构建对象，既可以使用<code>self</code>显式引用成员字段（<code>name</code>），也可以隐式引用（<code>numberOfSides</code>）。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">NamedShape</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">numberOfSides</span><span class="p">:</span> <span class="n">Int</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">name</span><span class="p">:</span> <span class="n">String</span>
</span><span class='line'>
</span><span class='line'>    <span class="n">init</span><span class="p">(</span><span class="n">name</span><span class="p">:</span> <span class="n">String</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">self</span><span class="p">.</span><span class="n">name</span> <span class="p">=</span> <span class="n">name</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>
</span><span class='line'>    <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;A shape with \(numberOfSides) sides.&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<p>使用<code>deinit</code>进行清理工作。</p>

<h4>继承和多态</h4>

<p>Swift支持继承和多态（<code>override</code>父类方法）：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">Square</span><span class="p">:</span> <span class="n">NamedShape</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">sideLength</span><span class="p">:</span> <span class="n">Double</span>
</span><span class='line'>
</span><span class='line'>    <span class="n">init</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="n">Double</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="n">String</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">self</span><span class="p">.</span><span class="n">sideLength</span> <span class="p">=</span> <span class="n">sideLength</span>
</span><span class='line'>        <span class="n">super</span><span class="p">.</span><span class="n">init</span><span class="p">(</span><span class="n">name</span><span class="p">:</span> <span class="n">name</span><span class="p">)</span>
</span><span class='line'>        <span class="n">numberOfSides</span> <span class="p">=</span> <span class="m">4</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>
</span><span class='line'>    <span class="n">func</span> <span class="nf">area</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">Double</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="n">sideLength</span> <span class="p">*</span> <span class="n">sideLength</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>
</span><span class='line'>    <span class="k">override</span> <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;A square with sides of length \(sideLength).&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">let</span> <span class="n">test</span> <span class="p">=</span> <span class="n">Square</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="m">5.2</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="s">&quot;my test square&quot;</span><span class="p">)</span>
</span><span class='line'><span class="n">test</span><span class="p">.</span><span class="n">area</span><span class="p">()</span>
</span><span class='line'><span class="n">test</span><span class="p">.</span><span class="n">simpleDescription</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>注意：如果这里的<code>simpleDescription</code>方法没有被标识为<code>override</code>，则会引发编译错误。</p>

<h4>属性</h4>

<p>为了简化代码，Swift引入了属性（property），见下面的<code>perimeter</code>字段：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
<span class='line-number'>21</span>
<span class='line-number'>22</span>
<span class='line-number'>23</span>
<span class='line-number'>24</span>
<span class='line-number'>25</span>
<span class='line-number'>26</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">EquilateralTriangle</span><span class="p">:</span> <span class="n">NamedShape</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">sideLength</span><span class="p">:</span> <span class="n">Double</span> <span class="p">=</span> <span class="m">0.0</span>
</span><span class='line'>
</span><span class='line'>    <span class="n">init</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="n">Double</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="n">String</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">self</span><span class="p">.</span><span class="n">sideLength</span> <span class="p">=</span> <span class="n">sideLength</span>
</span><span class='line'>        <span class="n">super</span><span class="p">.</span><span class="n">init</span><span class="p">(</span><span class="n">name</span><span class="p">:</span> <span class="n">name</span><span class="p">)</span>
</span><span class='line'>        <span class="n">numberOfSides</span> <span class="p">=</span> <span class="m">3</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>
</span><span class='line'>    <span class="kt">var</span> <span class="n">perimeter</span><span class="p">:</span> <span class="n">Double</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">get</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="m">3.0</span> <span class="p">*</span> <span class="n">sideLength</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">set</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">sideLength</span> <span class="p">=</span> <span class="n">newValue</span> <span class="p">/</span> <span class="m">3.0</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>
</span><span class='line'>    <span class="k">override</span> <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;An equilateral triagle with sides of length \(sideLength).&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">triangle</span> <span class="p">=</span> <span class="n">EquilateralTriangle</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="m">3.1</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="s">&quot;a triangle&quot;</span><span class="p">)</span>
</span><span class='line'><span class="n">triangle</span><span class="p">.</span><span class="n">perimeter</span>
</span><span class='line'><span class="n">triangle</span><span class="p">.</span><span class="n">perimeter</span> <span class="p">=</span> <span class="m">9.9</span>
</span><span class='line'><span class="n">triangle</span><span class="p">.</span><span class="n">sideLength</span>
</span></code></pre></td></tr></table></div></figure>


<p>注意：赋值器（setter）中，接收的值被自动命名为<code>newValue</code>。</p>

<h4>willSet和didSet</h4>

<p><code>EquilateralTriangle</code>的构造器进行了如下操作：</p>

<ol>
<li>为子类型的属性赋值。</li>
<li>调用父类型的构造器。</li>
<li>修改父类型的属性。</li>
</ol>


<p>如果不需要计算属性的值，但需要在赋值前后进行一些操作的话，使用<code>willSet</code>和<code>didSet</code>：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">TriangleAndSquare</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">triangle</span><span class="p">:</span> <span class="n">EquilateralTriangle</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">willSet</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">square</span><span class="p">.</span><span class="n">sideLength</span> <span class="p">=</span> <span class="n">newValue</span><span class="p">.</span><span class="n">sideLength</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">square</span><span class="p">:</span> <span class="n">Square</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">willSet</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">triangle</span><span class="p">.</span><span class="n">sideLength</span> <span class="p">=</span> <span class="n">newValue</span><span class="p">.</span><span class="n">sideLength</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="n">init</span><span class="p">(</span><span class="n">size</span><span class="p">:</span> <span class="n">Double</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="n">String</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">square</span> <span class="p">=</span> <span class="n">Square</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="n">size</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="n">name</span><span class="p">)</span>
</span><span class='line'>        <span class="n">triangle</span> <span class="p">=</span> <span class="n">EquilateralTriangle</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="n">size</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="n">name</span><span class="p">)</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">triangleAndSquare</span> <span class="p">=</span> <span class="n">TriangleAndSquare</span><span class="p">(</span><span class="n">size</span><span class="p">:</span> <span class="m">10</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="s">&quot;another test shape&quot;</span><span class="p">)</span>
</span><span class='line'><span class="n">triangleAndSquare</span><span class="p">.</span><span class="n">square</span><span class="p">.</span><span class="n">sideLength</span>
</span><span class='line'><span class="n">triangleAndSquare</span><span class="p">.</span><span class="n">square</span> <span class="p">=</span> <span class="n">Square</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="m">50</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="s">&quot;larger square&quot;</span><span class="p">)</span>
</span><span class='line'><span class="n">triangleAndSquare</span><span class="p">.</span><span class="n">triangle</span><span class="p">.</span><span class="n">sideLength</span>
</span></code></pre></td></tr></table></div></figure>


<p>从而保证<code>triangle</code>和<code>square</code>拥有相等的<code>sideLength</code>。</p>

<h4>调用方法</h4>

<p>Swift中，函数的参数名称只能在函数内部使用，但方法的参数名称除了在内部使用外还可以在外部使用（第一个参数除外），例如：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">Counter</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">count</span><span class="p">:</span> <span class="n">Int</span> <span class="p">=</span> <span class="m">0</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">incrementBy</span><span class="p">(</span><span class="n">amount</span><span class="p">:</span> <span class="n">Int</span><span class="p">,</span> <span class="n">numberOfTimes</span> <span class="n">times</span><span class="p">:</span> <span class="n">Int</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">count</span> <span class="p">+=</span> <span class="n">amount</span> <span class="p">*</span> <span class="n">times</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">counter</span> <span class="p">=</span> <span class="n">Counter</span><span class="p">()</span>
</span><span class='line'><span class="n">counter</span><span class="p">.</span><span class="n">incrementBy</span><span class="p">(</span><span class="m">2</span><span class="p">,</span> <span class="n">numberOfTimes</span><span class="p">:</span> <span class="m">7</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<p>注意Swift支持为方法参数取别名：在上面的代码里，<code>numberOfTimes</code>面向外部，<code>times</code>面向内部。</p>

<h4>?的另一种用途</h4>

<p>使用可空值时，<code>?</code>可以出现在方法、属性或下标前面。如果<code>?</code>前的值为<code>nil</code>，那么<code>?</code>后面的表达式会被忽略，而原表达式直接返回<code>nil</code>，例如：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">let</span> <span class="n">optionalSquare</span><span class="p">:</span> <span class="n">Square</span><span class="p">?</span> <span class="p">=</span> <span class="n">Square</span><span class="p">(</span><span class="n">sideLength</span><span class="p">:</span> <span class="m">2.5</span><span class="p">,</span> <span class="n">name</span><span class="p">:</span> <span class="s">&quot;optional </span>
</span><span class='line'><span class="n">square</span><span class="s">&quot;)</span>
</span><span class='line'><span class="n">let</span> <span class="n">sideLength</span> <span class="p">=</span> <span class="n">optionalSquare</span><span class="p">?.</span><span class="n">sideLength</span>
</span></code></pre></td></tr></table></div></figure>


<p>当<code>optionalSquare</code>为<code>nil</code>时，<code>sideLength</code>属性调用会被忽略。</p>

<h3>枚举和结构</h3>

<h4>枚举</h4>

<p>使用<code>enum</code>创建枚举——注意Swift的枚举可以关联方法：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
<span class='line-number'>21</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">enum</span> <span class="n">Rank</span><span class="p">:</span> <span class="n">Int</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">Ace</span> <span class="p">=</span> <span class="m">1</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">Two</span><span class="p">,</span> <span class="n">Three</span><span class="p">,</span> <span class="n">Four</span><span class="p">,</span> <span class="n">Five</span><span class="p">,</span> <span class="n">Six</span><span class="p">,</span> <span class="n">Seven</span><span class="p">,</span> <span class="n">Eight</span><span class="p">,</span> <span class="n">Nine</span><span class="p">,</span> <span class="n">Ten</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">Jack</span><span class="p">,</span> <span class="n">Queen</span><span class="p">,</span> <span class="n">King</span>
</span><span class='line'>        <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">switch</span> <span class="n">self</span> <span class="p">{</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Ace</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;ace&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Jack</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;jack&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Queen</span><span class="p">:</span>
span><span class='line'>                <span class="k">return</span> <span class="s">&quot;queen&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">King</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;king&quot;</span>
</span><span class='line'>            <span class="k">default</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="nf">String</span><span class="p">(</span><span class="n">self</span><span class="p">.</span><span class="n">toRaw</span><span class="p">())</span>
</span><span class='line'>        <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">let</span> <span class="n">ace</span> <span class="p">=</span> <span class="n">Rank</span><span class="p">.</span><span class="n">Ace</span>
</span><span class='line'><span class="n">let</span> <span class="n">aceRawValue</span> <span class="p">=</span> <span class="n">ace</span><span class="p">.</span><span class="n">toRaw</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>使用<code>toRaw</code>和<code>fromRaw</code>在原始（raw）数值和枚举值之间进行转换：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">if</span> <span class="n">let</span> <span class="n">convertedRank</span> <span class="p">=</span> <span class="n">Rank</span><span class="p">.</span><span class="n">fromRaw</span><span class="p">(</span><span class="m">3</span><span class="p">)</span> <span class="p">{</span>
</span><span class='line'>    <span class="n">let</span> <span class="n">threeDescription</span> <span class="p">=</span> <span class="n">convertedRank</span><span class="p">.</span><span class="n">simpleDescription</span><span class="p">()</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<p>注意枚举中的成员值（member value）是实际的值（actual value），和原始值（raw value）没有必然关联。</p>

<p>一些情况下枚举不存在有意义的原始值，这时可以直接忽略原始值：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">enum</span> <span class="n">Suit</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">Spades</span><span class="p">,</span> <span class="n">Hearts</span><span class="p">,</span> <span class="n">Diamonds</span><span class="p">,</span> <span class="n">Clubs</span>
</span><span class='line'>        <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">switch</span> <span class="n">self</span> <span class="p">{</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Spades</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;spades&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Hearts</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;hearts&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Diamonds</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;diamonds&quot;</span>
</span><span class='line'>            <span class="k">case</span> <span class="p">.</span><span class="n">Clubs</span><span class="p">:</span>
</span><span class='line'>                <span class="k">return</span> <span class="s">&quot;clubs&quot;</span>
</span><span class='line'>        <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">let</span> <span class="n">hearts</span> <span class="p">=</span> <span class="n">Suit</span><span class="p">.</span><span class="n">Hearts</span>
</span><span class='line'><span class="n">let</span> <span class="n">heartsDescription</span> <span class="p">=</span> <span class="n">hearts</span><span class="p">.</span><span class="n">simpleDescription</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<p>除了可以关联方法，枚举还支持在其成员上关联值，同一枚举的不同成员可以有不同的关联的值：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">enum</span> <span class="n">ServerResponse</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">case</span> <span class="nf">Result</span><span class="p">(</span><span class="n">String</span><span class="p">,</span> <span class="n">String</span><span class="p">)</span>
</span><span class='line'>    <span class="k">case</span> <span class="nf">Error</span><span class="p">(</span><span class="n">String</span><span class="p">)</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'>
</span><span class='line'><span class="n">let</span> <span class="n">success</span> <span class="p">=</span> <span class="n">ServerResponse</span><span class="p">.</span><span class="n">Result</span><span class="p">(</span><span class="s">&quot;6:00 am&quot;</span><span class="p">,</span> <span class="s">&quot;8:09 pm&quot;</span><span class="p">)</span>
</span><span class='line'><span class="n">let</span> <span class="n">failure</span> <span class="p">=</span> <span class="n">ServerResponse</span><span class="p">.</span><span class="n">Error</span><span class="p">(</span><span class="s">&quot;Out of cheese.&quot;</span><span class="p">)</span>
</span><span class='line'>
</span><span class='line'><span class="k">switch</span> <span class="n">success</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">let</span> <span class="p">.</span><span class="n">Result</span><span class="p">(</span><span class="n">sunrise</span><span class="p">,</span> <span class="n">sunset</span><span class="p">):</span>
</span><span class='line'>        <span class="n">let</span> <span class="n">serverResponse</span> <span class="p">=</span> <span class="s">&quot;Sunrise is at \(sunrise) and sunset is at \(sunset).&quot;</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">let</span> <span class="p">.</span><span class="n">Error</span><span class="p">(</span><span class="n">error</span><span class="p">):</span>
</span><span class='line'>        <span class="n">let</span> <span class="n">serverResponse</span> <span class="p">=</span> <span class="s">&quot;Failure... \(error)&quot;</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<h4>结构</h4>

<p>Swift使用<code>struct</code>关键字创建结构。结构支持构造器和方法这些类的特性。结构和类的最大区别在于：结构的实例按值传递（passed by value），而类的实例按引用传递（passed by reference）。</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">struct</span> <span class="nc">Card</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">rank</span><span class="p">:</span> <span class="n">Rank</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">suit</span><span class="p">:</span> <span class="n">Suit</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">simpleDescription</span><span class="p">()</span> <span class="p">-&gt;</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;The \(rank.simpleDescription()) of \(suit.simpleDescription())&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">let</span> <span class="n">threeOfSpades</span> <span class="p">=</span> <span class="n">Card</span><span class="p">(</span><span class="n">rank</span><span class="p">:</span> <span class="p">.</span><span class="n">Three</span><span class="p">,</span> <span class="n">suit</span><span class="p">:</span> <span class="p">.</span><span class="n">Spades</span><span class="p">)</span>
</span><span class='line'><span class="n">let</span> <span class="n">threeOfSpadesDescription</span> <span class="p">=</span> <span class="n">threeOfSpades</span><span class="p">.</span><span class="n">simpleDescription</span><span class="p">()</span>
</span></code></pre></td></tr></table></div></figure>


<h3>协议（protocol）和扩展（extension）</h3>

<h4>协议</h4>

<p>Swift使用<code>protocol</code>定义协议：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">protocol</span> <span class="n">ExampleProtocol</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">simpleDescription</span><span class="p">:</span> <span class="n">String</span> <span class="p">{</span> <span class="k">get</span> <span class="p">}</span>
</span><span class='line'>    <span class="n">mutating</span> <span class="n">func</span> <span class="nf">adjust</span><span class="p">()</span>
</span><span class='line'><span class="p">}</span>
</span></code></pre></td></tr></table></div></figure>


<p>类型、枚举和结构都可以实现（adopt）协议：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
<span class='line-number'>12</span>
<span class='line-number'>13</span>
<span class='line-number'>14</span>
<span class='line-number'>15</span>
<span class='line-number'>16</span>
<span class='line-number'>17</span>
<span class='line-number'>18</span>
<span class='line-number'>19</span>
<span class='line-number'>20</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="k">class</span> <span class="nc">SimpleClass</span><span class="p">:</span> <span class="n">ExampleProtocol</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">simpleDescription</span><span class="p">:</span> <span class="n">String</span> <span class="p">=</span> <span class="s">&quot;A very simple class.&quot;</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">anotherProperty</span><span class="p">:</span> <span class="n">Int</span> <span class="p">=</span> <span class="m">69105</span>
</span><span class='line'>    <span class="n">func</span> <span class="nf">adjust</span><span class="p">()</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">simpleDescription</span> <span class="p">+=</span> <span class="s">&quot; Now 100% adjusted.&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">a</span> <span class="p">=</span> <span class="n">SimpleClass</span><span class="p">()</span>
</span><span class='line'><span class="n">a</span><span class="p">.</span><span class="n">adjust</span><span class="p">()</span>
</span><span class='line'><span class="n">let</span> <span class="n">aDescription</span> <span class="p">=</span> <span class="n">a</span><span class="p">.</span><span class="n">simpleDescription</span>
</span><span class='line'>
</span><span class='line'><span class="k">struct</span> <span class="nc">SimpleStructure</span><span class="p">:</span> <span class="n">ExampleProtocol</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">simpleDescription</span><span class="p">:</span> <span class="n">String</span> <span class="p">=</span> <span class="s">&quot;A simple structure&quot;</span>
</span><span class='line'>    <span class="n">mutating</span> <span class="n">func</span> <span class="nf">adjust</span><span class="p">()</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">simpleDescription</span> <span class="p">+=</span> <span class="s">&quot; (adjusted)&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">b</span> <span class="p">=</span> <span class="n">SimpleStructure</span><span class="p">()</span>
</span><span class='line'><span class="n">b</span><span class="p">.</span><span class="n">adjust</span><span class="p">()</span>
</span><span class='line'><span class="n">let</span> <span class="n">bDescription</span> <span class="p">=</span> <span class="n">b</span><span class="p">.</span><span class="n">simpleDescription</span>
</span></code></pre></td></tr></table></div></figure>


<h4>扩展</h4>

<p>扩展用于在已有的类型上增加新的功能（比如新的方法或属性），Swift使用<code>extension</code>声明扩展：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">extension</span> <span class="n">Int</span><span class="p">:</span> <span class="n">ExampleProtocol</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">simpleDescription</span><span class="p">:</span> <span class="n">String</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">return</span> <span class="s">&quot;The number \(self)&quot;</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="n">mutating</span> <span class="n">func</span> <span class="nf">adjust</span><span class="p">()</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">self</span> <span class="p">+=</span> <span class="m">42</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="m">7.</span><span class="n">simpleDescription</span>
</span></code></pre></td></tr></table></div></figure>


<h3>泛型（generics）</h3>

<p>Swift使用<code>&lt;&gt;</code>来声明泛型函数或泛型类型：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="n">repeat</span><span class="p">&lt;</span><span class="n">ItemType</span><span class="p">&gt;(</span><span class="n">item</span><span class="p">:</span> <span class="n">ItemType</span><span class="p">,</span> <span class="n">times</span><span class="p">:</span> <span class="n">Int</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">ItemType</span><span class="p">[]</span> <span class="p">{</span>
</span><span class='line'>    <span class="kt">var</span> <span class="n">result</span> <span class="p">=</span> <span class="n">ItemType</span><span class="p">[]()</span>
</span><span class='line'>    <span class="k">for</span> <span class="n">i</span> <span class="k">in</span> <span class="m">0.</span><span class="p">.</span><span class="n">times</span> <span class="p">{</span>
</span><span class='line'>        <span class="n">result</span> <span class="p">+=</span> <span class="n">item</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">return</span> <span class="n">result</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">repeat</span><span class="p">(</span><span class="s">&quot;knock&quot;</span><span class="p">,</span> <span class="m">4</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<p>Swift也支持在类、枚举和结构中使用泛型：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="c1">// Reimplement the Swift standard library&#39;s optional type</span>
</span><span class='line'><span class="k">enum</span> <span class="n">OptionalValue</span><span class="p">&lt;</span><span class="n">T</span><span class="p">&gt;</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">case</span> <span class="n">None</span>
</span><span class='line'>    <span class="k">case</span> <span class="nf">Some</span><span class="p">(</span><span class="n">T</span><span class="p">)</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="kt">var</span> <span class="n">possibleInteger</span><span class="p">:</span> <span class="n">OptionalValue</span><span class="p">&lt;</span><span class="n">Int</span><span class="p">&gt;</span> <span class="p">=</span> <span class="p">.</span><span class="n">None</span>
</span><span class='line'><span class="n">possibleInteger</span> <span class="p">=</span> <span class="p">.</span><span class="n">Some</span><span class="p">(</span><span class="m">100</span><span class="p">)</span>
</span></code></pre></td></tr></table></div></figure>


<p>有时需要对泛型做一些需求（requirements），比如需求某个泛型类型实现某个接口或继承自某个特定类型、两个泛型类型属于同一个类型等等，Swift通过<code>where</code>描述这些需求：</p>

<figure class='code'><figcaption><span></span></figcaption><div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers"><span class='line-number'>1</span>
<span class='line-number'>2</span>
<span class='line-number'>3</span>
<span class='line-number'>4</span>
<span class='line-number'>5</span>
<span class='line-number'>6</span>
<span class='line-number'>7</span>
<span class='line-number'>8</span>
<span class='line-number'>9</span>
<span class='line-number'>10</span>
<span class='line-number'>11</span>
</pre></td><td class='code'><pre><code class='csharp'><span class='line'><span class="n">func</span> <span class="n">anyCommonElements</span> <span class="p">&lt;</span><span class="n">T</span><span class="p">,</span> <span class="n">U</span> <span class="k">where</span> <span class="n">T</span><span class="p">:</span> <span class="n">Sequence</span><span class="p">,</span> <span class="n">U</span><span class="p">:</span> <span class="n">Sequence</span><span class="p">,</span> <span class="n">T</span><span class="p">.</span><span class="n">GeneratorType</span><span class="p">.</span><span class="n">Element</span><span class="p">:</span> <span class="n">Equatable</span><span class="p">,</span> <span class="n">T</span><span class="p">.</span><span class="n">GeneratorType</span><span class="p">.</span><span class="n">Element</span> <span class="p">==</span> <span class="n">U</span><span class="p">.</span><span class="n">GeneratorType</span><span class="p">.</span><span class="n">Element</span><span class="p">&gt;</span> <span class="p">(</span><span class="n">lhs</span><span class="p">:</span> <span class="n">T</span><span class="p">,</span> <span class="n">rhs</span><span class="p">:</span> <span class="n">U</span><span class="p">)</span> <span class="p">-&gt;</span> <span class="n">Bool</span> <span class="p">{</span>
</span><span class='line'>    <span class="k">for</span> <span class="n">lhsItem</span> <span class="k">in</span> <span class="n">lhs</span> <span class="p">{</span>
</span><span class='line'>        <span class="k">for</span> <span class="n">rhsItem</span> <span class="k">in</span> <span class="n">rhs</span> <span class="p">{</span>
</span><span class='line'>            <span class="k">if</span> <span class="n">lhsItem</span> <span class="p">==</span> <span class="n">rhsItem</span> <span class="p">{</span>
</span><span class='line'>                <span class="k">return</span> <span class="k">true</span>
</span><span class='line'>            <span class="p">}</span>
</span><span class='line'>        <span class="p">}</span>
</span><span class='line'>    <span class="p">}</span>
</span><span class='line'>    <span class="k">return</span> <span class="k">false</span>
</span><span class='line'><span class="p">}</span>
</span><span class='line'><span class="n">anyCommonElements</span><span class="p">([</span><span class="m">1</span><span class="p">,</span> <span class="m">2</span><span class="p">,</span> <span class="m">3</span><span class="p">],</span> <span class="p">[</span><span class="m">3</span><span class="p">])</span>
</span></code></pre></td></tr></table></div></figure>


<p>Swift语言概览就到这里，有兴趣的朋友请进一步阅读<a href="">The Swift Programming Language</a>。</p>

<p>接下来聊聊个人对Swift的一些感受。</p>

<h2>个人感受</h2>

<p><strong>注意</strong>：下面的感受纯属个人意见，仅供参考。</p>

<h3>大杂烩</h3>

<p>尽管我接触Swift不足两小时，但很容易看出Swift吸收了大量其它编程语言中的元素，这些元素包括但不限于：</p>

<ol>
<li>属性（Property）、可空值（Nullable type）语法和泛型（Generic Type）语法源自C#。</li>
<li>格式风格与Go相仿（没有句末的分号，判断条件不需要括号）。</li>
<li>Python风格的当前实例引用语法（使用<code>self</code>）和列表字典声明语法。</li>
<li>Haskell风格的区间声明语法（比如<code>1..3</code>，<code>1...3</code>）。</li>
<li>协议和扩展源自Objective-C（自家产品随便用）。</li>
<li>枚举类型很像Java（可以拥有成员或方法）。</li>
<li><code>class</code>和<code>struct</code>的概念和C#极其相似。</li>
</ol>


<p>注意这里不是说Swift是抄袭——实际上编程语言能玩的花样基本就这些，况且Swift选的都是在我看来相当不错的特性。</p>

<p>而且，这个大杂烩有一个好处——就是任何其它编程语言的开发者都不会觉得Swift很陌生——这一点很重要。</p>

<h3>拒绝隐式（Refuse implicity）</h3>

<p>Swift去除了一些隐式操作，比如隐式类型转换和隐式方法重载这两个坑，干的漂亮。</p>

<h3>Swift的应用方向</h3>

<p>我认为Swift主要有下面这两个应用方向：</p>

<h4>教育</h4>

<p>我指的是编程教育。现有编程语言最大的问题就是交互性奇差，从而导致学习曲线陡峭。相信Swift及其交互性极强的编程环境能够打破这个局面，让更多的人——尤其是青少年，学会编程。</p>

<p>这里有必要再次提到<a href="http://worrydream.com/">Bret Victor</a>的<a href="http://vimeo.com/36579366">Inventing on Principle</a>，看了这个视频你就会明白一个交互性强的编程环境能够带来什么。</p>

<h4>应用开发</h4>

<p>现有的iOS和OS X应用开发均使用Objective-C，而Objective-C是一门及其繁琐（verbose）且学习曲线比较陡峭的语言，如果Swift能够提供一个同现有Obj-C框架的简易互操作接口，我相信会有大量的程序员转投Swift；与此同时，Swift简易的语法也会带来相当数量的其它平台开发者。</p>

<p>总之，上一次某家大公司大张旗鼓的推出一门编程语言及其编程平台还是在2000年（微软推出C#），将近15年之后，苹果推出Swift——作为开发者，我很高兴能够见证一门编程语言的诞生。</p>

<p>以上。</p>

<p>原文作者：</p>

<ul>
<li><a href="http://zh.lucida.me/">Lucida Blog</a></li>
<li><a href="http://www.weibo.com/pegong/">新浪微博</a></li>
<li><a href="http://www.douban.com/people/figure9/">豆瓣</a></li>
</ul>


<p>转载前请保留出处链接，谢谢。</p>
</div>