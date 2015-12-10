---
layout: post
title: "iOS7.0:隐藏技巧和变通之道"
date: 2014-04-09 17:16:22 +0800
comments: true
categories: [iOS]
---
<p>当 iOS 7 刚发布的时候，全世界的苹果开发人员都立马尝试着去编译他们的 app，接着再花上数月的时间来修复任何出现的错误，甚至从头开始重建这个 app。这样的结果，使得人们根本无暇去探究 iOS 7 所带来的新思想。除开一些明显而细微的更新，比如说 NSArray 的 <code>firstObject</code> 方法——这个方法可追溯到 iOS 4 时代，现在被提为公有 API——还有很多隐藏的技巧等着我们去挖掘。</p>

<h2 id="">平滑淡入淡出动画</h2>

<p>我在这里要讨论的并非新的弹性动画 API 或者 UIDynamics，而是一些更细微的东西。CALayer 增加了两个新方法：<code>allowsGroupOpacity</code> 和 <code>allowsEdgeAntialiasing</code>。现在，组不透明度（group opacity）不再是什么新鲜的东西了。iOS 会多次使用存在于 Info.plist 中的键 <code>UIViewGroupOpacity</code> 并可在应用程序范围内启用或禁用它。对于大多数 app 而言，这（译注：启用）并非所期望的，因为它会降低整体性能。在 iOS 7 中，用 SDK 7 所链接的程序，这项属性默认是启用的。当它被启用时，一些动画将会变得不流畅，它也可以在 layer 层上被控制。</p>

<p>一个有趣的细节，如果 <code>allowsGroupOpacity</code> 启用的话，<code>_UIBackdropView</code>（被用作 <code>UIToolbar</code> 或者 <code>UIPopoverView</code> 的背景视图）不能对其模糊进行动画处理，所以当你做一个 alpha 转换时，你可能会临时禁用这项属性。因为这会降低动画体验，你可以回到旧的方式然后在动画期间临时启用 <code>shouldRasterize</code>。别忘了设置适当的 <code>rasterizationScale</code>，否则在 retina 的设备上这些视图会成锯齿状（pixelerated）。</p>

<p>如果你想要复制 Safari 显示所有选项卡时的动画，那么边缘抗锯齿属性将变得非常有用。</p>

<h2 id="">阻塞动画</h2>

<p>有一个小但是非常有用的新方法 <code>[UIView performWithoutAnimation:]</code>。它是一个简单的封装，先检查动画当前是否启用，如果是则停用动画，执行块语句，然后重新启用动画。一个需要说明的地方是，它并 <em>不会</em> 阻塞基于 CoreAnimation 的动画。因此，不用急于将你的方法调用从：</p>

```objc
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    view.frame = CGRectMake(...);
    [CATransaction commit];
```

<p>替换成:</p>

```objc
    [UIView performWithoutAnimation:^{
        view.frame = CGRectMake(...);
    }];
```
<!-- more -->
<p>但是，绝大多数情况下这样也能工作得很好，只要你不直接跟 CALayer 打交道。</p>

<p>iOS 7 中，我有很多代码路径（主要是 <code>UITableViewCells</code>）需要额外保护以防止意外的动画，例如，如果一个弹窗（popover）的大小调整了，与此同时其中的表视图将因为高度的变化而加载新的 cell。我通常的做法是将整个 <code>layoutSubviews</code> 的代码包扎到一个动画块中：</p>

```objc
- (void)layoutSubviews 
{
    // 否则在 iOS 7 的传统模式下弹窗动画会渗入我们的单元格
    [UIView performWithoutAnimation:^{
        [super layoutSubviews];
        _renderView.frame = self.bounds;
    }];
}
```

<h2 id="">处理长的表视图</h2>

<p><code>UITableView</code> 非常快速高效，除非你开始使用 <code>tableView:heightForRowAtIndexPath:</code>，它会开始为你表中 <em>每一个</em> 元素调用此方法，即便没有可视对象——这是为了让其下层的 <code>UIScrollView</code> 能获取正确的 <code>contentSize</code>。此前有一些变通方法，但都不好用。iOS 7 中，苹果公司终于承认这一问题，并添加了  <code>tableView:estimatedHeightForRowAtIndexPath:</code>，这个方法把绝大部分计算成本推迟到实际滚动的时候。如果你完全不知道一个 cell 的大小，返回 <code>UITableViewAutomaticDimension</code> 就行了。</p>

