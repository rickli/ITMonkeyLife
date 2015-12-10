---
layout: post
title: "自定义ViewController动画"
date: 2014-05-13 15:45:26 +0800
comments: true
categories: [iOS]
---
 <p>在<a href="http://objccn.io/issue-5/">话题 #5</a> 中，<a href="http://twitter.com/chriseidhof">Chris Eidhof</a> 向我们介绍了 iOS7 引入的新特性自定义 <a href="http://objccn.io/issue-5-3">View Controller 转场</a>. 他给出了一个 <a href="http://objccn.io/issue-5-3/#conclusion">结论</a>：</p>

<blockquote>
  <p>我们在本文只探讨了在 navigation controller 中的两个 view controller 之间的转场动画，但是这些做法在 tab bar controller 或者<strong>任何你自己定义的 view controller 容器</strong>中<strong>也是通用的</strong>… </p>
</blockquote>

<p>尽管从技术角度来讲，使用 iOS 7 的 API，你可以对自定义容器中的 view controllers 做自定义转场，但是这不是能直接使用的，实现这种效果非常不容易。</p>

<p>请注意我正在讨论的自定义视图控制器容器 (custom container view controllers) 都是 <code>UIViewController</code> 的直接子类，而不是 <code>UITabBarController</code> 或者 <code>UINavigationController</code> 的子类。</p>

<p>对于你自定义的继承于 <code>UIViewController</code> 的容器子类，并没有现成可用的 API 允许一个任意的<em>动画控制器 (animation controller)</em> 将一个子视图控制器自动转场到另外一个，不管是可交互式的转场还是不可交互式的转场。 我甚至都觉着苹果根本就不想支持这种方式。苹果支持下面的这几种转场方式:</p>

<ul>
<li>Navigation controller 推入和推出页面</li>
<li>Tab bar controller 选择的改变</li>
<li>Modal 页面的展示和消失</li>
</ul>

<p>在本文中，我将向你展示如何自定义视图控制器容器，并且使其支持第三方的动画控制器。</p>

<p>如果你需要复习一下 iOS 5 引入的视图控制器容器，请阅读<a href="http://objccn.io/issue-1/">话题＃1</a> 中 <a href="https://twitter.com/rickigregersen">Ricky Gregersen</a> 写的文章 “<a href="http://objccn.io/issue-1-4/">View Controller 容器</a>”。</p>

<h2 id="">预热准备</h2>

<p>看到这里，你可能对上文我们说到的一些问题犯嘀咕，让我来告诉你答案吧:</p>

<p><em>为什么我们不直接继承 <code>UINavigationController</code> 或 <code>UITabBarController</code>，并且使用它们提供的功能的？</em></p>
<!-- more -->
<p>有些时候这是你不想要的。可能你想要一个非常特殊的外观或者行为，和这些类能够提供给你的差别非常大，因此你必须使用一些黑客式的手段去达到你想要的结果，同时还要担心系统框架的版本更新后这些黑客式的手段是否还仍然有效。或者，你就是想完全控制你的视图控制器容器，避免不得不支持一些特定的功能。</p>

<p><em>好吧, 那么为什么不使用  <pre><code>transitionFromViewController:toViewController:duration:options:animations:completion:</code></pre> 去实现呢？</em></p>

<p>这又是一个好问题，你可能想用这种方式去实现，但是或许你对代码的整洁性比较在意，想把这种转场相关的代码封装在内部。那么为什么不使用一个既存的、被良好验证的设计模式呢？这种设计模式可以非常方便的支持第三方的转场动画。</p>

<h2 id="api">介绍相关的API</h2>

<p>在我们开始写代码之前，让我们先花一分钟的时间来简单看一下我们需要的组件吧。</p>

<p>iOS 7 自定义视图控制器转场的 API 基本上都是以协议的方式提供的，这也使其可以非常灵活的使用，因为你可以很简单地将它们插入到你的类中。最主要的五个组件如下:</p>

