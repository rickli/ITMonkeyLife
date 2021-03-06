---
layout: post
title: "iCould 和 Core Data"
date: 2014-04-08 09:46:25 +0800
comments: true
categories: [iOS]
---
<div><p>当乔布斯第一次在苹果全球开发大会上介绍 <a href="http://en.wikipedia.org/wiki/ICloud">iCloud</a></div> 的时候，他将无缝同步的功能描述的太过完美，以至于让人怀疑其是否真的能实现。但当你在 <a href="http://adcdownload.apple.com//videos/wwdc_2011__hd/session_303__whats_new_in_core_data_on_ios.m4v">iOS 5</a> 和 <a href="http://adcdownload.apple.com//videos/wwdc_2012__hd/session_227__using_icloud_with_core_data.mov">iOS 6</a> 系统中尝试使用 iCloud <a href="http://www.objc.io/issue-4/core-data-overview.html">Core Data</a> 同步的时候你会对其真实情况了如指掌。</p>
<p><a href="https://developer.apple.com/library/mac/documentation/General/Conceptual/MOSXAppProgrammingGuide/CoreAppDesign/CoreAppDesign.html#//apple_ref/doc/uid/TP40010543-CH3-SW3">库风格应用</a>(译者注:"盒子类型"，比如 iPhoto )的同步中的问题导致<a href="http://www.macworld.com/article/1167742/developers_dish_on_iclouds_challenges.html">很多</a><a href="http://blog.caffeine.lu/problems-with-core-data-icloud-storage.html">开发者</a><a href="http://www.jumsoft.com/2013/01/response-to-sync-issues/">放弃</a>支持 iCloud，而选择一些其他的方案比如 <a href="http://simperium.com">Simperium</a>，<a href="https://github.com/nothirst/TICoreDataSync">TICoreDataSync</a> 和 <a href="http://www.wasabisync.com">WasabiSync</a>。</p>

<p>2013年初，在苹果公司不透明及充满 bug 的 iCloud Core Data 同步实现中挣扎多年后，开发者终于公开批判了这项服务的重大缺陷并将这个话题推上了<a href="http://arstechnica.com/apple/2013/03/frustrated-with-icloud-apples-developer-community-speaks-up-en-masse/">风口浪尖</a>。 最终被 Ellis Hamburger 在一篇<a href="http://www.theverge.com/2013/3/26/4148628/why-doesnt-icloud-just-work">尖锐文章</a>提出。</p>

<h2 id="wwdc">WWDC</h2>

<p>苹果也注意到了，很明显这些事情必须改变。在 WWDC 2013，<a href="http://about.me/nickgillett">Nick Gillett</a> 宣布 Core Data 团队花了一年时间专注于在 iOS 7 中解决一些 iCloud 最令人挫败的漏洞，承诺大幅改善问题并且让开发者更简单的使用。“我们明显减少了开发者所需要编写的复杂代码的数量。” Nick Gillett在 [“What’s New in Core Data and iCloud”] 舞台上讲到。 在 iOS 7 中，Apple 专注于 iCloud 的速度，可靠性，和性能，事实上这卓有成效。</p>

<p>让我们看看具体有哪些改变，以及如何在 iOS 7 应用程序实现 Core Data。</p>

<h2 id="">设置</h2>

<p>要设置一个 iCloud Core Data 应用，你首先需要在你的应用中请求 iCloud 的<a href="https://developer.apple.com/library/mac/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html">访问权限</a>，让你的应用程序可以读写一个或多个开放性容器 (ubiquity containers)，在 Xcode 5中你可以在你应用 target 的 <a href="https://developer.apple.com/xcode/">“Capabilities”</a> 选项卡中轻易完成着这一切。</p>

<p>在开放性容器内部，Core Data Framework 将会存储所有的事务日志 -- 记录你的所有持久化的存储 -- 为了跨设备同步数据做准备。 Core Data 使用了一个被称为<a href="http://en.wikipedia.org/wiki/Multi-master_replication">多源复制</a>(multi-master replication)的技术来同步 iOS 和 Macs 之间的数据。可持久化存储的数据存在了每个设备的 <code>CoreDataUbiquitySupport</code> 文件夹里，你可以在应用沙盒中找到他。当用户修改了 iCloud accounts，Core Data framework 会管理多个账户，而并不需要你自己去监听<a href="https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/nsfilemanager_class/Reference/Reference.html#//apple_ref/doc/uid/20000305-SW81"><code>NSUbiquityIdentityDidChangeNotification</code></a>。</p>