<p>对于段头/尾（section headers/footers），现在也有类似的 API 了。</p>

<h2 id="uisearchdisplaycontroller">UISearchDisplayController</h2>

<p>苹果的 search controller 使用了新的技巧来简化移动 search bar 到 navigation bar 的过程。启用 <code>displaysSearchBarInNavigationBar</code> 就可以了（除非你还在用 scope bar，那你就太不幸了）。我倒是很喜欢这么做，但遗憾的是，iOS 7 上的 <code>UISearchDisplayController</code> 貌似被破坏得相当严重，尤其在 iPad 上。苹果公司看上去像是没时间处理这个问题，对于显示的搜索结果并不会隐藏实际的表视图。在 iOS 7 之前，这不算问题，但是现在 <code>searchResultsTableView</code> 有一个透明的背景色，使它看上去相当糟糕。作为一种变通方法，你可以设置不透明背景色或者采取一些<a href="http://petersteinberger.com/blog/2013/fixing-uisearchdisplaycontroller-on-ios-7/">更富于技巧的手段</a>来获得你期望的效果。关于这个控件我碰到过各种各样的结果，当使用 <code>displaysSearchBarInNavigationBar</code> 时甚至 <em>根本</em> 不会显示搜索表视图。</p>

<p>你的结果可能有所不同，但我依赖于一些手段（severe hacks）来让 <code>displaysSearchBarInNavigationBar</code> 工作：</p>

```objc
- (void)restoreOriginalTableView 
{
    if (PSPDFIsUIKitFlatMode() &amp;&amp; self.originalTableView) {
        self.view = self.originalTableView;
    }
}

- (UITableView *)tableView 
{
    return self.originalTableView ?: [super tableView];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller 
  didShowSearchResultsTableView:(UITableView *)tableView 
{
    // HACK: iOS 7 依赖于重度的变通来显示搜索表视图
    if (PSPDFIsUIKitFlatMode()) {
        if (!self.originalTableView) self.originalTableView = self.tableView;
        self.view = controller.searchResultsTableView;
        controller.searchResultsTableView.contentInset = UIEdgeInsetsZero; // 移除 64 像素的空白
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller 
  didHideSearchResultsTableView:(UITableView *)tableView 
{
    [self restoreOriginalTableView];
}
```

<p>另外，别忘了在 <code>viewWillDisappear</code> 中调用 <code>restoreOriginalTableView</code>，否则程序会 crash。
记住这只是一种解决办法；可能还有不那么激进的方法，不用替换视图本身，但这个问题确实应该由苹果公司来修复。（TODO: RADAR!）</p>

<h2 id="">分页</h2>

<p><code>UIWebView</code> 现在可以对带有 <code>paginationMode</code> 的网站进行自动分页。有一大堆与此功能相关的新属性：</p>

```objc
@property (nonatomic) UIWebPaginationMode paginationMode NS_AVAILABLE_IOS(7_0);
@property (nonatomic) UIWebPaginationBreakingMode paginationBreakingMode NS_AVAILABLE_IOS(7_0);
@property (nonatomic) CGFloat pageLength NS_AVAILABLE_IOS(7_0);
@property (nonatomic) CGFloat gapBetweenPages NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) NSUInteger pageCount NS_AVAILABLE_IOS(7_0);
```

<p>目前而言，虽然这不一定对大多数网站都有用，但它肯定是生成简单的电子书阅读器或者显示文本的一种更好的方式。加点乐子的话，请尝试将它设置为 <code>UIWebPaginationModeBottomToTop</code>。</p>

<h2 id="popover">会飞的 Popover</h2>

<p>想知道为什么你的 popover 疯了一样到处乱飞？在 <code>UIPopoverControllerDelegate</code> 协议中有一个新的代理方法让你能控制它：</p>

```objc
-  (void)popoverController:(UIPopoverController *)popoverController
  willRepositionPopoverToRect:(inout CGRect *)rect 
                       inView:(inout UIView **)view
```

<p>当 popover 锚点是指向一个 <code>UIBarButtonItem</code> 时，<code>UIPopoverController</code> 会做出合适的展现，但是如果你让它在一个 view 或者 rect 中显示，你可能就需要实现此方法并正常返回。一个花费了我相当长时间来验证的问题——如果你通过改变 <code>preferredContentSize</code> 来动态调整你的 popover，那么这个方法就尤其需要实现。苹果公司现在对改变 popover 大小的请求更严格，如果没有预留足够的空间，popover 将会到处移动。</p>

