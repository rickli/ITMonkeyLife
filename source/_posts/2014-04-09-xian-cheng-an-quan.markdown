---
layout: post
title: "线程安全"
date: 2014-04-09 16:08:45 +0800
comments: true
categories: [iOS]
---
<p>这篇文章将专注于实用技巧，设计模式，以及对于写出线程安全类和使用 GCD 来说所特别需要注意的一些<a href="http://zh.wikipedia.org/wiki/反面模式">反面模式</a>。</p>

<h2 id="">线程安全</h2>

<h3 id="apple">Apple 的框架</h3>

<p>首先让我们来看看 Apple 的框架。一般来说除非特别声明，大多数的类默认都不是线程安全的。对于其中的一些类来说，这是很合理的，但是对于另外一些来说就很有趣了。</p>

<p>就算是在经验丰富的 iOS/Mac 开发者，也难免会犯从后台线程去访问 UIKit/AppKit 这种错误。比如因为图片的内容本身就是从后台的网络请求中获取的话，顺手就在后台线程中设置了 <code>image</code> 之类的属性，这样的错误其实是屡见不鲜的。Apple 的代码都经过了性能的优化，所以即使你从别的线程设置了属性的时候，也不会产生什么警告。</p>

<p>在设置图片这个例子中，症结其实是你的改变通常要过一会儿才能生效。但是如果有两个线程在同时对图片进行了设定，那么很可能因为当前的图片被释放两次，而导致应用崩溃。这种行为是和时机有关系的，所以很可能在开发阶段没有崩溃，但是你的用户使用时却不断 crash。</p>

<p>现在没有<strong>官方</strong>的用来寻找类似错误的工具，但我们确实有一些技巧来避免这个问题。<a href="https://gist.github.com/steipete/5664345">UIKit Main Thread Guard</a> 是一段用来监视每一次对 <code>setNeedsLayout</code> 和 <code>setNeedsDisplay</code> 的调用代码，并检查它们是否是在主线程被调用的。因为这两个方法在 UIKit 的 setter （包括 image 属性）中广泛使用，所以它可以捕获到很多线程相关的错误。虽然这个小技巧并不包含任何私有 API， 但我们还是不建议将它是用在发布产品中，不过在开发过程中使用的话还是相当赞的。</p>

<p>Apple没有把 UIKit 设计为线程安全的类是有意为之的，将其打造为线程安全的话会使很多操作变慢。而事实上 UIKit 是和主线程绑定的，这一特点使得编写并发程序以及使用 UIKit 十分容易的，你唯一需要确保的就是对于 UIKit 的调用总是在主线程中来进行。</p>

<h4 id="uikit">为什么 UIKit 不是线程安全的？</h4>

<p>对于一个像 UIKit 这样的大型框架，确保它的线程安全将会带来巨大的工作量和成本。将 non-atomic 的属性变为 atomic 的属性只不过是需要做的变化里的微不足道的一小部分。通常来说，你需要同时改变若干个属性，才能看到它所带来的结果。为了解决这个问题，苹果可能不得不提供像 Core Data 中的 <code>performBlock:</code> 和 <code>performBlockAndWait:</code> 那样类似的方法来同步变更。另外你想想看，绝大多数对 UIKit 类的调用其实都是以<strong>配置</strong>为目的的，这使得将 UIKit 改为线程安全这件事情更显得毫无意义了。</p>

<p>然而即使是那些与配置共享的内部状态之类事情无关的调用，其实也不是线程安全的。如果你做过 iOS 3.2 或之前的黑暗年代的 app 开发的话，你肯定有过一边在后台准备图像时一边使用 NSString 的 <code>drawInRect:withFont:</code> 时的随机崩溃的经历。值得庆幸的事，在 iOS 4 中 <a href="http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniOS/Articles/iPhoneOS4.html">苹果将大部分绘图的方法和诸如 <code>UIColor</code> 和 <code>UIFont</code> 这样的类改写为了后台线程可用</a>。</p>

