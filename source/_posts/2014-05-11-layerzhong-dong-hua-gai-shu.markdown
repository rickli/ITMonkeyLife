---
layout: post
title: "Layer中动画概述"
date: 2014-05-11 00:08:11 +0800
comments: true
categories: [iOS]
---
 <p>默认情况下，<code>CALayer</code> 及其子类的绝大部分标准属性都可以执行动画，无论是添加一个 <code>CAAnimation</code> 到 Layer（显式动画），亦或是为属性指定一个动作然后修改它（隐式动画）。</p>

<p>但有时候我们希望能同时为好几个属性添加动画，使它们看起来像是一个动画一样；或者，我们需要执行的动画不能通过使用标准 Layer 属性动画来实现。</p>

<p>在本文中，我们将讨论如何子类化 <code>CALayer</code> 并添加我们自己的属性，以便比较容易地创建那些如果以其他方式实现起来会很麻烦的动画效果。</p>

<p>一般说来，我们希望添加到 <code>CALayer</code> 的子类上的可动画属性有三种类型：</p>

<ul>
<li>能间接动画 Layer （或其子类）的一个或多个标准属性的属性。</li>
<li>能触发 Layer 背后的图像（即 <code>contents</code> 属性）重绘的属性。</li>
<li>不涉及 Layer 重绘或对任何已有属性执行动画的属性。</li>
</ul>

<h2 id="">间接属性动画</h2>

<p>能间接修改其它标准 Layer 属性的自定义属性是这些选项中最简单的。它们仅仅只是自定义 setter 方法。然后将它们的输入转换为适用于创建动画的一个或多个不同的值。</p>

<p>如果被我们设置的属性已经预设好标准动画，那我们完全不需要编写任何实际的动画代码，因为我们修改这些属性后，它们就会继承任何被配置在当前 <code>CATransaction</code> 上的动画设置，并且自动执行动画。</p>

<p>换句话说，即使 <code>CALayer</code> 不知道如何对我们自定义的属性进行动画，它依然能对因自定义属性被改变而引起的其它可见副作用进行动画，而这恰好就是我们所需要的。</p>

<p>为了演示这种方法，让我们来创建一个简单的模拟时钟，之后我们可以使用被声明为 <code>NSDate</code> 类型 <code>time</code> 属性来设置它的时间。我会将从创建一个静态的时钟面盘开始。这个时钟包含三个 <code>CAShapeLayer</code> 实例 —— 一个用于时钟面盘的圆形 Layer 和两个用于时针和分针的长方形 Sublayer。</p>
```objc
@interface ClockFace: CAShapeLayer

@property (nonatomic, strong) NSDate *time;

@end

@interface ClockFace ()

// 私有属性
@property (nonatomic, strong) CAShapeLayer *hourHand;
@property (nonatomic, strong) CAShapeLayer *minuteHand;

@end

@implementation ClockFace

- (id)init
{
    if ((self = [super init]))
    {
        self.bounds = CGRectMake(0, 0, 200, 200);
        self.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
        self.fillColor = [UIColor whiteColor].CGColor;
        self.strokeColor = [UIColor blackColor].CGColor;
        self.lineWidth = 4;

        self.hourHand = [CAShapeLayer layer];
        self.hourHand.path = [UIBezierPath bezierPathWithRect:CGRectMake(-2, -70, 4, 70)].CGPath;
        self.hourHand.fillColor = [UIColor blackColor].CGColor;
        self.hourHand.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        [self addSublayer:self.hourHand];

        self.minuteHand = [CAShapeLayer layer];
        self.minuteHand.path = [UIBezierPath bezierPathWithRect:CGRectMake(-1, -90, 2, 90)].CGPath;
        self.minuteHand.fillColor = [UIColor blackColor].CGColor;
        self.minuteHand.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        [self addSublayer:self.minuteHand];
    }
    return self;
}

@end
```
<!-- more -->
<p>同时我们要设置一个包含 <code>UIDatePicker</code> 的基本的 View Controller，这样我们就能测试我们的 Layer （日期选择器在 Storyboard 里设置）了：</p>

