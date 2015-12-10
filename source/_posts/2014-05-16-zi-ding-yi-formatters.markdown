---
layout: post
title: "自定义Formatters"
date: 2014-05-16 14:09:57 +0800
comments: true
categories: [iOS]
---
<p>我们希望有一种快速的一次性的解决方案，可以把数据格式化为一种易读的格式。Foundation 框架中的就有 <code>NSFormatter</code> 可以很好地胜任这个工作。另外，在 Mac 上，Appkit 已经内建了 <code>NSFormatter</code> 的支持。</p>

<h2 id="">内建格式器</h2>

<p>Foundation 框架中的 <code>NSFormatter</code> 是一个抽象类，它有两个已经实现的子类：<code>NSNumberFormatter</code> 与 <code>NSDateFormatter</code>。现在我们先跳过这些，来实现我们自己的子类。</p>

<p>如果你想了解更多的相关知识，我推荐阅读 <a href="http://nshipster.com/nsformatter/">NSHipster</a>。</p>

<h2 id="">介绍</h2>

<p><code>NSFormatter</code> 除了抛出错误，其它什么事也不做。我还不知道有人想要用这个，当然如果它对你有用，就去用它吧。</p>

<p>因为我们不喜欢错误，我们在此实现一个 <code>NSFormatter</code> 的子类，它可以把 <code>UIColor</code> 实例转换成可读的名字。例如，以下代码可以返回字符串“Blue”:</p>

<pre><code>KPAColorFormatter *colorFormatter = [[KPAColorFormatter alloc] init];
[colorFormatter stringForObjectValue:[UIColor blueColor]] // Blue
</code></pre>

<p><code>NSFormatter</code> 的子类化有两个方法需要实现：<code>stringForObjectValue:</code> 与 <code>getObjectValue:ForString:errorDescription:</code>。我们先开始介绍第一个方法，因为这个方法更常用。第二个方法，就我所知，经常用于 OS X 上，并且通常不是很有用，我们将稍后介绍。</p>

<h2 id="">初始化</h2>

<p>首先，我们需要做些初始化的工作。由于没有事先定义好的字典可以把颜色映射至名字，这些工作将由我们来完成。为了简化，这些工作将在初始化方法中完成：</p>

```objc
- (id)init;
{
    return [self initWithColors:@{
        [UIColor redColor]: @"Red",
        [UIColor blueColor]: @"Blue",
        [UIColor greenColor]: @"Green"
    }];
}
```
<!-- more -->
<p>这里的 colors 是一个以 <code>UIColor</code> 实例为键，英语名为值的字典。大家可以自行地去实现 <code>initWithColors:</code> 方法。当然你也可以自行实现，或者直接前往 <a href="https://github.com/klaaspieter/KPAColorFormatter">Github repo</a> 获得答案。</p>

<h2 id="">格式化对象值</h2>

<p>由于我们这里只可以格式化 <code>UIColor</code> 实例对象，于是在方法 <code>stringForObjectValue:</code> 中的第一件事就是判断传入的参数类型是否是 <code>UIColor</code> 类。</p>

```
- (NSString *)stringForObjectValue:(id)value;
{
    if (![value isKindOfClass:[UIColor class]]) {
        return nil;
    }

    // To be continued...
}
```

<p>在判断参数合法后，我们可以实现真正的逻辑了。我们的格式器中包含一个 <code>UIColor</code> 对象为键，颜色名为值的字典。因此，我们只需要以 <code>UIColor</code> 对象为键找到对应的值：</p>

```objc
- (NSString *)stringForObjectValue:(id)value;
{
    // Previously on KPAColorFormatter

    return [self.colors objectForKey:value];
}
```

<p>以上代码是一个尽可能简单的实现。一个更高级（有用）的格式器应该是在我们的颜色字典中没有找到匹配的颜色时，返回一个最接近的颜色。大家可以自行实现，或是你不想花费太多功夫，可以前往 <a href="https://github.com/klaaspieter/KPAColorFormatter">Github repo</a>。</p>

<h2 id="">反向格式化</h2>

<p>我们的格式器也应该支持反向格式化，即把字符串转成实例对象。这是通过 <code>getObjectValue:forString:errorDescription:</code> 方法实现。在 OS X 上，在使用 <code>NSCell</code> 时会经常用到这个方法。</p>