<p>但不幸的是 Apple 在线程安全方面的文档是极度匮乏的。他们推荐只访问主线程，并且甚至是绘图方法他们都没有明确地表示保证线程安全。因此在阅读文档的同时，去读读 <a href="http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniOS/Articles/iPhoneOS4.html">iOS 版本更新说明</a>会是一个很好的选择。</p>

<p>对于大多数情况来说，UIKit 类确实只应该用在应用的主线程中。这对于那些继承自 UIResponder 的类以及那些操作你的应用的用户界面的类来说，不管如何都是很正确的。</p>

<h4 id="deallocation">内存回收 (deallocation) 问题</h4>

<p>另一个在后台使用 UIKit 对象的的危险之处在于“内存回收问题”。Apple 在技术笔记 <a href="ttp://developer.apple.com/library/ios/#technotes/tn2109/_index.html">TN2109</a> 中概述了这个问题，并提供了多种解决方案。这个问题其实是要求 UI 对象应该在主线程中被回收，因为在它们的 <code>dealloc</code> 方法被调用回收的时候，可能会去改变 view 的结构关系，而如我们所知，这种操作应该放在主线程来进行。</p>

<p>因为调用者被其他线程持有是非常常见的（不管是由于 operation 还是 block 所导致的），这也是很容易犯错并且难以被修正的问题。在 <a href="https://github.com/AFNetworking/AFNetworking/issues/56">AFNetworking 中也一直长久存在这样的 bug</a>，但是由于其自身的隐蔽性而鲜为人知，也很难重现其所造成的崩溃。在异步的 block 或者操作中一致使用 <code>__weak</code>，并且不去直接访问局部变量会对避开这类问题有所帮助。</p>

<h4 id="collection">Collection 类</h4>
<!-- more -->
<p>Apple 有一个<a href="ttps://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/Multithreading/ThreadSafetySummary/ThreadSafetySummary.html#//apple_ref/doc/uid/10000057i-CH12-SW1">针对 iOS 和 Mac 的很好的总览性文档</a>，为大多数基本的 foundation 类列举了其线程安全特性。总的来说，比如 <code>NSArry</code> 这样不可变类是线程安全的。然而它们的可变版本，比如 <code>NSMutableArray</code> 是线程不安全的。事实上，如果是在一个队列中串行地进行访问的话，在不同线程中使用它们也是没有问题的。要记住的是即使你申明了返回类型是不可变的，方法里还是有可能返回的其实是一个可变版本的 collection 类。一个好习惯是写类似于 <code>return [array copy]</code> 这样的代码来确保返回的对象事实上是不可变对象。</p>

<p>与和<a href="">Java</a>这样的语言不一样，Foundation 框架并不提供直接可用的 collection 类，这是有其道理的，因为大多数情况下，你想要的是在更高层级上的锁，以避免太多的加解锁操作。但缓存是一个值得注意的例外，iOS 4 中 Apple 添加的 <code>NSCache</code> 使用一个可变的字典来存储不可变数据，它不仅会对访问加锁，更甚至在低内存情况下会清空自己的内容。</p>

<p>也就是说，在你的应用中存在可变的且线程安全的字典是可以做到的。借助于 class cluster 的方式，我们也很容易<a href="https://gist.github.com/steipete/5928916">写出这样的代码</a>。</p>

<h3 id="atomicproperties">原子属性 (Atomic Properties)</h3>

<p>你曾经好奇过 Apple 是怎么处理 atomic 的设置/读取属性的么？至今为止，你可能听说过自旋锁 (spinlocks)，信标 (semaphores)，锁 (locks)，@synchronized 等，Apple 用的是什么呢？因为 <a href="http://www.opensource.apple.com/source/objc4/">Objctive-C 的 runtime 是开源</a>的，所以我们可以一探究竟。</p>

<p>一个非原子的 setter 看起来是这个样子的：</p>

```objc
- (void)setUserName:(NSString *)userName {
      if (userName != _userName) {
          [userName retain];
          [_userName release];
          _userName = userName;
      }
}
```

<p>这是一个手动 retain/release 的版本，ARC 生成的代码和这个看起来也是类似的。当我们看这段代码时，显而易见要是 <code>setUserName:</code> 被并发调用的话会造成麻烦。我们可能会释放 <code>_userName</code> 两次，这回使内存错误，并且导致难以发现的 bug。</p>