<p>每一个事务日志都是一个<code>plist</code>文件，负责实体的跟踪插入，删除以及更新。这些日志会自动被系统按照一定<a href="http://mentalfaculty.tumblr.com/post/23788055417/under-the-sheets-with-icloud-and-core-data-seeding">基准</a>合并。</p>
<div>
<p>在你设置iCloud的持久化存储的时候，调用</p><code>addPersistentStoreWithType:configuration:URL:options:error:</code><p>或者</p> <code>migratePersistentStore:toURL:options:withType:error:</code></a>的时候注意需要设置一些选项:
</div>
<!-- more -->
<ul>
<li><p><code>NSPersistentStoreUbiquitousContentNameKey</code> (<code>NSString</code>) <br />
给 iCloud 存储空间指定一个名字（例如 @“MyAppStore”）</p></li>
<li><p><code>NSPersistentStoreUbiquitousContentURLKey</code> (<code>NSString</code>, iOS 7 中可选)
给事务日志指定一个二级目录(例如 @"Logs")</p></li>
<li><p><code>NSPersistentStoreUbiquitousPeerTokenOption</code> (<code>NSString</code>, 可选) <br />
为每个程序设置一个盐，为了让不同应用可以在同一个集成 iCloud 的设备中分享 Core Data 数据 (比如<code>@"d70548e8a24c11e3bbec425861b86ab6"</code>)</p></li>
<li><p><code>NSPersistentStoreRemoveUbiquitousMetadataOption</code> (<code>NSNumber</code> (Boolean), 可选)
指定程序是否需要备份或迁移 iCloud 的元数据(例如 <code>@YES</code>)</p></li>
<li><p><code>NSPersistentStoreUbiquitousContainerIdentifierKey</code> (<code>NSString</code>) <br />
指定一个容器，如果你的应用有多个容器定义在 entitlements 中(例如 <code>@"com.company.MyApp.anothercontainer"</code>)</p></li>
<li><p><code>NSPersistentStoreRebuildFromUbiquitousContentOption</code> (<code>NSNumber</code> (Boolean), 可选) 
告诉 Core Data 抹除本地存储数据并且用 iCoud 重建数据(例如 <code>@YES</code>)</p></li>
</ul>

<p>只支持 iOS 7 的应用的唯一必填选项是 ContentNameKey，它是为了让 Core Data 知道把日志和元数据放在哪里。在 iOS 7 中，你传入 NSPersistentStoreUbiquitousContentNameKey 的字符串值不应该包含'.'。 如果你的应用已经使用 Core Data 去存储持久化数据，但是没有实现 iCloud 同步，你只需要简单加入 content name key 就能将存储转为可以使用 iCloud 的状态，而无需关注有没有活跃的 iCloud 账户。</p>

<p>为你的应用设置一个管理对象上下文简单到只需要实例化一个 <code>NSManagedObjectContext</code> 并连同一个合并策略一并告诉你的持久化存储。苹果建议使用 <code>NSMergeByPropertyObjectTrumpMergePolicy</code> 作为合并策略，它会合并冲突，并给予内存中的变化的数据相较于磁盘数据更高的优先级。</p>