<h2 id="">键盘支持</h2>

<p>苹果公司不只为我们提供了<a href="https://developer.apple.com/library/ios/documentation/ServicesDiscovery/Conceptual/GameControllerPG/Introduction/Introduction.html">全新的 framework 用于游戏控制器</a>，它也给了我们这些键盘爱好者一些关注！你会发现新定义的公用键，比如  <code>UIKeyInputEscape</code> 或 <code>UIKeyInputUpArrow</code>，可以使用全新的 <a href="https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIKeyCommand_class/Reference/Reference.html#//apple_ref/occ/instp/UIKeyCommand/input"><code>UIKeyCommand</code></a> 类截查。在 iOS 7 之前，只能通过一些<a href="http://petersteinberger.com/blog/2013/adding-keyboard-shortcuts-to-uialertview/">难以言表的手段来处理键盘命令</a>，现在，就让我们操起蓝牙键盘试试看我们能用这个做什么！</p>

<p>开始之前，你需要对响应链（responder chain）有个了解。你的 <code>UIApplication</code> 继承自  <code>UIResponder</code>，<code>UIView</code> 和 <code>UIViewController</code> 也是如此。如果你曾经处理过 <code>UIMenuItem</code>  并且没有使用<a href="https://github.com/steipete/PSMenuItem">我的基于块的包装</a>的话，那么你对此已经有所了解。事件先被发送到最上层的响应者，然后一级级往下传递直到 UIApplication。为了捕获按键命令，你需要告诉系统你关心哪些按键命令（而不是全捕获）。为了完成这个，你需要重写 <code>keyCommands</code> 这个新属性：</p>

```objc
- (NSArray *)keyCommands 
{
    return @[[UIKeyCommand keyCommandWithInput:@"f"
                                 modifierFlags:UIKeyModifierCommand  
                                        action:@selector(searchKeyPressed:)]];
}

- (void)searchKeyPressed:(UIKeyCommand *)keyCommand 
{
    // 响应事件
}
```

<p><img src="http://img.objccn.io/issue-5/responder-chain.png" name="工作中的响应者链" width="472" height="548"></p>

<p>现在可别太激动，需要注意的是，这个方法只在键盘可见时有效（比如有类似 <code>UITextView</code> 这样的对象作为第一响应者时）。对于全局热键，你仍然需要用上面提到的 hack 方法。除去那些，这个解决途径还是很优雅的。不要覆盖类似 cmd-V 这种系统的快捷键，它会被自动映射到 <code>paste:</code> 方法。</p>

<p>还有一些新的预定义的响应者行为：</p>

```objc
- (void)increaseSize:(id)sender NS_AVAILABLE_IOS(7_0);
- (void)decreaseSize:(id)sender NS_AVAILABLE_IOS(7_0);
```

<p>它们分别对应 cmd+ 和 cmd- 命令，用来放大/缩小内容。</p>

<h2 id="">匹配键盘背景</h2>

<p>苹果公司终于公开了 <a href="https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIInputView_class/Reference/Reference.html"><code>UIInputView</code></a>，其中提供了一种方式——使用 <code>UIInputViewStyleKeyboard</code> 来匹配键盘样式。这使得你能编写自定义的键盘或者适应默认样式的默认键盘的扩展（工具条）。这个类<a href="https://github.com/nst/iOS-Runtime-Headers/commits/master/Frameworks/UIKit.framework/UIInputView.h">一开始</a>就存在了，不过现在我们终于可以绕过私有API的方式来使用它了。</p>

<p>如果 <code>UIInputView</code> 是一个 <code>inputView</code> 或者 <code>inputAccessoryView</code> 的<em>根视图</em>，它将只显示一个背景，否则它将是透明的。遗憾的是，这并不能让你实现一个未填充的分离态的键盘，但它仍然比用一个简单的 UIToolbar 要好。我还没看到苹果在何处使用这个新 API，看上去 Safari 里仍然使用着 <code>UIToolbar</code>。</p>

<h2 id="">了解你的无线电通信</h2>