<ol>
<li><strong>动画控制器 (Animation Controllers)</strong> 遵从 <code>UIViewControllerAnimatedTransitioning</code> 协议，并且负责实际执行动画。  </li>
<li><strong>交互控制器 (Interaction Controllers)</strong> 通过遵从 <code>UIViewControllerInteractiveTransitioning</code> 协议来控制可交互式的转场。  </li>
<li><strong>转场代理 (Transitioning Delegates)</strong> 根据不同的转场类型方便的提供需要的动画控制器和交互控制器。  </li>
<li><strong>转场上下文 (Transitioning Contexts)</strong> 定义了转场时需要的元数据，比如在转场过程中所参与的视图控制器和视图的相关属性。 转场上下文对象遵从 <code>UIViewControllerContextTransitioning</code> 协议，<em>并且这是由系统负责生成和提供的</em>。2.  </li>
<li><strong>转场协调器(Transition Coordinators)</strong> 可以在运行转场动画时，并行的运行其他动画。 转场协调器遵从 <code>UIViewControllerTransitionCoordinator</code> 协议。</li>
</ol>

<p>正如你从其他的阅读材料中得知的那样，转场有不可交互式和可交互式两种方式。在本文中，我们将集中精力于不可交互的转场。这种转场是最简单的转场，也是我们学习的一个好的开始。这意味着我们需要处理上面提到的<em>动画控制器 (animation controllers)</em>，<em>转场代理 (transitioning delegates)</em> 和<em>转场上下文 (transitioning contexts)</em>。</p>

<p>闲话少说，让我们开始动手吧…</p>

<h2 id="">示例工程</h2>

<p>通过三个阶段，我们将要实现一个简单自定义的视图控制器容器，它可以对子视图控制器提供自定义的转场动画的支持。</p>

<p>你可以在<a href="https://github.com/objcio/issue-12-custom-container-transitions">这里</a>找到这三个阶段的 Xcode 工程的源代码。</p>

<h3 id="1">阶段 1: 基础</h3>

<p>我们应用中的核心类是 <code>ContainerViewController</code>，它持有一个<code>UIViewController</code>实例的数组，每个实例是一个普通的 <code>ChildViewController</code>。容器视图控制器设置了一个带有可点击图标，并代表每个子视图控制器的私有的子视图：</p>

<p><img src="http://img.objccn.io/issue-12/2014-05-01-custom-container-view-controller-transitions-stage-1.gif" alt="Stage 1: no animation" /></p>

<p>我们通过点击图标在不同的子视图控制器之间切换。在这一阶段，子视图控制器之间切换时是没有转场动画的。</p>

<p>你可以在这里查看<a href="https://github.com/objcio/issue-12-custom-container-transitions/tree/stage-1">阶段－1</a>的源代码。</p>

<h3 id="2">阶段 2: 转场动画</h3>

<p>当我们添加转场动画时，我们想要使用一个遵从 <code>UIViewControllerAnimatedTransitioning</code> 协议的<em>动画控制器(animation controllers)</em>。这个协议声明了 3 个方法，前面的 2 个方法是必须实现的：</p>

```objc
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)animationEnded:(BOOL)transitionCompleted;  
```

<p>通过这些方法，我们可以获得我们所需的所有东西。当我们的视图控制器容器准备执行动画时，我们可以从动画控制器中获取动画的持续时间，并让其去执行真正的动画。当动画执行完毕后，如果动画控制器实现了可选的 <code>animationEnded:</code> 方法，我们可以调用动画控制器中的 <code>animationEnded:</code> 方法。</p>

<p>但是，首先我们必须把一件事情搞清楚。正如你在上面的方法签名中看到的那样，上面两个必须实现的方法需要一个<em>转场上下文</em>参数，这是一个遵从 <code>UIViewControllerContextTransitioning</code> 协议的对象。通常情况下，当我们使用系统内建的类时，系统框架为我们创建了<em>转场上下文</em>对象，并把它传递给动画控制器。但是在我们这种情况下，我们需要自定义转场动画，所以我们需要承担系统框架的责任，<em>自己</em>去创建这个<em>转场上下文</em>对象。</p>

<p>这就是大量使用协议的方便之处。我们可以不用必须复写一个私有类，而复写私有类这种方法是明显不可行的。我们可以定义自己的类，并使其遵从文档中相应的协议就可以了。</p>

<p>尽管在 <code>UIViewControllerContextTransitioning</code> 协议中声明了<a href="https://developer.apple.com/library/ios/documentation/uikit/reference/UIViewControllerContextTransitioning_protocol/Reference/Reference.html">很多方法</a>，而且它们都是必须要实现 (required) 的，但是我们现在可以暂时忽略它们中的一些方法，因为我们现在仅仅支持不可交互式的转场。</p>

<p>同 UIKit 类似，我们定义了一个私有类 <code>NSObject &lt;UIViewControllerContextTransitioning&gt;</code>。在我们的特定例子中，这个私有类是 <code>PrivateTransitionContext</code>，它的初始化方法如下实现：</p>