<p>虽然 Apple 还没有发布官方的 iOS7 中 iCloud Core Data 的示例代码，但是 Apple 的 Core Data 团队中的一个工程师在<a href="https://devforums.apple.com/message/828503#828503">开发者论坛</a>上提供了这个模板。我们稍微修改让它更清晰:</p>
```objc
#pragma mark - Notification Observers
- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self 
                           selector:@selector(storesWillChange:) 
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification 
                             object:self.persistentStoreCoordinator];

    [notificationCenter addObserver:self 
                           selector:@selector(storesDidChange:) 
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification 
                             object:self.persistentStoreCoordinator];

    [notificationCenter addObserver:self 
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:) 
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification 
                             object:self.persistentStoreCoordinator];
}

# pragma mark - iCloud Support

/// 在 -addPersistentStore: 使用这些配置
- (NSDictionary *)iCloudPersistentStoreOptions {
    return @{NSPersistentStoreUbiquitousContentNameKey: @"MyAppStore"};
}

- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)notification {
    NSManagedObjectContext *context = self.managedObjectContext;

    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSManagedObjectContext *context = self.managedObjectContext;

    [context performBlockAndWait:^{
        NSError *error;

        if ([context hasChanges]) {
            BOOL success = [context save:&amp;error];

            if (!success &amp;&amp; error) {
                // 执行错误处理
                NSLog(@"%@",[error localizedDescription]);
            }
        }

        [context reset];
    }];

    // 刷新界面
}

- (void)storesDidChange:(NSNotification *)notification {
    // 刷新界面
}
```

<h3 id="">异步持久化设置</h3>

<p>在 iOS 7 中，使用 iCloud 选项来调用 </p><code>addPersistentStoreWithType:configuration:URL:options:error:</code> 几乎可以瞬间返回存储对象。 能做到这样是因为它首先设置了一个内部‘回滚’存储，利用本地存储作为一个占位符，同时由事务日志和元数据来异步地构建 iCloud 存储。当回滚存储有变化时，这些变化将在 iCloud 存储被添加到 coordinator 时合并至其中。在完成回滚存储的设置后，控制台将会打印<code>Using local storage: 1</code> ，当 iCloud 完全设置完后，你会看到 <code>Using local storage: 0</code>。 这句话的意思是 iCloud 存储已经启用，此后你可以通过监听<code>NSPersistentStoreDidImportUbiquitousContentChangesNotification</code>看到来自 iCloud 的内容。

<p>如果你的应用关注在不同存储间的迁移，那么你需要监听</p><p><code>NSPersistentStoreCoordinatorStoresWillChangeNotification</code></p> 或<code>NSPersistentStoreCoordinatorStoresDidChangeNotification</code>(将这些通知关联到你的 coordinator，这样就可以过滤其他和你无关的通知) 并且在 <code>userInfo</code> 中检查 <code>NSPersistentStoreUbiquitousTransitionTypeKey</code> <p>的值， 这个数值是一个对应</p> <a href="https://developer.apple.com/library/ios/documentation/cocoa/Reference/CoreDataFramework/Classes/NSPersistentStoreCoordinator_Class/NSPersistentStoreCoordinator.html#//apple_ref/c/tdef/NSPersistentStoreUbiquitousTransitionType"><code>NSPersistentStoreUbiquitousTransitionType</code></a> <p>枚举类型的 NSNumber，在迁移已经发生时，这个值是<code>NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted</code>。</p>

<h2 id="">边缘情况</h2>

<h3 id="churn">混淆 (Churn)</h3>

<p>在 iOS 5 和 iOS 6 中测试 iCloud 时最严重的一个问题是重度用户的账号会遇到一种“混淆”的状态，导致无法使用。同步将完全停止，甚至删除开放性数据也无法使其正常工作。在 <a href="http://lickability.com">Lickability</a>，我们亲切地称为这种状态“fucking bucket。”</p>

<p>在 iOS 7 中，系统提供了一个方法来真正移除全部的开放性存储内容:</p> <code>+removeUbiquitousContentAndPersistentStoreAtURL:options:error:</code>，这个方法对测试很有帮助，甚至在你应用中，当你用户进入了一个不正常的状态时，他们可以通过这个方法删除所有数据，并重新来过。不过，需要指出的是：首先，这种方法是同步的。甚至在做网络操作的时候它也是同步的，因此它会花很长时间，并且在完成前也不会返回。第二，绝对不能在有持久性存储 coordinators 活跃时执行此操作。这样会造成很严重的问题，你的应用程序可能进入一个不可恢复的状态，而且官方指导指出所有活跃的持久性存储 coordinators 都应在使用这个方法前完全销毁收回。

<h3 id="">账户修改</h3>

