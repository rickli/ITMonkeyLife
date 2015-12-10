---
layout: post
title: "iOS 8 体验推送"
date: 2014-07-02 11:55:11 +0800
comments: true
categories: [iOS]
---
<p> 一直更新了iOS8，但是一直没有开始研究这个iOS8，今天因为项目用到了推送，于是体验了iOS8的推送，先讲讲这个推送。目前分为四个推送：用户推送，本地推送，远程推送，地理位置推送。
</p>
<p><img src="http://ww3.sinaimg.cn/large/626e5d69gw1ehyeq298goj21kw0sadmt.jpg" alt="推送界面" /></p>

<h2>用户推送</h2>
<p>我们先开始讲这个用户推送,我们要使用之前必须先注册这个推送，用户要允许这个程序进行推送</p>
<p>注册过程：</p>

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIUserNotificationType  types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert ;
    UIUserNotificationSettings  *mySettings  = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    UIUserNotificationType allowTypes = [notificationSettings types];
}


- (void)getReadyForNotification
{
    UIUserNotificationSettings *currentNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    [self checkSetting:currentNotificationSettings];

}
```

<p>总结就是三个方法进行注册</p>
<p><img src="http://ww4.sinaimg.cn/large/626e5d69gw1ehyeumz8inj21f80d40up.jpg" alt="推送注册三个方法" /></p>

<p>我们现在仅仅是注册了通知的设置，还要注册推送通知的行为，在iOS8中，行为能直接在推送消息进行，如回复消息，拒绝消息等</p>
<p><img src="http://ww1.sinaimg.cn/large/626e5d69gw1ehyeyi825mj21aa12ggoc.jpg" alt="直接在推送消息进行回复" /></p>
<p>这个真心碉堡了</p>
<p>我们如何能进行这些行为，首先我们需注册这些行为。</p>
<!-- more -->
<li>Actions</li>
```objc
	UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"RickAction";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
```
<li>Categories</li>

```objc
	UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
```
<p>我们需要注意这个<code>UIUserNotificationActionContextDefault</code>,如果我们使用这个，我们会得到这个推送行为，Maybe和Accept</p>
<p><img src="http://ww1.sinaimg.cn/large/626e5d69gw1ehyf4bfhvrj20q80zytaw.jpg" alt="Maybe和Accept" /></p>
<p>我们还可以使用<code>UIUserNotificationActionContextMinimal</code>得到的是Decline和Accept行为</p>
<p><img src="http://ww3.sinaimg.cn/large/626e5d69gw1ehyf61ypo0j20q010476h.jpg" alt="Decline和Accept" /></p>

<li>Settings</li>
<p>在这些行为注册之后，我们加上之前提到的推送设置就完成了注册推送的这个流程了</p>

```objc
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    UIUserNotificationType  types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert ;
    UIUserNotificationSettings  *mySettings  = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
```
<h2>远程推送</h2>
<p>远程推送，所有消息大小不超过2KB,我们获取远程推送的json格式的消息，解析这个消息就是我们的远程推送了：</p>
```json
{
    “aps”: {
        "content-available": 1,
        "alert": "This is the alert text",
        "badge": 1,
        "sound": "default"
    }
} 
```
<p>若要使用远程推送，满足两个条件：一、用户需要调用注册用户推送<code>registerUserNotificationSettings</code>;二、在<code>info.plist</code>文件中<code>UIBackgroundModes</code>必须包含远程通知。</p>	
```objc
	[[UIApplication sharedApplication] registerForRemoteNotifications];
```
<blockquote>
	<p>这个注册通知的方法开始更改了</p>
</blockquote>

```objc
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
}
```
<p>iOS7通知代理方法</p>
<p><img src="http://ww4.sinaimg.cn/large/626e5d69gw1ehyfq2omeij21kw0zc456.jpg" alt="iOS6的通知代理方法" /></p>
<p>后来又增加了本地通知的代理方法</p>
<p><img src="http://ww4.sinaimg.cn/large/626e5d69gw1ehyfvjws4ej21kw0uxn20.jpg" alt="添加本地推送的通知代理方法" /></p>
<p>iOS8的推送代理方法只有两个了</p>
<p><img src="http://ww4.sinaimg.cn/large/626e5d69gw1ehyfws0hdfj210g0oyq6d.jpg" alt="iOS 8推送的通知代理方法" /></p>
```objc
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"RickAction"]) {
        [self handleAcceptActionWithNotification:notification];
    }
    completionHandler();
}

- (void)handleAcceptActionWithNotification:(UILocalNotification*)notification
{
}
```
<h2>地理位置推送</h2>
<p>这个推送是新的API才有的特性,必须配合CLLocation定位一起使用。</p>
```objc

//Location Notification
    CLLocationManager *locMan = [[CLLocationManager alloc] init];
    locMan.delegate = self;
    [locMan requestWhenInUseAuthorization];

#pragma mark - CLLocationManager

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status

{
    BOOL canUseLocationNotifications = (status == kCLAuthorizationStatusAuthorizedWhenInUse);
    if (canUseLocationNotifications) {
        [self startShowLocationNotification];
    }
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification

{
    CLRegion *region = notification.region;
    if (region) {
    }
}

- (void)startShowLocationNotification

{
    CLLocationCoordinate2D local2D ;
    local2D.latitude = 123.0;
    local2D.longitude = 223.0;
    UILocalNotification *locNotification = [[UILocalNotification alloc] init];
    locNotification.alertBody = @"你接收到了";
    locNotification.regionTriggersOnce = YES;
    locNotification.region = [[CLCircularRegion alloc] initWithCenter:local2D radius:45 identifier:@"local-identity"];
    [[UIApplication sharedApplication] scheduleLocalNotification:locNotification];
}
```
<blockquote>
	<p>如果没有开启Core Location 那么上面的didReceiveLocalNotification不会被调用</p>
</blockquote>

<p>最后再总结一下，整个推送流程我觉得是这样子的，先注册推送，然后推送消息，客户端接收推送消息，执行推送行为。如果有错误，还请在文章下面评论，欢迎指正。</p>
<p><img src="http://ww2.sinaimg.cn/large/626e5d69gw1ehyg8u1o51j21ea0qkmz1.jpg" alt="推送的流程" /></p>

<hr />