<p>虽然早在 iOS 4 的时候，大部分的运营商信息已经在 CTTelephony 暴露了，但它通常只用于特定场景并非十分有用。iOS 7 中，苹果公司为其添加了一个方法，其中最有用的：<code>currentRadioAccessTechnology</code>。这个方法能告诉你手机是处于较慢的 GPRS 还是高速的 LTE 或者介于其中。目前还没有方法得到连接速度（当然手机本身也无法获取这个），但是这足以用来优化一个下载管理器，让其在 EDGE 下不用尝试 <em>同时</em> 去下载6张图片了。</p>

<p>现在还没有 <code>currentRadioAccessTechnology</code> 的相关文档，为了让它工作，会遇到一些麻烦和错误。当你想要获取当前网络信号值，你应当注册一个 <code>CTRadioAccessTechnologyDidChangeNotification</code> 通知而不是去轮询这个属性。为了确切的使 iOS 发送这些通知，你需要持有一个 <code>CTTelephonyNetworkInfo</code> 的实例，但不要在通知中创建  <code>CTTelephonyNetworkInfo</code> 的实例，否则会 crash。</p>

<p>在这个简单的例子中，因为在 block 中捕获 <code>telephonyInfo</code> 将会持有它，所以我就这么用了：</p>

```objc
CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
[NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification 
                                                object:nil 
                                                 queue:nil 
                                            usingBlock:^(NSNotification *note) 
{
    NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
}];
```

<p>当手机从 Edge 环境切换到 3G，日志输出应该像这样：</p>

<pre><code>iOS7Tests[612:60b] Current Radio Access Technology: CTRadioAccessTechnologyEdge
iOS7Tests[612:1803] New Radio Access Technology: (null)
iOS7Tests[612:1803] New Radio Access Technology: CTRadioAccessTechnologyHSDPA
</code></pre>

<p>苹果导出了所有字符串符号，因此可以很简单的比较和检测当前的网络信息。</p>

<h2 id="corefoundationautorelease">Core Foundation，Autorelease 和你</h2>

<p>Core Foundation 中出现了一个新的辅助方法，它被用于私有调用已有数年时间：</p>

```objc
CFTypeRef CFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg)
```

<p>它的确做了你所期望的事，让人费解的是苹果花了这么长时间才把它公开。ARC 下，大多数人在处理返回 Core Foundation 对象时是通过转换成对等的 NS 对象来完成的，如返回一个  <code>NSDictionary</code>，虽然它是一个 <code>CFDictionaryRef</code>，简单地使用 <code>CFBridgingRelease()</code> 就行了。这样通常没问题，除非你返回的没有可用的对等 NS 对象，如 <code>CFBagRef</code>。你要么使用 id，这样会失去类型安全性，要么你将你的方法重命名为 <code>createMethod</code> 并考虑所有的内存语义，最后使用 CFRelease。还有一些手段，比如<a href="http://favstar.fm/users/AndrePang/status/18099774996">这个</a>，使用 non-ARC-file 参数你才能编译它，但终归得使用 CFAutorelease()。另外：不要编写使用苹果公司命名空间的代码，所有这些自定义的 CF-宏将来都会被打破的。</p>

<h2 id="">图片解压缩</h2>

<p>当通过 <code>UIImage</code> 展示一张图片时，在显示之前需要解压缩（除非图片源已经像素缓存了）。对于 JPG/PNG 文件这会占用相当可观的时间并会造成卡顿。iOS 6 以前，通常是通过创建一个位图上下文，然后在其中画图来解决。<a href="https://github.com/AFNetworking/AFNetworking/blob/09658b352a496875c91cc33dd52c3f47b9369945/AFNetworking/AFURLResponseSerialization.m#L442-518">（参见 AFNetworking 如何处理这个问题）</a>。</p>

<p>从 iOS 7 开始，你可以使用 <code>kCGImageSourceShouldCacheImmediately</code>: 强制图片在创建时直接解压缩：</p>

```objc
+ (UIImage *)decompressedImageWithData:(NSData *)data 
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, (__bridge CFDictionaryRef)@{(id)kCGImageSourceShouldCacheImmediately: @YES});

    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CFRelease(source);
    return image;
}
```