<p>iOS 5 系统中，用户在切换 iCloud 账户或者禁用账户时，<code>NSPersistentStoreCoordinator</code> 中的数据会在应用无法知晓的情况下完全消失。事实上检查一个账号是否变更了的唯一的方法是调用 <code>NSFileManager</code> 中的 <code>URLForUbiquityContainerIdentifier</code>，这个方法可以创建一个开放性容器文件夹，而且需要数秒返回。在 iOS 6，这种情况随着引进 <code>ubiquityIdentityToken</code> 和相应的<code>NSUbiquityIdentityDidChangeNotification</code> 之后得到改善。因为在 ubiquity id 变化的时候会发送通知，这就可以对应用账户的变更进行有效的确认并及时的发出提示。</p>

<p>然而，iOS 7 中这种转换的情况就变得更加简单，账户的切换是由 Core Data 框架来处理的，因此只要你的程序能够正常响应 <code>NSPersistentStoreCoordinatorStoresWillChangeNotification</code> 和 <code>NSPersistentStoreCoordinatorStoresDidChangeNotification</code> 便可以在切换账户的时候流畅的更换信息。检查 <code>userInfo</code> 的字典中 <code>NSPersistentStoreUbiquitousTransitionType</code> 键将提供更多关于迁移的类型的细节。</p>

<p>在应用沙箱中框架会为每个账户管理各自独立的持久化存储，所以这就意味着如果用户回到之前的账户，其数据会和之前离开时一样，仍然可用。Core Data 现在也会在磁盘空间不足时管理对这些文件进行的清理工作。</p>

<h3 id="icloud">iCloud 的启用与停用</h3>

<p>在 iOS 7 中应用实现用一个开关用来切换启用关闭 iCloud 变的非常容易，虽然对大部分应用来说这个功能不是很需要，因为在创建 <code>NSPersistentStore</code> 时候如果加入 iCloud 选项，那么 API 现在将自动建立一个独立的文件结构，这意味着本地存储和 iCloud 存储共用相同的存储 URL 和其他很多设置。这个选项将把 ubiquitous 元数据和存储本身进行分离，并专门为迁移或者复制的场景进行了特殊设计。下面是一个示例:</p>
```objc
- (void)migrateiCloudStoreToLocalStore {
    // 假设你只有一个存储
    NSPersistentStore *store = [[_coordinator persistentStores] firstObject]; 

    NSMutableDictionary *localStoreOptions = [[self storeOptions] mutableCopy];
    [localStoreOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];

    NSPersistentStore *newStore =  [_coordinator migratePersistentStore:store 
                                                                  toURL:[self storeURL] 
                                                                options:localStoreOptions 
                                                               withType:NSSQLiteStoreType error:nil];

    [self reloadStore:newStore];
}

- (void)reloadStore:(NSPersistentStore *)store {
    if (store) {
        [_coordinator removePersistentStore:store error:nil];
    }

    [_coordinator addPersistentStoreWithType:NSSQLiteStoreType 
                               configuration:nil 
                                         URL:[self storeURL] 
                                     options:[self storeOptions] 
                                       error:nil];
}
```

<p>切换一个本地存储到　iCloud 存储是一个非常容易的事情，简单到只需启用 iCloud 选项，并且把拥有相同选项的可持久存储加入到 coordinator 中。</p>

<h3 id="">外部文件的引用</h3>

<p>外部文件的应用是一个在 iOS 5　中加入的 Core Data 新特性，允许大尺寸的二进制自动存储在 SQLite 数据库之外的文件系统中。 在我们测试中，当发生改变时，iCloud 并不知道如何解决依赖关系并会抛出异常。如果你计划使用 iCloud 同步 ,可以考虑在 iCloud entities 中取消这个选择:</p>

<p><img src="http://cloud.mttb.me/UBrx/image.png" alt="Core Data Modeler Checkbox" /></p>

<h3 id="model">Model 版本</h3>

<p>如果你计划使用 iCloud，存储的内容只能在未来兼容自动<a href="https://developer.apple.com/library/ios/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html">轻量级迁移</a>，
这意味着 Core Data 需要能推断出映射，你也不能提供自己的映射模型。在未来只有对 Model 的简单改变，比如添加和重命名属性，才能被支持。在考虑是否使用 Core Data 同步时，一定要考虑到你的 app 的 Model 在未来版本中改变的情况。</p>