```objc
@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) ClockFace *clockFace;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 添加时钟面板 Layer
    self.clockFace = [[ClockFace alloc] init];
    self.clockFace.position = CGPointMake(self.view.bounds.size.width / 2, 150);
    [self.view.layer addSublayer:self.clockFace];

    // 设置默认时间
    self.clockFace.time = [NSDate date];
}

- (IBAction)setTime
{
    self.clockFace.time = self.datePicker.date;
}

@end
```

<p>现在我们只需要实现 <code>time</code> 属性的 setter 方法。这个方法使用 <code>NSCalendar</code> 将时间变为小时和分钟，之后我们将它们转换为角坐标。然后我们就可以使用这些角度去生成两个 <code>CGAffineTransform</code> 以旋转时针和分针。</p>

```objc
- (void)setTime:(NSDate *)time
{
    _time = time;

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:time];
    self.hourHand.affineTransform = CGAffineTransformMakeRotation(components.hour / 12.0 * 2.0 * M_PI);
    self.minuteHand.affineTransform = CGAffineTransformMakeRotation(components.minute / 60.0 * 2.0 * M_PI);
}
```

<p>结果看起来像这样：</p>

<p><img src="http://img.objccn.io/issue-12/clock.gif" width="320px"></p>

<p>你可以 <a href="https://github.com/objcio/issue-12-custom-layer-property-animations">从 GitHub 上</a> 下载这个项目看看。</p>

<p>如你所见，我们实在没有做什么太费脑筋的事情；我们并没有创建一个新的可动画属性，而只是在单个方法里设置了几个标准可动画 Layer 属性而已。然而，如果我们想创建的动画并不能映射到任何已有的 Layer 属性上时，该怎么办呢？</p>

<h2 id="layer">动画 Layer 内容</h2>

<p>假设不使用几个分离的 Layer 来实现我们的时钟面板，那我们可以改用 Core Graphics 来绘制时钟。（这通常会降低性能，但我们可以假想我们所要实现的效果需要许多复杂的绘图操作，而它们很难用常规的 Layer 属性和 transform 来复制。）我们要怎么做呢？</p>

<p>与 <code>NSManagedObject</code> 很类似， <code>CALayer</code> 具有为任何被声明的属性生成 dynamic 的 setter 和 getter 的能力。在我们当前的实现中，我们让编译器去 synthesize 了 <code>time</code> 属性的 ivar 和 getter 方法，而我们自己实现了 setter 方法。但让我们来改变一下：丢弃我们的 setter 并将属性标记为 <code>@dynamic</code> 。同时我们也丢弃分离的时针和分针 Layer ，因为我们将自己去绘制它们。</p>

```objc
@interface ClockFace ()

@end


@implementation ClockFace

@dynamic time;

- (id)init
{
    if ((self = [super init]))
    {
        self.bounds = CGRectMake(0, 0, 200, 200);
    }
    return self;
}

@end
```

<p>在我们开始之前，需要先做一个小调整：因为不幸的是，<code>CALayer</code> 不知道如何对 <code>NSDate</code> 属性进行插值（interpolate）（例如，虽然它可以处理数字类型和其它例如 <code>CGColor</code> 和 <code>CGAffineTransform</code> 这样的类型，但它不能自动生成不同的 <code>NSDate</code> 实例之间的中间值）。我们可以保留我们的自定义 setter 方法并用它设置另一个等价于 <code>NSTimeInterval</code> 的动态属性（这是一个数字值，可以被插值），但为了保持例子的简单性，我们会用一个浮点值替换 <code>NSDate</code> 属性来表征时钟的小时。我们还更新了用户界面，现在使用一个简单的 <code>UITextField</code> 来设置浮点值，而不再使用日期选择器：</p>