<p>对于任何没有手动实现的属性，编译器都会生成一个 <a href="https://github.com/opensource-apple/objc4/blob/master/runtime/Accessors.subproj/objc-accessors.mm#L127"><code>objc_setProperty_non_gc(id self, SEL _cmd, ptrdiff_t offset, id newValue, BOOL atomic, signed char shouldCopy)</code></a> 的调用。在我们的例子中，这个调用的参数是这样的：</p>

```objc
objc_setProperty_non_gc(self, _cmd, 
  (ptrdiff_t)(&amp;_userName) - (ptrdiff_t)(self), userName, NO, NO);`
```

<p><code>ptrdiff_t</code> 可能会吓到你，但是实际上这就是一个简单的指针算术，因为其实 Objective-C 的类仅仅只是 C 结构体而已。</p>

<p><code>objc_setrProperty</code> 调用的是如下方法：</p>

```objc
static inline void reallySetProperty(id self, SEL _cmd, id newValue, 
  ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy) 
{
    id oldValue;
    id *slot = (id*) ((char*)self + offset);

    if (copy) {
        newValue = [newValue copyWithZone:NULL];
    } else if (mutableCopy) {
        newValue = [newValue mutableCopyWithZone:NULL];
    } else {
        if (*slot == newValue) return;
        newValue = objc_retain(newValue);
    }

    if (!atomic) {
        oldValue = *slot;
        *slot = newValue;
    } else {
        spin_lock_t *slotlock = &amp;PropertyLocks[GOODHASH(slot)];
        _spin_lock(slotlock);
        oldValue = *slot;
        *slot = newValue;        
        _spin_unlock(slotlock);
    }

    objc_release(oldValue);
}
```

<p>除开方法名字很有趣以外，其实方法实际做的事情非常直接，它使用了在 <code>PropertyLocks</code> 中的 128 个自旋锁中的 1 个来给操作上锁。这是一种务实和快速的方式，最糟糕的情况下，如果遇到了哈希碰撞，那么 setter 需要等待另一个和它无关的 setter 完成之后再进行工作。</p>

<p>虽然这些方法没有定义在任何公开的头文件中，但我们还是可用手动调用他们。我不是说这是一个好的做法，但是知道这个还是蛮有趣的，而且如果你想要同时实现原子属性<strong>和</strong>自定义的 setter 的话，这个技巧就非常有用了。</p>

```objc
// 手动声明运行时的方法
extern void objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, 
  id newValue, BOOL atomic, BOOL shouldCopy);
extern id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, 
  BOOL atomic);

#define PSTAtomicRetainedSet(dest, src) objc_setProperty(self, _cmd, 
  (ptrdiff_t)(&amp;dest) - (ptrdiff_t)(self), src, YES, NO) 
#define PSTAtomicAutoreleasedGet(src) objc_getProperty(self, _cmd, 
  (ptrdiff_t)(&amp;src) - (ptrdiff_t)(self), YES)