```objc
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");

    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.viewControllers = @{
            UITransitionContextFromViewControllerKey:fromViewController,
            UITransitionContextToViewControllerKey:toViewController,
        };

        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.disappearingFromRect = self.appearingToRect = self.containerView.bounds;
        self.disappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.appearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }

    return self;
}
```

<p>我们把视图的出现和消失时的状态记录了下来，比如初始状态和最终状态的 frame。</p>

<p>请注意一点，我们的初始化方法需要我们提供我们是在向右切换还是向左切换。在我们的 <code>ContainerViewController</code> 中，按钮是一个接一个水平排列的，转场上下文通过设置每个的 frame 来记录它们之间的位置关系。动画控制器或者说 <em>animator</em>，在生成动画时可以使用这些 frame。</p>

<p>我们也可以通过另外的方式去获取这些信息，但是那样的话，就会使 animator 和 <code>ContainerViewController</code> 及其视图控制器耦合在一起了，这是不好的，我们并不想这样。animator 应该只关心它自己以及传递给它的上下文，因为这样，在理想情况下，animator 可以在不同的上下文中得到复用。</p>

<p>在下一步实现我们自己的动画控制器时，我们应该时刻记住这一点，现在让我们来实现转场上下文吧。</p>

<p>你可能记得我们在 <a href="http://objccn.io/issue-5/">issue #5</a> 中的<a href="http://objccn.io/issue-5-3/">View Controller 转场</a>已经做过相同的事情了，为什么我们不使用它呢？事实上，由于使用了非常灵活的协议，我们可以直接把那个工程中的动画控制器，也就是 <code>Animator</code> 类直接拿过来使用，不需要任何修改。</p>

<p>使用 <code>Animator</code> 类的实例来做转场动画的核心代码如下所示：</p>

```objc
[fromViewController willMoveToParentViewController:nil];
[self addChildViewController:toViewController];

Animator *animator = [[Animator alloc] init];

NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight:toIndex > fromIndex];

transitionContext.animated = YES;
transitionContext.interactive = NO;
transitionContext.completionBlock = ^(BOOL didComplete) {
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [toViewController didMoveToParentViewController:self];
};

[animator animateTransition:transitionContext];
```

<p>这其中的大部分是在对视图控制器容器的操作，计算出我们是在向左切换还是向右切换。做动画的部分基本上只有 3 行代码：1) 创建 animator，2) 创建转场上下文，和 3) 触发动画执行。</p>

<p>有了上面的代码，转场效果看起来如下图所示:</p>

<p><img src="http://img.objccn.io/issue-12/2014-05-01-custom-container-view-controller-transitions-stage-2.gif" alt="Stage 2: third-party animation" /></p>

<p>非常酷，我们甚至没有写一行动画相关的代码。</p>

<p>你可以在 <a href="https://github.com/objcio/issue-12-custom-container-transitions/tree/stage-2">阶段-2</a> 标签下看到这部分代码的变化。在<a href="https://github.com/objcio/issue-12-custom-container-transitions/compare/stage-1...stage-2">与 阶段－1 的对比</a>这里你可以看到 阶段-2 和 阶段-1 相对比的完整的代码改变。</p>

<h3 id="3">阶段 3: 封装</h3>

<p>我想我们最后要做的一件事情是封装 <code>ContainerViewController</code> ，使其能够：</p>

<ol>
<li>提供默认的转场动画。  </li>
<li>提供替换默认动画控制器的代理。</li>
</ol>

<p>这意味着我们需要把对 <code>Animator</code> 类的依赖移除，同时需要创建一个代理协议。</p>

<p>我们如下定义这个协议:</p>

```objc
@protocol ContainerViewControllerDelegate <NSObject>
@optional
- (void)containerViewController:(ContainerViewController *)containerViewController didSelectViewController:(UIViewController *)viewController;
- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(ContainerViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;
@end
```

<p><code>containerViewController:didSelectViewController:</code> 方法使 <code>ContainerViewController</code> 可以很更容易的集成于功能齐全的应用中。 </p>

<p><code>containerViewController:animationControllerForTransitionFromViewController:toViewController:</code> 方法挺有趣的，当然，你可以把它和下面的 UIKit 中的视图控制器容器的代理协议做对比：</p>