```objc
@interface ViewController () &lt;UITextFieldDelegate&gt;

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) ClockFace *clockFace;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 添加时钟面板 Layer
    self.clockFace = [[ClockFace alloc] init];
    self.clockFace.position = CGPointMake(self.view.bounds.size.width / 2, 150);
    [self.view.layer addSublayer:self.clockFace];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.clockFace.time = [textField.text floatValue];
}

@end
```

<p>现在，既然我们已经移除了自定义的 setter 方法，那我们要如何才能知晓 <code>time</code> 属性的改变呢？我们需要一个无论何时 <code>time</code> 属性改变时都能自动通知 <code>CALayer</code> 的方式，这样它才好重绘它的内容。我们通过覆写 <code>+needsDisplayForKey:</code> 方法即可做到这一点，如下：</p>

```objc
+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@"time" isEqualToString:key])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}
```

<p>这就告诉了 Layer ，无论何时 <code>time</code> 属性被修改，它都需要调用 <code>-display</code> 方法。现在我们就覆写 <code>-display</code> 方法，添加一个 <code>NSLog</code> 语句打印出 <code>time</code> 的值：</p>

```objc
- (void)display
{
    NSLog(@"time: %f", self.time);
}
```

<p>如果我们设置 <code>time</code> 属性为 1.5 ，我们就会看到 <code>-display</code> 被调用，打印出新值：</p>

<pre><code>2014-04-28 22:37:04.253 ClockFace[49145:60b] time: 1.500000
</code></pre>

<p>但这还不是我们真正想要的；我们希望 <code>time</code> 属性能在旧值和新值之间在几帧之内做一个平滑的过渡动画。为了实现这一点，我们需要为 <code>time</code> 属性指定一个动画（或“动作（action）”），而通过覆写 <code>-actionForKey:</code> 方法就能做到：</p>

```objc
- (id&lt;CAAction&gt;)actionForKey:(NSString *)key
{
    if ([key isEqualToString:@"time"])
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @(self.time);
        return animation;
    }
    return [super actionForKey:key];
}
```

<p>现在，如果我们再次设置 <code>time</code> 属性，我们就会看到 <code>-display</code> 被多次调用。调用的次数大约为每秒 60 次，至于动画的长度，默认为 0.25 秒，大约是 15 帧：</p>

<pre><code>2014-04-28 22:37:04.253 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.255 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.351 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.370 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.388 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.407 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.425 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.443 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.461 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.479 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.497 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.515 ClockFace[49145:60b] time: 1.500000
2014-04-28 22:37:04.755 ClockFace[49145:60b] time: 1.500000
</code></pre>

<p>由于某些原因，当我们在每个中间点打印 <code>time</code> 值时，我们一直看到的是最终值。为何不能得到插值呢？因为我们查看的是错误的 <code>time</code> 属性。</p>

<p>当你设置某个 <code>CALayer</code> 的某个属性，你实际设置的是 <em>model</em> Layer 的值 —— 这里的 <em>model</em> Layer 表示正在进行的动画结束时， Layer 所达到的最终状态。如果你取 <em>model</em> Layer 的值，它就总是给你它被设置到的最终值。</p>

<p>但连接到 <em>model</em> Layer 的是所谓的 <em>presentation</em> Layer ——它是 <em>model</em> Layer 的一个拷贝，但它的值所表示的是 <em>当前的</em>，中间动画状态。如果我们修改 <code>-display</code> 方法去打印 Layer 的 <code>presentationLayer</code> 的 <code>time</code> 属性，那我们就会看到我们所期望的插值。（同时我们也使用 <code>presentationLayer</code> 的 <code>time</code> 属性来获取动画的开始值，替代 <code>self.time</code> ）：</p>

```objc
- (id<CAAction>)actionForKey:(NSString *)key
{
    if ([key isEqualToString:@"time"])
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @([[self presentationLayer] time]);
        return animation;
    }
    return [super actionForKey:key];
}

- (void)display
{
    NSLog(@"time: %f", [[self presentationLayer] time]);
}
```