```

<p><a href="https://gist.github.com/steipete/5928690">参考这个 gist</a> 来获取包含处理结构体的完整的代码，但是我们其实并不推荐使用它。</p>

<h4 id="synchronized">为何不用 @synchronized ？</h4>

<p>你也许会想问为什么苹果不用 <code>@synchronized(self)</code> 这样一个已经存在的运行时特性来锁定属？？你可以看看<a href="https://github.com/opensource-apple/objc4/blob/master/runtime/objc-sync.mm#L291">这里的源码</a>，就会发现其实发生了很多的事情。Apple 使用了<a href="http://googlemac.blogspot.co.at/2006/10/synchronized-swimming.html">最多三个加/解锁序列</a>，还有一部分原因是他们也添加了<a href="https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html#//apple_ref/doc/uid/10000057i-CH8-SW3">异常开解(exception unwinding)</a>机制。相比于更快的自旋锁方式，这种实现要慢得多。由于设置某个属性一般来说会相当快，因此自旋锁更适合用来完成这项工作。<code>@synchonized(self)</code> 更适合使用在你
需要确保在发生错误时代码不会死锁，而是抛出异常的时候。</p>

<h3 id="">你自己的类</h3>

<p>单独使用原子属性并不会是你的类变成线程安全。它不能保护你应用的逻辑，只能保护你免于在 setter 中遭遇到<a href="http://objccn.io/issue-3-1">竞态条件</a>的困扰。看看下面的代码片段：</p>

```objc
if (self.contents) {
    CFAttributedStringRef stringRef = CFAttributedStringCreate(NULL, 
      (__bridge CFStringRef)self.contents, NULL);
    // 渲染字符串
}
```

<p>我之前在 <a href="http://pspdfkit.com">PSPDFKit</a> 中就犯了这个错误。时不时地应用就会因为 <code>contents</code> 属性在通过检查之后却又被设成了 nil 而导致 EXC<em>BAD</em>ACCESS 崩溃。捕获这个变量就可以简单修复这个问题；</p>

```objc
NSString *contents = self.contents;
if (contents) {
    CFAttributedStringRef stringRef = CFAttributedStringCreate(NULL, 
      (__bridge CFStringRef)contents, NULL);
    // 渲染字符串
}
```

<p>在这里这样就能解决问题，但是大多数情况下不会这么简单。想象一下我们还有一个 <code>textColor</code> 的属性，我们在一个线程中将两个属性都做了改变。我们的渲染线程有可能使用了新的内容，但是依旧保持了旧的颜色，于是我们得到了一组奇怪的组合。这其实也是为什么 Core Data 要将 model 对象都绑定在一个线程或者队列中的原因。</p>

<p>对于这个问题，其实没有万用解法。使用 <a href="http://www.cocoawithlove.com/2008/04/value-of-immutable-values.html">不可变模型</a>是一个可能的方案，但是它也有自己的问题。另一种途径是限制对存在在主线程或者某个特定队列中的既存对象的改变，而是先进行一次拷贝之后再在工作线程中使用。对于这个问题的更多对应方法，我推荐阅读 Jonathan Sterling 的关于 <a href="http://www.jonmsterling.com/posts/2012-12-27-a-pattern-for-immutability.html">Objective-C 中轻量化不可变对象</a>的文章。</p>

<p>一个简单的解决办法是使用 <code>@synchronize</code>。其他的方式都非常非常可能使你误入歧途，已经有太多聪明人在这种尝试上一次又一次地以失败告终。</p>

<h4 id="">可行的线程安全设计</h4>

<p>在尝试写一些线程安全的东西之前，应该先想清楚是不是真的需要。确保你要做的事情不会是过早优化。如果要写的东西是一个类似配置类 (configuration class) 的话，去考虑线程安全这种事情就毫无意义了。更正确的做法是扔一个断言上去，以保证它被正确地使用：</p>

```objc
void PSPDFAssertIfNotMainThread(void) {
    NSAssert(NSThread.isMainThread, 
      @"Error: Method needs to be called on the main thread. %@", 
      [NSThread callStackSymbols]);
}
```

<p>对于那些肯定应该线程安全的代码（一个好例子是负责缓存的类）来说，一个不错的设计是使用并发的 <code>dispatch_queue</code> 作为读/写锁，并且确保只锁着那些真的需要被锁住的部分，以此来最大化性能。一旦你使用多个队列来给不同的部分上锁的话，整件事情很快就会变得难以控制了。</p>

<p>于是你也可以重新组织你的代码，这样某些特定的锁就不再需要了。看看下面这段实现了一种多委托的代码（其实在大多数情况下，用 NSNotifications 会更好，但是其实也还是有<a href="https://code.google.com/r/riky-adsfasfasf/source/browse/Utilities/GCDMulticastDelegate.h">多委托的实用例子</a>）的</p>

```objc
// 头文件
@property (nonatomic, strong) NSMutableSet *delegates;

// init方法中
_delegateQueue = dispatch_queue_create("com.PSPDFKit.cacheDelegateQueue", 
  DISPATCH_QUEUE_CONCURRENT);