<p><code>NSCell</code> 有一个 <code>objectValue</code> 属性。默认情况下，<code>NSCell</code> 会用 <code>objectValue</code> 的描述，但是它也可以选择用一个格式器。在用 <code>NSTextFieldCell</code> 时，用户可以输入值，作为程序员，我们可能期望 <code>objedctValue</code> 可以根据根据输入的字符串转成一个 <code>UIColor</code> 实例。例如，用户如果输入“Blue”，我们需要返回一个 <code>[UIColor blueColor]</code> 实例的引用。</p>

<p>实现反向格式化分为两部分：一部分为当格式器可以成功地把字符串转成 <code>UIColor</code> 实例，另一部分当其不能成功转换。第一部分代码如下：</p>

```objc
- (BOOL)getObjectValue:(out __autoreleasing id *)obj 
             forString:(NSString *)string 
      errorDescription:(out NSString *__autoreleasing *)error;
{
    __block UIColor *matchingColor = nil;
    [self.colors enumerateKeysAndObjectsUsingBlock:^(UIColor *color, NSString *name, BOOL *stop) {
        if([name isEqualToString:string]) {
            matchingColor = color;
            *stop = YES;
        }
    }];

    if (matchingColor) {
        *obj = matchingColor;
        return YES;
    } // Snip
```

<p>这里可以做一些优化，但是我们先不去做这些。以上方法会遍历我们颜色字典里的每一个对象 ，当一个颜色名字找到时，则会返回其对应关联的 <code>UIColor</code> 实例对象的引用，同时返回 YES 告知调用者我们已经成功地把字符串转成了一个 <code>UIColor</code> 实例对象。</p>

<p>现在处理第二部分：</p>

```objc
if (matchingColor) {
    // snap
} else if (error) {
    *error = [NSString stringWithFormat:@"No known color for name: %@", string];
}

return NO;
```

<p>这里，我们如果不能找到一个匹配的颜色，我们会检测调用者是否需要错误信息，如果需要，则把错误通过引用返回。这里检查错误很重要。如果你不这样做，程序就会 crash。同时，我们也会返回 NO，告知调用者这次转换失败。</p>

<h2 id="">本地化</h2>

<p>到现在，我们已经建立了一个完全功能的 <code>NSFormatter</code> 的子类，当然这只是对于生活在美国的英语使用者而言有用。</p>

<p>但相比全世界 71.3 亿人，那才 3.19 亿。或者说，你还有 96% 的潜在用户。当然你可以说：这些潜在用户绝大部分都不是 iPhone 或 Mac 使用者，这么做有什么意思呢？这么想你就太扫兴了。</p>

<p><code>NSNumberFormatter</code> 与 <code>NSDateFormatter</code> 都有一个 locale 属性，它是 <code>NSLocale</code> 实例对象。我们现在来扩展格式器以支持本地化，让它可以根据 local 属性来返回对应翻译的名字。</p>

<h3 id="">翻译</h3>

<p>首先，我们需要翻译颜色名字字符串。有关 genstring 与 *.lprojs 超出了本文的范围。有<a href="http://www.getlocalization.com/library/get-localization-mac/">很多文章</a>讨论这点。好了，不需要其它工作了，快要结束了。</p>

<h3 id="">本地化的格式化</h3>

<p>接下来是本地化功能的实现。在获取翻译的字符串后，我们需要更新 <code>stringForObejectValue:</code> 方法。以前已经使用过 <code>NSLocalizedString</code> 的人可能已经早早的把每一个字符串都用 <code>NSLocalizedString</code> 替换了。但是我们不会这么做。</p>

<p>我们现在处理的是一个动态的 local，而 <code>NSLocalizedString</code> 只会查找当前默认的语言的翻译。在99%的情况下，这种默认的行为是你所想要的，但是我们会用格式化器的 locale 属性来动态查询语言。</p>

<p>以下是 <code>stringForObjectValue:</code> 的新的实现：</p>

```objc
- (NSString *)stringForObjectValue:(id)value;
{
    // Previously on... don't you hate these? I just watched that 20 seconds ago!

    NSString *languageCode = [self.locale objectForKey:NSLocaleLanguageCode];
    NSURL *bundleURL = [[NSBundle bundleForClass:self.class] URLForResource:languageCode 
                                                              withExtension:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithURL:bundleURL];
    return [languageBundle localizedStringForKey:name value:name table:nil];
}
```

