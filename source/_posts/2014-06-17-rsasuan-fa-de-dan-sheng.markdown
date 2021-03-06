---
layout: post
title: "RSA算法的诞生"
date: 2014-06-17 09:20:46 +0800
comments: true
categories: [RSA]
---
<p>最近为了研究某个极其无聊的问题，读了一些公钥加密的历史，意外地发现这段历史竟然非常有趣。尤其是 RSA 算法的诞生过程，被很多书写得非常励志，看得人热血澎湃。果然比起算法本身，这些背后的故事更能吸引我的兴趣。</p>
<p>RSA 算法具体是怎么回事，我就不在这瞎说了。简介可以看 <a href="http://en.wikipedia.org/wiki/RSA_(cryptosystem)" target="_blank">Wikipedia</a>，如果想形象一点理解算法本身，<a href="http://v.youku.com/v_show/id_XNDQ0NTE3MDA0.html" target="_blank">这儿</a>有个不错的视频，可以通过它了解 RSA 的基本思想。我就直接从 RSA 这三个人说起了。参考的书籍资料列在文末。</p>
<p><span id="more-1659"></span></p>
<h2>RSA 背后的三个小伙</h2>
<p>RSA 是由三个提出者 <a href="http://en.wikipedia.org/wiki/Ron_Rivest" target="_blank">Ron Rivest</a>、<a href="http://en.wikipedia.org/wiki/Adi_Shamir" target="_blank">Adi Shamir</a> 和 <a href="http://en.wikipedia.org/wiki/Len_Adleman" target="_blank">Leonard Adleman</a> 的姓氏首字母组成的。这三个人风格迥异，组成了一个技能互补的完美团队。</p>
<p>Ron Rivest，RSA 中的 R。他在耶鲁读数学系，随后跑到斯坦福读计算机科学系研究人工智能。他所研究的课题——让机器人在没有人干预的情况下在停车场散步，在那个计算机科学系仅成立四年的年代明显太过乐观，但他依然乐此不疲。毕业后他接受 MIT 任教的工作机会。也许是因为多年积累的科研氛围，他对新技术非常兴奋，大量阅读前沿文献。与此同时，他认为迷人的理论应该与现实世界相结合，才能散发魅力，对世界有所改变，这也是他的理想。</p>
<p>Adi Shamir，RSA 中的 S。他是以色列人，和 Rivest 一样，学数学后转计算机科学进一步深造，毕业后以访问学者的身份来到 MIT。他很聪明，学习能力超强。虽然他在数学上的造诣颇深，但起初他在算法方面的知识十分匮乏，当他接到 Rivest 关于算法高级课程讲授的邀请信时连连叫苦，教算法已经够呛了，还什么高级课程？给博士生讲的么？虽然如此，他还是硬着头皮前往 MIT，之后很快投入到学习中，整天泡在图书馆，读了一书架关于算法的书籍，最终仅用两周便掌握了所需的知识。</p>
<p>Leonard Adleman，RSA 中的 A。自幼胸无大志，从未想过做什么数学家。读大学时受各方面影响，甚至包括<a href="http://en.wikipedia.org/wiki/Watch_Mr._Wizard" target="_blank">电视节目</a>的影响，在专业选择上犹豫不决，最终因为学数学会有大量时间做别的而选择就读数学系。毕业后在美国银行做程序员，之后想去学医，被录取了却又改变主意想研究物理，上了几堂课又觉得没意思。最后他怕挂科对找工作有影响，跑去图书馆借了本计算机科学的书，一直没还，学校就会因此扣留成绩单。辗转几次后，他最终选择读计算机科学 PhD。毕业后同样在 MIT 任教。</p>
<p>这三人当时都非常年轻，二十多、三十出头的样子。他们的办公室距离很近，可以经常串门。于是故事就从一次 Adleman 的串门开始了。</p>
<div class="wp-caption alignnone" ><img title="有没有看到黑板上写着的 ∴ P = NP" alt="" src="http://pic.yupoo.com/i404/Dqb0HmOw/7DiuP.jpg" width="600" height="207" /><p class="wp-caption-text">自左至右：Adi Shamir, Ron Rivest, Leonard Adleman (<a href="http://www.usc.edu/dept/molecular-science/RSApics.htm" target="_blank">via</a>)</p></div>
<h2>42次的失败</h2>
<!-- more -->
<p>1976 年底的某天，Adleman 无意推开 Rivest 的房门。热爱新技术的 Rivest 果不其然正拿着份楼上的  <a href="http://en.wikipedia.org/wiki/Whitfield_Diffie" target="_blank">Whitfield Diffie</a> 与 <a href="http://en.wikipedia.org/wiki/Martin_Hellman" target="_blank">Martin Hellman</a> 合作发表的新论文研究。自认为对前沿理念无所不晓的 Rivest，没料到这篇文章提出了一个前所未有的思路，这让他兴奋不已。正琢磨着，Adleman 推门进来了，Rivest 便忘我地向 Adleman 讲解了这篇论文中所述的思想，在 Adleman 听起来大约是这样的：</p>
<blockquote><p>公钥密码 blah blah blah…不对称密码 blah blah blah…单向函数 blah blah blah…但是符合条件的单向函数目前没找到。我有信心找到这样的单向函数，你看你要不要和我一起试试？</p></blockquote>
<p>这些显然不足以让早已下决心走纯理论路线的 Adleman 动心，对此他只是报以一个“礼貌的哈欠”。想当初选择读计算机科学，除了方便找工作，Adleman 还深受马丁加德纳专栏的影响。专栏中写到的哥德尔定理让他感到惊艳，深深体会到数学之美，如今只有高斯之流方能入他的眼，眼下 Rivest 滔滔不绝的什么加密解密，在他看来既不高级也不好玩。</p>
<p>好在 Rivest 拉到了另一个同盟，也就是隔壁的 Shamir。Shamir 一听说这篇文章就立刻意识到它的价值，二人一拍即合，开始了他们昼夜不休的单向函数寻找之旅。因为两人都头脑灵活，很快就想到了一些方案。尽管 Adleman 不情愿参与其中，他们还是会把结果拿给 Adleman，Adleman 的角色就是逐个击破这些方案，找出各种漏洞，给那两个头脑发热的人泼点冷水，免得他们走弯路。</p>
<p>三人走火入魔一般，吃饭聊、喝酒聊，甚至去滑雪度假也不忘讨论这件事。Shamir 就在滑雪的时候想到了一个绝妙的点子，以至于把滑雪板都落在了身后。当他意识到这一点回头去取时，却又不幸忘记了那个一闪而过的点子。相对来说给他们启发的 Diffie 要幸运一些，他在下楼买可乐的时候同样让灵感溜走，好在上楼的过程中他又想起来了，这个差点溜走的灵感正是 Rivest 那天手中所拿论文的核心思想，为 RSA 算法奠定了基础。</p>
<p>起初 Rivest 和 Shamir 构造出来的算法很快就能被 Adleman 破解，二人受到强烈的打击，以至于有一阶段他们走向了另一个极端，试图证明 Diffie 他们的想法根本就是不靠谱的。但慢慢的，破解变得没那么容易，特别是他们的第 32 号方案，Adleman 用了一晚上才找出漏洞，这让他们感觉胜利就在眼前。</p>
<p>就这样，Rivest 和 Shamir 先后抛出了 42 个方案，虽然这 42 个全部被 Adleman 击破，不过他们的努力并不算白费，至少指出了 42 条错误的路线。</p>
<h2>算法的诞生与命名</h2>
<p>1977 年 4 月，Rivest 和其余两人参加了犹太逾越节的 Party，喝了些酒。到家后 Rivest 睡不着，随手翻了翻数学书，随后一个灵感逐渐清晰起来。他大气不敢出一口，冷静下来连夜整理自己的思路，一气呵成写就了一篇论文。次日，Rivest 把论文拿给 Adleman，做好再一次徒劳的心理准备，但这一次 Adleman 认输了，认为这个方案应该是可行的。</p>
<p>按照惯例，Rivest 按姓氏字母序将三人的名字署在论文上，也就是 Adleman、Rivest、Shamir，但 Adleman 总觉得自己贡献微乎其微，不过是泼泼冷水，不至于还要署个名，便要求 Rivest 拿掉自己的名字。在 Rivest 的坚持下，他最终要求至少把自己的名字放到最后。也正因为如此，RSA 叫做 RSA没有被叫做 ARS。虽然 Adleman 一开始认为这注定是他诸多论文中最不起眼的一篇，RSA 走红后他还是调侃说，越来越觉得 ARS 更顺口了。</p>
<h2>之后</h2>
<p>之后的历史我们就非常熟悉了，他们的论文受到各方赞赏。Rivest 还把论文发给马丁加德纳一份，加德纳非常感兴趣，把 Rivest 请到家里面谈，进一步了解 RSA 算法。当然此前，加德纳还不忘先表演一个扑克魔术。这次会面也促成后来马丁加德纳在他著名的专栏刊登 RSA 算法及破解奖金的故事。至于 R、S、A 这三人，依然保持着友谊，还成立了 RSA 公司，赚了一大笔钱。</p>
<p>最后，既然 RSA 是根据提出者命名的，必然也逃不出 <a href="http://en.wikipedia.org/wiki/Stigler%27s_law_of_eponymy" target="_blank">Stigler&#8217;s law</a> 的魔爪。的确从时间上来说，RSA 这三人并非最早提出这个算法的人。事实上早于这三人四年时间，RSA 算法的思想就被英国学者构造出来了。早在 1969 年，英国密码学家 <a href="http://en.wikipedia.org/wiki/James_H._Ellis" target="_blank">James Ellis</a> 就想到了公钥密码的概念，但同样卡在寻找单向函数这个问题上。1973 年 9 月，年仅 26 岁的数学家 <a href="http://en.wikipedia.org/wiki/Clifford_Cocks" target="_blank">Clifford Cocks</a> 听说这个思想后，在完全不了解状况的心理状态下花不到半小时就找到了 Rivest 他们苦思冥想的方案。但是，他们效力于政府，这个绝妙的想法立刻被相关机构封锁，变为机密，谁也不能对外公开自己的发现，于是他们眼睁睁地看着 Diffie 及 RSA 等人重现了他们当时的研究并享有盛誉。直到 1997 年底，时隔二十余年，这件事情才被公之于众。遗憾的是那时候 Ellis 已经过世一个月，直至逝世都是一个无名英雄。</p>
<h2>参考资料</h2>
<ul>
<li><a href="http://www.amazon.cn/Crypto-How-the-Code-Rebels-Beat-the-Government-Saving-Privacy-in-the-Digital-Age-Levy-Steven/dp/0140244328/ref=sr_1_1?ie=UTF8&amp;qid=1388319023" target="_blank">Crypto: How the Code Rebels Beat the Government&#8211;Saving Privacy in the Digital Age</a>：Steven Levy 所著，<span style="line-height: 1.714285714; font-size: 1rem;">大部分内容都是从这本书了解到的。书里从 Whitfield Diffie 的八卦（是真的八卦，和他老婆的相遇之类）说起，一直说到非常现实的 NSA 涉入等情节，写得很详细很有趣。中译本译作《<a href="http://books.google.ch/books?id=s3RyC2JKGqwC&amp;hl=zh-CN&amp;source=gbs_navlinks_s" target="_blank">隐私的终结</a>》，但翻译水平非常有限，比如把爱伦坡译成艾伦坡和阿兰坡两种不同译法，把 cutting-edge 翻译成边缘，或者干脆把算法水平有待提高翻译成精通算法什么的…</span></li>
<li><a href="http://www.amazon.cn/The-Code-Book-The-Science-of-Secrecy-from-Ancient-Egypt-to-Quantum-Cryptography-Singh-Simon/dp/0385495323/ref=sr_1_1" target="_blank">The Code Book: The Science of Secrecy from Ancient Egypt to Quantum Cryptography</a>：中译本《<a href="http://www.amazon.cn/密码故事-人类智力的另类较量-西蒙•辛格/dp/B00AV1S8HU/ref=sr_1_1?s=books&amp;ie=UTF8&amp;qid=1388319635&amp;sr=1-1" target="_blank">密码故事</a>》，除了密码从古至今的演变，书里还单独对 Ellis 和 Cocks 等人的工作做了详细的讲述。我还没看完这本书，但感觉会很有意思。</li>
<li>关于 Adleman 的更多八卦可以看<a href="http://www.nytimes.com/1994/12/13/science/scientist-at-work-leonard-adleman-hitting-the-high-spots-of-computer-theory.html" target="_blank">这篇采访</a>，总觉得他的气场和其余两人很不搭，各种变卦和无所谓。啊对了，Adleman 也是将计算机病毒命名为 Computer virus 的人。</li>
</ul>
			
<hr />