<h3 id="">合并冲突</h3>

<p>在任何同步系统中，服务器和客户端之前的文件冲突是不可避免的。不同于 <a href="https://developer.apple.com/library/ios/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html#//apple_ref/doc/uid/TP40012094-CH2-SW1">iCloud Data 文档同步</a>的 APIs, iCloud 的 Core Data 整合并没有明确允许处理本地存储和事务日志之间的冲突。这其实是因为 Core Data 已经支持通过实现 <code>NSMergePolicy</code> 的子类来自定义策合并策略。 如果你要处理冲突，创建 <code>NSMergePolicy</code> 的子类并且覆盖 <code>resolveConflicts:error:</code> 来决定在冲突发生的时候做什么。然后在你的 <code>NSManagedObjectContext</code> 子类中，让<code>mergePolicy</code> 方法返回一个你自定义的策略的实例。</p>

<h3 id="">界面更新</h3>

<p>很多库风格应用同时显示集合对象和一个对象的详细信息。 视图是由 <code>NSFetchedResultsController</code> 实例自动从网络更新 Core Data 的数据然后刷新。然而，您应该确保每一个详细视图正确监听变化对象并使自己保持最新。如果你不这样做, 将有显示陈旧的数据的风险，或者更糟，你将覆盖其他设备修改的数据。</p>

<h2 id="">测试</h2>

<h3 id="">本地网络和因特网同步</h3>

<p>iCloud 守护进程将使用本地网络或使用因特网这两种方式中的其中一种，来进行跨设备的数据同步。守护进程检测到两个设备时，也被称为对等网络，在同一个局域网，将在内网快速传输。然而，如果在不同的网络，该系统将传输回滚事务日志。这很重要，你必须在开发中对两种情况进行大量的测试，以确保您的应用程序正常运作。在这两种场景中，从备份存储同步更改或过渡到 iCloud 有时需要比预期更长的时间，所以如果有什么不工作，尝试给它点时间。</p>

<h3 id="icloud">模拟器中使用 iCloud</h3>

<p>在 iOS 7 中最有用的更新就是 iCloud 终于可以在<a href="https://developer.apple.com/library/mac/documentation/General/Conceptual/iCloudDesignGuide/Chapters/TestingandDebuggingforiCloud.html">模拟器</a>中使用。在以往的版本中，你只能在设备中测试，这个限制使监听开发的同步进程有点困难。现在你甚至可以在你的 Mac 和模拟器中进行数据同步。</p>

<p>在 Xcode 5 新增的 iCloud 调试仪表中，你可以看到在你的应用程序的开放性存储中的文件，以及检查它们的文件传输状态，比如 "Current"， "Excluded"， 和 "Stored in Cloud" 等。 对于更底层的调试，可以把 <code>-com.apple.coredata.ubiquity.logLevel 3</code> 加入到启动参数或者设置成用户默认，以启用详细日志。还可以考虑在 iOS 中安装 <a href="http://developer.apple.com/downloads">iCloud 存储调试日志配置文件</a> 以及新的 <a href="https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/ubcontrol.1.html"><code>ubcontrol</code></a> 命令行工具提供高质量错误报告到Apple 。你可以在你的设备连入 iTunes 并同步后在 <code>~/Library/Logs/CrashReporter/MobileDevice/device-name/DiagnosticLogs</code>
 中获取这些工具生成的日志。</p>

<p>然而，iCloud Core Data 并不完全支持模拟器。在用实际设备和模拟器测试传输时，似乎模拟器的 iCloud Core Data 只上传更改，却从不把它们抓取下来。虽然比起分别使用多个不同测试设备来说，确实进步和方便了很多，但是 iOS 模拟器上的 iCloud Core Data 支持绝对还没有完全成熟。</p>

<h2 id="">继续改进</h2>