<p>上面的代码还有可以重构改进的地方，但因为把代码都放在同一个地方可以方便阅读，所以请大家多多包涵了。</p>

<p>首先，我们通过 locale 属性查找相应的语言，之后通过 NSBundle 找到对应的语言代码。最后，我们会让 bundle 对英语名称进行翻译。如果找不到对应的翻译，则会返回 name: 方法的参数（即英语名称）。如上即是 <code>NSLocalizedString</code> 的具体实现。</p>

<h3 id="">本地化的反向格式化</h3>

<p>同样，我们也可以把颜色名称转成 <code>UIColor</code> 实例对象，当然，我认为这样做是不值得的。我们当前的实现适用于99%的情况。另外1%的情况是在 Mac 的 <code>NSCell</code> 上使用，而且你允许用户输入一个你试图解析的颜色的名字，这所需要做的要比简单的 子类化 NSFormatter 复杂很多。或许，你不应该允许你的用户通过文本输入颜色值。<a href="https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSColorPanel_Class/">NSColorPanel</a> 在这里是一个更好的解决方案。</p>

<h2 id="">属性化字符串</h2>

<p>到目前为止，我们的格式器都按我们预期的工作。接下来让我们做一个完全没用的功能，只是示范一下我们可以这么做，你懂的。</p>

<p>格式器同时支持属性化字符串。要不要支持它取决于你特定的应用与其用户界面。因此，你最好把这个功能做成可配置。</p>

<p>以下代码就是将文本颜色设置为当前正在格式化的颜色：</p>

```objc
- (NSAttributedString *)attributedStringForObjectValue:(id)value 
                                 withDefaultAttributes:(NSDictionary *)defaultAttributes;
{
    NSString *string = [self stringForObjectValue:value];

    if  (!string) {
        return nil;
    }

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:defaultAttributes];
    attributes[NSForegroundColorAttributeName] = value;
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}
```

<p>首先，我们如之前一样处理字符串，然后检查格式化是否成功。然后我们把默认的属性值与前面设置的颜色属性结合后，最终返回属性化字符串。很容易，是吗？</p>

<h2 id="">便捷</h2>

<p>因为初始化内建的格式器<a href="https://twitter.com/ID_AA_Carmack/status/28939697453">太慢了</a>，所以通常需要对外给你的格式器提供一个便利的类方法。这个格式器应该用默认值与当前的本地化环境。以下是格式器的实现：</p>

<pre><code>+ (NSString *)localizedStringFromColor:(UIColor *)color;
{
    static dispatch_once_t onceToken;
    dispatch_once(&amp;onceToken, ^{
        KPAColorFormatterReusableInstance = [[KPAColorFormatter alloc] init];
    });

    return [KPAColorFormatterReusableInstance stringForObjectValue:color];
}
</code></pre>

<p>除非你的格式器像 <code>NSNumberFormatter</code> 与 <code>NSDateFormatter</code> 一样做一些疯狂的事情 ，你可能不需要因为性能问题这么做。但是这样做也可以让使用格式器简单许多。</p>

<h2 id="">总结</h2>

<p>我们的颜色格式器现在可以把一个 <code>UIColor</code> 实例格式成一个可读的名字或是反过来也行。当然还有放多有关 <code>NSFormatter</code> 的事情没有涉及。特别是在 Mac 上，因为它跟 <code>NSCell</code> 相关，你可以用更多高级的特性。例如当用户在编辑的时，你可以对字符串做一些检测。</p>

<p>我们的格式器还可以做更多自定义的事情。例如，在没查找到一个你需要的颜色名字时，我们可以返回给你最相近的颜色名字。有时，你可能需要我们的格式器有一个 Boolean 属性来控制该功能。或许我们的属性化字符串的格式化不是你想要的，并且应该支持更多自定义操作。</p>

<p>就此，我们完成了一个非常可靠的格式器。所有的代码（伴有 OS X 示例）都放在了 <a href="https://github.com/klaaspieter/KPAColorFormatter">Github</a> 上， 并且你也可以在 <a href="http://cocoapods.org/">CocoaPods</a> 上看到。如果你应用需要此功能，可以将 "KPAColorFormatter" 放在你的 Podfile 中，开始使用它吧。</p>

<hr />