<p>下面是打印出的值：</p>

<pre><code>2014-04-28 22:43:31.200 ClockFace[49176:60b] time: 0.000000
2014-04-28 22:43:31.203 ClockFace[49176:60b] time: 0.002894
2014-04-28 22:43:31.263 ClockFace[49176:60b] time: 0.363371
2014-04-28 22:43:31.300 ClockFace[49176:60b] time: 0.586421
2014-04-28 22:43:31.318 ClockFace[49176:60b] time: 0.695179
2014-04-28 22:43:31.336 ClockFace[49176:60b] time: 0.803713
2014-04-28 22:43:31.354 ClockFace[49176:60b] time: 0.912598
2014-04-28 22:43:31.372 ClockFace[49176:60b] time: 1.021573
2014-04-28 22:43:31.391 ClockFace[49176:60b] time: 1.134173
2014-04-28 22:43:31.409 ClockFace[49176:60b] time: 1.242892
2014-04-28 22:43:31.427 ClockFace[49176:60b] time: 1.352016
2014-04-28 22:43:31.446 ClockFace[49176:60b] time: 1.460729
2014-04-28 22:43:31.464 ClockFace[49176:60b] time: 1.500000
2014-04-28 22:43:31.636 ClockFace[49176:60b] time: 1.500000
</code></pre>

<p>所以现在我们所要做就是画出时钟。我们将使用普通的 Core Graphics 函数以绘制到一个 Graphics Context 上来做到这一点，然后将产生出图像设置为我们 Layer 的 <code>contents</code>。下面是更新后的 <code>-display</code> 方法：</p>

```objc
- (void)display
{
    // 获取时间插值
    float time = [self.presentationLayer time];

    // 创建绘制上下文
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // 绘制时钟面板
    CGContextSetLineWidth(ctx, 4);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 2, 2));

    // 绘制时针
    CGFloat angle = time / 12.0 * 2.0 * M_PI;
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextSetLineWidth(ctx, 4);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddLineToPoint(ctx, center.x + sin(angle) * 80, center.y - cos(angle) * 80);
    CGContextStrokePath(ctx);

    // 绘制分针
    angle = (time - floor(time)) * 2.0 * M_PI;
    CGContextSetLineWidth(ctx, 2);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddLineToPoint(ctx, center.x + sin(angle) * 90, center.y - cos(angle) * 90);
    CGContextStrokePath(ctx);

    //set backing image 设置 contents 
    self.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}
```

<p>结果看起来如下：</p>

<p><img src="http://img.objccn.io/issue-12/clock2.gif" width="320px"></p>

<p>如你所见，不同于第一个时钟动画，随着时针的变化，分针实际上对每一个小时都会转上满满一圈（就像一个真正的时钟那样），而不仅仅只是通过最短的路径移动到它的最终位置；因为我们正在动画的是 <code>time</code> 值本身而不仅仅是时针或分针的位置，所以上下文信息被保留了。</p>

<p>通过这样的方式绘制一个时钟并不是很理想，因为 Core Graphics 函数没有硬件加速，可能会引起动画帧数的下降。另一种能每秒重绘 <code>contents</code> 图像 60 次的方式是用一个数组存储一些预先绘制好的图像，然后基于合适的插值简单的选择对应的图像即可。实现代码大概如下：</p>

```objc
const NSInteger hoursOnAClockFace = 12;

- (void)display
{
    // 获取时间插值 
    float time = [self.presentationLayer time] / hoursOnAClockFace;

    // 从之前定义好的图像数组里获取图像帧
    NSInteger numberOfFrames = [self.frames count];
    NSInteger index = round(time * numberOfFrames) % numberOfFrames;
    UIImage *frame = self.frames[index];
    self.contents = (id)frame.CGImage;
}
```

