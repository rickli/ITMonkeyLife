---
layout: post
title: "教程:一步步在github上建立octopress博客"
date: 2014-03-13 14:05:56 +0800
comments: true
categories: 
---
<h2>目标</h2>
<p>创建网址为<a href="http://itmonkeylife.github.io/Blog">http://itmonkeylife.github.io/Blog</a>的博客.博客使用octopress程序,搭建在github的服务器上.网页与本地机器的<code>Blog</code>文件夹同步.</p>
<h2>步骤</h2>
<h3>0) 配置环境</h3>
<p>octopress需要ruby和git支持. 因此我们需要先安装这两个程序.
这儿分windows和Mac分别讲下.</p>
<p><strong>Windows(简略说下,详细教程请搜索):</strong></p>
<p>下载并安装git:</p>
<blockquote>
    
<p><a href="http://git-scm.com/download">http://git-scm.com/download</a></p>
</blockquote>
<p>下载并安装Ruby和开发组件(DEVELOPMENT KIT),共两个文件,Ruby推荐1.9.3版,对octopuses支持很好:</p>
<blockquote>
<p><a href="http://rubyinstaller.org/downloads/">http://rubyinstaller.org/downloads/</a></p>
</blockquote>
<p><strong>Mac:</strong></p>
<p>Mac本身自带了git,因此不需要单独安装.</p>
<p>Octopress需要带openssl组件的ruby支持.</p>
<p>但新版本的ruby似乎编译对参数<code>--with-openssl-dir=my/openssl/dir</code>支持有问题, 因此推荐使用rvm安装管理多版本的Ruby, rvm默认安装Ruby 2.0版本, 这儿为了不发生兼容性问题, 除了默认的2.0, 再安装个带openssl的1.9.3版.</p>
<ul>
<li><p>确认<a href="https://developer.apple.com/xcode/">Xcode</a>和其自带的<code>命令行工具</code>已经安装.</p>
<p>  如没有,Xcode可在App Store免费下载.<code>命令行工具</code>可以在<code>Xcode- Preferences - Download</code> 中    点击安装 <code>Command Line Tools</code>.</p>
</li>
<li><p>安装rvm, rvm是个软件管理工具,和Linux上的apt-get,yum之类类似.</p>
</li>
</ul>
<pre><code class="lang-bash">sudo curl -L https://get.rvm.io | bash -s stable</code></pre>
<p>在~/.bash_profile文件末尾添加:</p>
<pre><code class="lang-bash">echo &#39;[[ -s &quot;$HOME/.rvm/scripts/rvm&quot; ]] &amp;&amp; . &quot;$HOME/.rvm/scripts/rvm&quot;</code></pre>
<p>加载下配置文件:</p>
<pre><code class="lang-bash">source ~/.bash_profile</code></pre>
<ul>
<li>安装1.93版支持openssl的Ruby.</li>
</ul>
<pre><code class="lang-bash">rvm install 1.9.3 --with-gcc=clang ----with-openssl-dir=$HOME/.rvm/usr
rvm use 1.9.3 --default</code></pre>
<h3>1) 下载octopress至本地Blog文件夹</h3>
<p>octopress的源代码同样在github上管理,因此我们使用git克隆一份到本地的<code>Blog</code>文件夹,并进入此文件夹.
如你没有域名,可以使用github提供的默认域名:<code>yourname.github.com</code>,yourname是你github的用户名.</p>
<pre><code class="lang-bash">git clone git@github.com:ITMonkeyLife/Blog.git ITMonkeyLife/Blog
cd ITMonkeyLife/Blog</code></pre>
<h3>2) 安装相关组件</h3>
<!-- more -->
<pre><code class="lang-bash">gem install bundler
bundle install</code></pre>
<h3>3) 安装主题</h3>
<pre><code class="lang-bash">rake install</code></pre>
<p>上条命令安装默认主题,在<a href="https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes">https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes</a>可以找到许多第三方主题,这儿我们选择<a href="http://zespia.tw/Octopress-Theme-Slash/">slash</a>主题,如询问是否覆盖,选择是:</p>
<pre><code class="lang-bash">git clone git://github.com/tommy351/Octopress-Theme-Slash.git .themes/slash
rake install[&#39;slash&#39;]</code></pre>
<h3>4) 在github上创建repository</h3>
<p>去<a href="http://github.com">Github</a>上注册个账户,选择免费套餐.</p>
<p>新建一个repository.</p>
<p><strong>注意:repository的名字一定要<code>yourname.github.com</code>这样的格式.</strong>
<code>yourname</code>是你注册时的用户名.</p>
<p>这儿我创建名为<code>itmonkeylife.github.com</code>的repository,创建好后拷贝ssh地址.</p>
<p><code>https://github.com/itmonkeylife/Blog.github.com.git</code></p>
<h3>5) 建立本地与github的联系</h3>
<pre><code class="lang-bash">rake setup_github_pages</code></pre>
<p>输入上述ssh地址,注意区分大小写.
如遇验证问题,提示类似</p>
<pre><code class="lang-bash">rake aborted!
undefined method
[]&#39; for nil:NilClass