<p>因为 iOS 7 中 APIs 和功能得到了极大的改善，那些在 iOS 5 和 iOS 6 上分发的带有 iCloud Core Data 的应用的命运就显得扑朔迷离了。 由于从 API 的角度来看它们完全不同（当然我们从功能角度也验证了这一点)，Apple 的建议对于那些需要传统同步的应用来说并不那么友好。Apple <strong>清楚地</strong> 在<a href="https://devforums.apple.com/thread/199983?start=0&amp;tstart=0*">开发者论坛</a> 上建议，绝对不要在 iOS 7 和之前的设备同步之间同步数据。</p>

<p>事实上，“任何时候你都不应该在 iOS 7 与 iOS 6 同步。iOS 6 将持续造成那些已经在 iOS 7 上修正了的 bug，这样做将会会污染 iCloud 账户。” 保证这种分离的最简单的方法是简单地改变你存储中的 <code>NSPersistentStoreUbiquitousContentNameKey</code>，遵循规范进行命名。这样保证从旧版本数据同步的方法是孤立的，并允许开发人员从老旧的实现中完全脱身。</p>

<h2 id="">发布</h2>

<p>发布一个 iCloud Core Data 应用仍旧有很大的风险，你需要对所有的环节进行测试：账户转换，iCloud 存储空间耗尽，多种设备，Model 的升级，以及设备恢复等。尽管 iCloud 调试仪表和 <a href="http://developer.icloud.com">developer.icloud.com</a> 对这些有所帮助，但依靠一个你完全无法控制的服务来发布一个应用仍然需要那种纵身一跃入深渊的信念。</p>

<p>正如 Brent Simmon <a href="http://inessential.com/2013/03/27/why_developers_shouldnt_use_icloud_sy">提到</a>的，发布任意一种 iCloud Syncing 应用都会有限制，所以需要事先了解一下成本。像 <a href="http://dayoneapp.com">Day One</a> 和 <a href="https://agilebits.com/onepassword">1Password</a> 这样的程序，会让使用者选择用 iCloud 还是 Dropbox 来同步他们的数据。对于很多使用者来说，没什么可以比一个独立的账户更加简易，但是一部分动手能力强的人喜欢更好的更全面的控制他们的数据。对于开发者而言，维持这种完全不同的<a href="https://www.dropbox.com/developers/datastore">数据库同步系统</a>在开发和测试的过程当中是十分繁琐和超负荷的。</p>

<h2 id="bugs">Bugs</h2>

<p>一旦你测试并且发布了你的 iCloud Core Data 应用，你很可能会遇到很多框架里的 bug，最好的办法是反馈这些 bug 的详细信息到  <a href="http://bugreport.apple.com">Apple</a>，其中需要包含以下信息：</p>

<ol>
<li>完整的重现步骤  </li>
<li>安装了 iCloud 调试配置并将 iCloud 调试日志输出级别调为 3 的终端输出  </li>
<li>打包为 zip 的完整的开放性存储内容</li>
</ol>

<h2 id="">结论</h2>

<p>在 iOS 5 和 6 中 iCloud Core Data 根本就没法用这件事已经是不是一个秘密， Apple 的程序员自己都承认“在 iOS 5 和 6 中使用 Core Data + iCloud 时，存在重大的稳定性和长期可靠性的问题，要使用它的话请一定一定一定把应用设为 iOS 7 only“。一些高端的开发者，比如 <a href="http://agiletortoise.com">Agile Tortoise</a> 以及 <a href="http://realmacsoftware.com">Realmac Software</a>，现在已经信任 iCloud Core Data，并把它集成到了他们的应用中。因为有着充分的<a href="https://developer.apple.com/library/ios/documentation/General/Conceptual/iCloudDesignGuide/Chapters/Introduction.html">考量</a>和测试，你也应该这么做了。</p>

<p><em>特别感谢 Andrew Harrison, Greg Pierce, and Paul Bruneau 对这篇文章的帮助</em></p>

<p>[^1]: 在之前的 OS 版本中，这个方法直到 iCloud 数据下载并合并到持久化存储中前是不会返回的。这将造成大幅延迟，并意味着任何对这个方法的调用需要被派发到一个后台的队列中去。值得庆幸的是现在已经不再需要这么做了。</p>

<hr />