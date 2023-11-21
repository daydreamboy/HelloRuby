//
//  AppDelegate.m
//  AppTest
//
//  Created by wesley chen on 16/4/13.
//
//

#import "AppDelegate.h"

#import "RootViewController.h"

// >= `15.0`
#ifndef IOS15_OR_LATER
#define IOS15_OR_LATER          ([[[UIDevice currentDevice] systemVersion] compare:@"15.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

@interface WCNavigationBarTool : NSObject
@end
@interface WCNavigationBarTool ()
+ (BOOL)fixAppearanceOfNavigationBarIssueTransparentOnIOS15;
@end
@implementation WCNavigationBarTool
+ (BOOL)fixAppearanceOfNavigationBarIssueTransparentOnIOS15 {
    if (IOS15_OR_LATER) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunguarded-availability"
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
#pragma GCC diagnostic pop
        
        return YES;
    }
    
    return NO;
}
@end

@interface AppDelegate ()
@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) UINavigationController *navController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WCNavigationBarTool fixAppearanceOfNavigationBarIssueTransparentOnIOS15];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.rootViewController = [RootViewController new];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    // Note: the translucent value of UITabBar and UINavigationBar are YES by default, this is cause off-screen rendering,
    // so set it to NO
    // @see https://stackoverflow.com/questions/45368350/is-there-something-wrong-of-ios-simulators-color-offscreen-rendered-function
    self.navController.navigationBar.translucent = NO;
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