Tasks: TOP =&gt; setup_github_pages
(See full trace by running task with --trace)</code></pre>
<p>的信息,请看此文:<a href="http://never.doubting.me/2013/04/18/2013-04-18-github-set-up-ssh-keys/">github设置ssh验证</a></p>
<h3>6) 绑定域名</h3>
<p>首先把你的域名指向<code>207.97.227.245</code>,如不知怎么操作,请咨询域名注册商.
在source文件夹下建立CNAME文件:</p>
<pre><code class="lang-bash">echo &#39;never.doubting.me&#39; &gt;&gt; source/CNAME</code></pre>
<h3>7) 生成网页并推送到github</h3>
<pre><code class="lang-bash">rake generate
rake deploy</code></pre>
<p>稍等几分钟,你就可通过域名访问博客了.并且收到一封博客建立的信件.</p>
<h3>8) 自定义博客</h3>
<p>博客的基本信息在<code>_config.yml</code>文件中修改.
自定义css等在<code>source</code>文件夹中.
修改后别忘了:</p>
<pre><code class="lang-bash">rake generate
rake deploy</code></pre>
<h3>9) 发表文章</h3>
<pre><code>rake new_post[&quot;教程:一步步在github上建立octopress博客&quot;]</code></pre>
<p>这儿我新建了一篇名为<code>教程:一步步在github上建立octopress博客</code>的文章.
之后去<code>source/_post/</code>文件夹找到对应<code>.markdown</code>文件修改.</p>
<p>打开文件后可以看到文件头包含一些文章的信息,这儿我修改为:</p>
<pre><code class="lang-html">---
layout: post    
title: &quot;教程:一步步在github上建立octopress博客&quot;    
date: 2014-03-13 11:13    
author: znithy    
comments: true    
categories:     
- 教程    
- github    
- octopress    
published: false
---</code></pre>
<p>第一张指明此篇是<code>post</code>,后面是标题,时间和作者,我加了<code>教程</code> <code>github</code> <code>octopuses</code> 三个标签,并且允许评论,<code>published: false</code>表示不要发表,如想要发表改成<code>published: true</code>或者直接删掉这行.</p>
<p>文章直接写在这部分内容下面.</p>
<h3>10) 发表外链文章</h3>
<p>点击标题转向其他网页.创建方法同上,只是需要添加<code>external-url</code>这个条目.
下面是一个例子:</p>
<pre><code class="lang-html">---        
layout: post    
title: &quot;非常不错的科学博客&quot;    
date: 2014-03-13 14:13         
comments: true        
external-url: http://www.baidu.com/        
---</code></pre>
<h3>11) 发表页面</h3>
<p>创建网址为<code>http://itmonkeylife.github.io/Blog//about/i.html</code>的网页:</p>
<pre><code class="lang-bash">rake new_page[about/i.html]</code></pre>
<p>与<code>post</code>不同的是,此时没有<code>categories</code>这个条目,但多了<code>sharing</code>和<code>footer</code>,具体有什么作用,不妨自己试下.</p>
<pre><code class="lang-html">---    
layout: page        
title: &quot;Super Awesome&quot;    
date: 2011-07-03 5:59    
comments: true    
sharing: true    
footer: true        
---</code></pre>
<h3>12) 管理文章</h3>
<p>直接增加或删除.markdown文件即可.
每次更新文件后别忘了:</p>
<pre><code class="lang-bash">rake generate
rake deploy</code></pre>
<h2>其他</h2>
<h3>git设置用户名</h3>
<p>默认情况下直接使用系统的用户名,也可通过下面的命令自定义:</p>
<pre><code class="lang-bash">git config --global user.name author #将用户名设为author    
git config --global user.email author@mail.com #将用户邮箱设为author@mail.com</code></pre>
<h3>关于怎样使用git,这份教程很不错,推荐.</h3>
<blockquote>
<p><a href="http://znithy.com/download/看日记学git.pdf">看日记学git.pdf</a></p>
</blockquote>
<h3>第三方插件地址:</h3>
<blockquote>
<p><a href="https://github.com/imathis/octopress/wiki/3rd-party-plugins">https://github.com/imathis/octopress/wiki/3rd-party-plugins</a></p>
</blockquote>
<h3>中文问题:</h3>
<p>如遇到此类提示(可能因设置了中文的catagory):</p>
<pre><code class="lang-bash">...
Liquid Exception: invalid byte sequence in UTF-8 in atom.xml
/Documents/never.doubting.me/plugins/octopress_filters.rb:75:in `gsub;
/Documents/never.doubting.me/plugins/octopress_filters.rb:75:in `cdata_escape;
...</code></pre>
<p>最方便的方法是换用kramdown.首先安装kramdown:</p>
<pre><code class="lang-bash">gem install kramdown</code></pre>
<p>之后修改<code>_config.yml</code>文件:</p>
<pre><code class="lang-html">markdown: kramdown</code></pre>