<p>通过避免在每一帧里都用昂贵的软件绘制，我们能改善动画的性能，但代价是我们需要在内存里存储所有预先绘制的动画帧图像，对于一个复杂的动画来说，这可能造成惊人的内存浪费。</p>

<p>但这提出了一个有趣的可能性。如果我们完全不在 <code>-display</code> 里更新 <code>contents</code> 图像会发生什么？我们做一些其它的事情怎样？</p>

<h2 id="">非可视属性的动画</h2>

<p>在 <code>-display</code> 里更新其它 Layer 属性就是不必要的，因为我们可以很简单地直接对任何这样的属性做动画，如同我们在第一个时钟面板例子里所做的那样。但如果我们设置一些其它的东西，比如某些完全和 Layer 不相关的东西，会怎样呢？</p>

<p>下面的代码使用一个 <code>CALayer</code> 结合 <code>AVAudioPlayer</code> 来创建一个可动画的音量控制器。通过把音量绑定到 dynamic 的 Layer 属性上，我们可以使用 Core Animation 的属性插值来平滑的在两个不同的音量之间渐变，以同样的方式我们可以动画 Layer 上的任何自定义属性：</p>

```objc
@interface AudioLayer : CALayer

- (id)initWithAudioFileURL:(NSURL *)URL;

@property (nonatomic, assign) float volume;

- (void)play;
- (void)stop;
- (BOOL)isPlaying;

@end


@interface AudioLayer ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end


@implementation AudioLayer

@dynamic volume;

- (id)initWithAudioFileURL:(NSURL *)URL
{
    if ((self = [self init]))
    {
        self.volume = 1.0;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:NULL];
    }
    return self;
}

- (void)play
{
    [self.player play];
}

- (void)stop
{
    [self.player stop];
}

- (BOOL)isPlaying
{
    return self.player.playing;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@"volume" isEqualToString:key])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id&lt;CAAction&gt;)actionForKey:(NSString *)key
{
    if ([key isEqualToString:@"volume"])
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @([[self presentationLayer] volume]);
        return animation;
    }
    return [super actionForKey:key];
}

- (void)display
{
    // 设置音量值为合适的音量插值
    self.player.volume = [self.presentationLayer volume];
}

@end
```

<p>我们可以通过使用一个简单的有着播放、停止、音量增大以及音量减小按钮的 View Controller 来做测试：</p>

```objc
@interface ViewController ()

@property (nonatomic, strong) AudioLayer *audioLayer;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *musicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"caf"]];
    self.audioLayer = [[AudioLayer alloc] initWithAudioFileURL:musicURL];
    [self.view.layer addSublayer:self.audioLayer];
}

- (IBAction)playPauseMusic:(UIButton *)sender
{
    if ([self.audioLayer isPlaying])
    {
        [self.audioLayer stop];
        [sender setTitle:@"Play Music" forState:UIControlStateNormal];
    }
    else
    {
        [self.audioLayer play];
        [sender setTitle:@"Pause Music" forState:UIControlStateNormal];
    }
}

- (IBAction)fadeIn
{
    self.audioLayer.volume = 1;
}

- (IBAction)fadeOut
{
    self.audioLayer.volume = 0;
}

@end
```

<p>注意：尽管我们的 Layer 没有可见的外观，但它依然需要被添加到屏幕上的视图层级里，以便动画能正常工作。</p>

<h2 id="">结论</h2>

<p><code>CALayer</code> 的 dynamic 属性提供了一中简单的机制来实现任何形式的动画 —— 不仅仅只是内建的那些。而通过覆写 <code>-display</code>  方法，我们可以使用这些属性去控制任何我们想控制的东西，甚至是音量值这样的东西。</p>

<p>通过使用这些属性，我们不仅仅避免了重复造轮子，同时还确保了我们的自定义动画能与标准动画的时机和控制函数协同工作，以此就能非常容易地与其它动画属性同步。</p>

<hr />