- (void)addDelegate:(id&lt;PSPDFCacheDelegate&gt;)delegate {
    dispatch_barrier_async(_delegateQueue, ^{
        [self.delegates addObject:delegate];
    });
}

- (void)removeAllDelegates {
    dispatch_barrier_async(_delegateQueue, ^{
        self.delegates removeAllObjects];
    });
}

- (void)callDelegateForX {
    dispatch_sync(_delegateQueue, ^{
        [self.delegates enumerateObjectsUsingBlock:^(id&lt;PSPDFCacheDelegate&gt; delegate, NSUInteger idx, BOOL *stop) {
            // 调用delegate
        }];
    });
}
```

<p>除非 <code>addDelegate:</code> 或者 <code>removeDelegate:</code> 每秒要被调用上千次，否则我们可以使用一个相对简洁的实现方式：</p>

```objc
// 头文件
@property (atomic, copy) NSSet *delegates;

- (void)addDelegate:(id&lt;PSPDFCacheDelegate&gt;)delegate {
    @synchronized(self) {
        self.delegates = [self.delegates setByAddingObject:delegate];
    }
}

- (void)removeAllDelegates {
    self.delegates = nil;
}

- (void)callDelegateForX {
    [self.delegates enumerateObjectsUsingBlock:^(id&lt;PSPDFCacheDelegate&gt; delegate, NSUInteger idx, BOOL *stop) {
        // 调用delegate
    }];
}
```

<p>当然啦，这个例子有点过于人为编造，其实我们很容易可以把变化限制在主线程中来避免问题。但是对于很多数据结构来说，可以在进行变更操作的方法中创建不可变的拷贝，这样 app 的整体逻辑就不需要处理很多锁的情况。请注意我们还是需要给 <code>addDelegate:</code> 加上锁，否则在其他线程进行异步调用的时候可能遭遇委托对象丢失的问题。</p>

<h2 id="gcd">GCD 的陷阱</h2>

<p>对于大多数上锁的需求来说，GCD 就足够好了。它简单迅速，并且基于 block 的 API 使得粗心大意造成非平衡锁操作的概率下降了不少。然后，GCD 中还是有不少陷阱，我们在这里探索一下其中的一些。</p>

<h3 id="gcd">将 GCD 当作递归锁使用</h3>

<p>GCD 是一个对共享资源的访问进行串行化的队列。这个特性可以被当作锁来使用，但实际上它和 <code>@synchronized</code> 有很大区别。 GCD队列并非是<a href="http://zh.wikipedia.org/w/index.php?title=可重入&amp;variant=zh-cn">可重入</a>的，因为这将破坏队列的特性。很多有试图使用 <code>dispatch_get_current_queue()</code> 来绕开这个限制，但是这是一个<a href="https://gist.github.com/steipete/3713233">糟糕的做法</a>，Apple 在 iOS6 中将这个方法标记为废弃，自然也是有自己的理由。</p>

```objc
// This is a bad idea.
inline void pst_dispatch_sync_reentrant(dispatch_queue_t queue, 
  dispatch_block_t block) 
{
    dispatch_get_current_queue() == queue ? block() 
                                          : dispatch_sync(queue, block);
}
```

<p>对当前的队列进行测试也许在简单情况下可以行得通，但是一旦你的代码变得复杂一些，并且你可能有多个队列在同时被锁住的情况下，这种方法很快就悲剧了。一旦这种情况发生，几乎可以肯定的是你会遇到<a href="http://objccn.io/issue-2-1/#dead_locks">死锁</a>。当然，你可以使用 <code>dispatch_get_specific()</code>，这将截断整个队列结构，从而对某个特定的队列进行测试。要这么做的话，你还得为了在队列中附加标志队列的元数据，而去写自定义的队列构造函数。嘛，最好别这么做。其实在实用中，使用 <code>NSRecursiveLock</code> 会是一个更好的选择。</p>

<h3 id="dispatch_async">用 dispatch_async 修复时序问题</h3>

<p>在使用 UIKit 的时候遇到了一些时序上的麻烦？很多时候，这样进行“修正”看来非常完美：</p>

```objc
dispatch_async(dispatch_get_main_queue(), ^{
    // Some UIKit call that had timing issues but works fine 
    // in the next runloop.
    [self updatePopoverSize];
});
```

<p>千万别这么做！相信我，这种做法将会在之后你的 app 规模大一些的时候让你找不着北。这种代码非常难以调试，并且你很快就会陷入用更多的 dispatch 来修复所谓的莫名其妙的"时序问题"。审视你的代码，并且找到合适的地方来进行调用（比如在 viewWillAppear 里调用，而不是 viewDidLoad 之类的）才是解决这个问题的正确做法。我在自己的代码中也还留有一些这样的 hack，但是我为它们基本都做了正确的文档工作，并且对应的 issue 也被一一记录过。</p>

<p>记住这不是真正的 GCD 特性，而只是一个在 GCD 下很容易实现的常见反面模式。事实上你可以使用 <code>performSelector:afterDelay:</code> 方法来实现同样的操作，其中 delay 是在对应时间后的 runloop。</p>

<h3 id="dispatch_syncdispatch_async">在性能关键的代码中混用 dispatch<em>sync 和 dispatch</em>async</h3>

<p>这个问题我花了好久来研究。在 <a href="http://pspdfkit.com">PSPDFKit</a> 中有一个使用了 LRU（最久未使用）算法列表的缓存类来记录对图片的访问。当你在页面中滚动时，这个方法将被调用<strong>非常多次</strong>。最初的实现使用了 <code>dispatch_sync</code> 来进行实际有效的访问，使用 <code>dispatch_async</code> 来更新 LRU 列表的位置。这导致了帧数远低于原来的 60 帧的目标。</p>

<p>当你的 app 中的其他运行的代码阻挡了 GCD 线程的时候，dispatch manager 需要花时间去寻找能够执行 dispatch_async 代码的线程，这有时候会花费一点时间。在找到合适的执行线程之前，你的同步调用就会被 block 住了。其实在这个例子中，异步情况的执行顺序并不是很重要，但没有能将这件事情告诉 GCD 的好办法。读/写锁这里并不能起到什么作用，因为在异步操作中基本上一定会需要进行顺序写入，而在此过程中读操作将被阻塞住。如果误用了 <code>dispatch_async</code> 代价将会是非常惨重的。在将它用作锁的时候，一定要非常小心。</p>

<h3 id="dispatch_async">使用 dispatch_async 来派发内存敏感的操作</h3>

<p>我们已经谈论了很多关于 NSOperations 的话题了，一般情况下，使用这个更高层级的 API 会是一个好主意。当你要处理一段内存敏感的操作的代码块时，这个优势尤为突出、</p>

<p>在 PSPDFKit 的老版本中，我用了 GCD 队列来将已缓存的 JPG 图片写到磁盘中。当 retina 的 iPad 问世之后，这个操作出现了问题。ß因为分辨率翻倍了，相比渲染这张图片，将它编码花费的时间要长得多。所以，操作堆积在了队列中，当系统繁忙时，甚至有可能因为内存耗尽而崩溃。</p>

<p>我们没有办法追踪有多少个操作在队列中等待运行（除非你手动添加了追踪这个的代码），我们也没有现成的方法来在接收到低内存通告的时候来取消操作、这时候，切换到 NSOperations 可以使代码变得容易调试得多，并且允许我们在不添加手动管理的代码的情况下，做到对操作的追踪和取消。</p>

<p>当然也有一些不好的地方，比如你不能在你的 <code>NSOperationQueue</code> 中设置目标队列（就像 <code>DISPATCH_QUEUE_PRIORITY_BACKGROUND</code> 之于 缓速 I/O 那样）。但这只是为了可调试性的一点小代价，而事实上这也帮助你避免遇到<a href="http://objccn.io/issue-2-1/#priority_inversion">优先级反转</a>的问题。我甚至不推荐直接使用已经包装好的 <code>NSBlockOperation</code> 的 API，而是建议使用一个 NSOperation 的真正的子类，包括实现其 description。诚然，这样做工作量会大一些，但是能输出所有运行中/准备运行的操作是及其有用的。</p>

<hr />