<p>刚发现这一点时我很很兴奋，但不要高兴得太早。在我的测试中，开启即时缓存后性能实际上有所 <em>降低</em>。要么这个方法最终是在主线程中被调用的（好像不太可能），要么感官上的性能下降是因为其在方法 <code>copyImageBlockSetJPEG</code> 中锁住了，因为这个方法也被用在主线程显示非加密的图片时。在我的 app 中，我在主线程中加载小的预览图，在后台线程中加载大型图，使用了 <code>kCGImageSourceShouldCacheImmediately</code> 后小小的解压缩阻塞了主线程，同时在后台处理大量开销昂贵的操作。    </p>

<p><img src="http://img.objccn.io/issue-5/image-decompression.png" name="Image Decompression Stack Trace" width="662" height="1008"></p>

<p>还有更多关于图片解压缩的却不是 iOS 7 中的新东西，像 <code>kCGImageSourceShouldCache</code>，它用来控制系统自动卸载解压缩图片数据的能力。确保你将它设置为 YES，否则所有的工作都将没有意义。有趣的是，苹果在 64-bit 运行时的系统中将 <code>kCGImageSourceShouldCache</code> 的 <em>默认值</em> 从 NO 改为了 YES。</p>

<h2 id="">盗版检查</h2>

<p>苹果添加了一个方式，通过 NSBunble 上的新方法 <a href="https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/Reference/Reference.html#//apple_ref/occ/instm/NSBundle/appStoreReceiptURL"><code>appStoreReceiptURL</code></a> 来获取和验证 Lion 系统上 App Store 的收据，现在终于也移植到了 iOS 上了。这使得你可以检查你的应用是合法购买的还是被破解了的。检查收据还有另一个重要的原因，它包含了 <em>初始购买日期</em>，这点对于把你的应用从付费模式迁移到免费+应用内付费模式很有帮助。你可以根据这个初始购买日期来决定额外内容对于你的用户是免费（因为他们已经付过费了）还是收费的。</p>

<p>收据还允许你检查应用程序是否通过批量购买计划购买以及该许可证是否仍有效，有一个名为  <code>SKReceiptPropertyIsVolumePurchase</code> 的属性标示了该值。</p>

<p>当你调用 <code>appStoreReceiptURL</code> 时，你需要特别注意，因为在 iOS 6 上，它还是一个私有 API，你应该在用户代码中先调用 <code>doesNotRecognizeSelector:</code>，在调用前检查运行（基础）版本。在开发期间，这个方法返回的 URL 不会指向一个文件。你可能需要使用 StoreKit 的 <a href="https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKReceiptRefreshRequest_ClassRef/SKReceiptRefreshRequest.html"><code>SKReceiptRefreshRequest</code></a>，这也是 iOS 7 中的新东西，用它来下载证书。使用一个至少有过一次购买的测试用户，否则它将没法工作：</p>

```objc
// 刷新收据
SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
[request setDelegate:self];
[request start];
```

<p>验证收据需要大量的代码。你需要使用 OpenSSL 和内嵌的<a href="http://www.apple.com/certificateauthority/">苹果根证书</a>，并且你还要了解一些基本的东西像是证书、<a href="http://en.wikipedia.org/wiki/PKCS">PCKS 容器</a>以及 <a href="http://de.wikipedia.org/wiki/Abstract_Syntax_Notation_One">ASN.1</a>。这里有一些<a href="https://github.com/rmaddy/VerifyStoreReceiptiOS">样例代码</a>，但是你不应该让它这么简单——尤其是对那些有“高尚意图”的人，别只是拷贝现有的验证方法，至少做点修改或者编写你自己的，你应该不希望一个普通的补丁程序就能在数秒内瓦解你的努力吧。</p>

<p>你绝对应该读读苹果的指南——<a href="https://developer.apple.com/library/mac/releasenotes/General/ValidateAppStoreReceipt/index.html#//apple_ref/doc/uid/TP40010573-CH1-SW6">验证 Mac App 商店收据</a>，这里面的大多数都适用于 iOS。苹果在 <a href="https://developer.apple.com/wwdc/videos/">WWDC 2013 的 Session 308 “Using Receipts to Protect Your Digital Sales”</a> 中详述了通过新加入的“Grand Unified Receipt”而带来的变动。</p>

<h2 id="comicsansms">Comic Sans MS</h2>