<ul>
<li><code>tabBarController:animationControllerForTransitionFromViewController:toViewController:</code> (<code>UITabBarControllerDelegate</code>)</li>
<li><code>navigationController:animationControllerForOperation:fromViewController:toViewController:</code> (<code>UINavigationControllerDelegate</code>)</li>
</ul>

<p>所有的这些方法都返回一个 <code>id&lt;UIViewControllerAnimatedTransitioning&gt;</code> 对象。</p>

<p>与之前一直使用一个 <code>Animator</code> 对象不同, 我们现在可以从我们的代理那里获取一个动画控制器：</p>

<pre><code>id&lt;UIViewControllerAnimatedTransitioning&gt;animator = nil;
if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
    animator = [self.delegate containerViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
}
animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);
</code></pre>

<p>如果我们有代理并且它返回了一个 animator，那么我们就使用这个 animator。否则，我们使用内部私有类 <code>PrivateAnimatedTransition</code> 创建一个默认的 animator。接下来我们将实现 <code>PrivateAnimatedTransition</code> 类。</p>

<p>尽管默认的动画和 <code>Animator</code> 有一些不同，但是代码看起来惊人的相似。下面是完整的代码实现:</p>

```objc
@implementation PrivateAnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75f;
static CGFloat const kInitialSpringVelocity = 0.5f;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    // When sliding the views horizontally, in and out, figure out whether we are going left or right.
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x > [transitionContext finalFrameForViewController:toViewController].origin.x);

    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);

    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = travel;
        fromViewController.view.alpha = 0;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
```p

<p>需要注意的一点是，上面的代码没有通过设置视图的 frame 来反应它们之间的位置关系，但是代码仍然可以正常工作，只不过转场总是在同一个方向上。因此，这个类也可以被其他的代码库使用。</p>

<p>转场动画现在看起来如下所示:</p>

<p><img src="http://img.objccn.io/issue-12/2014-05-01-custom-container-view-controller-transitions-stage-3.gif" alt="Stage 3: third-party animation" /></p>

<p>在 <a href="https://github.com/objcio/issue-12-custom-container-transitions/tree/stage-3">阶段-3</a> 的代码中，app delegate 中设置代理的部分被<a href="https://github.com/objcio/issue-12-custom-container-transitions/blob/stage-3/Container%20Transitions/AppDelegate.m#L41">注释掉了</a>，这样就可以看到默认的动画效果了。你可以将其设置回再使用 <code>Animator</code> 类。你可能想查看<a href="https://github.com/objcio/issue-12-custom-container-transitions/compare/stage-2...stage-3">同 阶段－2 相比所有的修改</a>。</p>

<p>我们现在有一个自包含的提供了默认转场动画的 <code>ContainerViewController</code> 类，这个默认的转场动画可以被开发者自己定义的iOS 7 自定义动画控制器 (<code>UIViewControllerAnimatedTransitioning</code>) 的对象代替，甚至都可以不用关心我们的源代码就可以方便的替换。</p>

<h2 id="">结论</h2>

<p>在本文中我们通过使用 iOS 7 提供的自定义视图控制器转场的新特性，使我们自定义的视图控制器容器成为了 UIKit 的一等公民。</p>

<p>这意味着你可以把自定义的非交互式的转场动画应用到自定义的视图控制器容器中。你可以看到我们把 7 个话题之前使用的转场类直接拿过来使用，而且没有做任何修改。</p>

<blockquote>
  <p><span class="secondary radius label">译者注</span> 即 <a href="http://objccn.io/issue-5/">issue #5</a> 中的 <a href="http://objccn.io/issue-5-3/">View Controller 转场</a>中的 <code>Animator</code> 类。</p>
</blockquote>

<p>如果你想让自己的容器视图控制器作为一个类库或者框架，或者仅仅想使你的代码得到更好的复用，这将是非常完美的。</p>

<p>我们现在仅仅支持非交互式的转场，下一步就是对交互式的转场也提供支持。</p>

<p>我把它留给你当作一个练习。这有一些复杂，因为我们基本上是要模仿系统的行为，而这真的全是猜测性的工作。</p>

<h2 id="">扩展资料</h2>

<ul>
<li>2014 年的 iOS 7 Tech Talks 视频: <a href="https://developer.apple.com/tech-talks/videos/index.php?id=3#3">“Architecting Modern Apps, Part 1”</a> (07:23-31:27)</li>
<li>全部代码都放在 <a href="https://github.com/objcio/issue-12-custom-container-transitions">GitHub</a></li>
</ul>

<hr />