<p>承认吧，你是怀念 Comic Sans MS 的。在 iOS 7 中，Comic Sans MS 终于回来了。iOS 6 中添加了可下载字体，但那时的字体列表很少也不见得有趣。在 iOS 7 中苹果添加了不少字体，包括 “famous”，它和 <a href="http://www.fontsquirrel.com/fonts/PT-Sans">PT Sans</a> 或 <a href="http://sixrevisions.com/graphics-design/comic-sans-the-font-everyone-loves-to-hate/">Comic Sans MS</a> 有些类似。<code>kCTFontDownloadableAttribute</code> 并没有在 iOS 6 中声明，所以 iOS 7 之前它并不真正可用，但苹果确是在 iOS 6 的时候就已经做了私有声明了。</p>

<p><img src="http://img.objccn.io/issue-5/comic-sans-ms.png" name="Who doesn't love Comic Sans MS" width="414" height="559"></p>

<p>字体列表是<a href="http://mesu.apple.com/assets/com_apple_MobileAsset_Font/com_apple_MobileAsset_Font.xml">动态变化</a>的，以后可能就会发生变动。苹果在 <a href="http://support.apple.com/kb/HT5484">Tech Note HT5484</a> 中罗列了一些可用的字体，但这个文档已经过时了，并不能反映 iOS 7 的变化。</p>

<p>这里显示了你该如何获取一个用 <code>CTFontDescriptorRef</code> 标示的可下载的字体数组：</p>

```objc
CFDictionary *descriptorOptions = @{(id)kCTFontDownloadableAttribute : @YES};
CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)descriptorOptions);
CFArrayRef fontDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(descriptor, NULL);
```

<p>系统不会检查字体是否已存在于磁盘上而将直接返回同样的列表。另外，这个方法可能会启用网络并造成阻塞，你不应该在主线程中使用它。</p>

<p>使用如下基于块的 API 来下载字体：    </p>

```objc
bool CTFontDescriptorMatchFontDescriptorsWithProgressHandler(
         CFArrayRef                          descriptors,
         CFSetRef                            mandatoryAttributes,
         CTFontDescriptorProgressHandler     progressBlock)
```

<p>这个方法能操作网络并传递下载进度信息来调用你的 <code>progressBlock</code> 方法直到下载成功或者失败。参考苹果的 <a href="https://developer.apple.com/library/ios/samplecode/DownloadFont/Listings/DownloadFont_ViewController_m.html">DownloadFont 样例</a>看看如何使用它。    </p>

<p>有一些值得注意的地方，这里的字体只在当前程序运行时有效，下次运行将被重新载入内存。因为字体存放在共享空间中，你不能依赖于它们是否可用。很有可能但不能保证地说，系统会清理这个目录，或者你的程序被拷贝到没有这个字体的新设备中，同时你又没有网络。在 Mac 或是模拟器上，你能根据 <code>kCTFontURLAttribute</code> 获得字体的绝对路径，加载速度也会提升，但是在 iOS 上是不行的，因为这个目录在你的程序之外，你需要再次调用 <code>CTFontDescriptorMatchFontDescriptorsWithProgressHandler</code>。</p>

<p>你也可以注册新的 <code>kCTFontManagerRegisteredFontsChangedNotification</code> 通知来跟踪新字体在何时被载入到了字体注册表中。你可以在 <a href="https://developer.apple.com/wwdc/videos/">WWDC 2013 的 Session 223 “Using Fonts with TextKit”</a>中查找更多信息。</p>

<h2 id="">这还不够?</h2>

<p>没关系，iOS 7 的新东西远不止如此！了解一下 <a href="http://nshipster.com/ios7/">NSHipster</a> 你将明白语音合成相关的东西，base64、全新的 <code>NSURLComponents</code>、<code>NSProgress</code>、条形码扫描、阅读列表以及 <code>CIDetectorEyeBlink</code>。还有很多我们没有涵盖到的，比如苹果的 <a href="https://developer.apple.com/library/ios/releasenotes/General/iOS70APIDiffs/index.html#//apple_ref/doc/uid/TP40013203">iOS 7 API 变化</a>，<a href="https://developer.apple.com/library/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS7.html">What's new in iOS</a>指南以及 <a href="https://developer.apple.com/library/prerelease/mac/releasenotes/Foundation/RN-Foundation/index.html#//apple_ref/doc/uid/TP30000742">Foundation Release Notes</a>（这些都是基于 OS X的，但是代码都是共享的，很多也同样适用于 iOS）。很多新方法都还没形成文档，等着你来探究和写成博客。</p>

<hr />