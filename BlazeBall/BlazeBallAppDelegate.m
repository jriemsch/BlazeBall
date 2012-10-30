//  Created by Jens Riemschneider on 9/18/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "BlazeBallAppDelegate.h"
#import "RootViewController.h"
#import "BlazeBallView.h"

@implementation BlazeBallAppDelegate


@synthesize window = _window;
@synthesize glView = _glView;
@synthesize rootViewController = _rootViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.glView = [[[BlazeBallView alloc] initWithFrame:screenBounds] autorelease];
    
	_rootViewController = [[RootViewController alloc] init];
	self.window.rootViewController = self.rootViewController;
    [self.window addSubview:_glView];

    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    NSLog(@"Stopping view");
    BlazeBallView *view = (BlazeBallView *)self.glView;
    view.stopped = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */

    NSLog(@"Starting view");
    BlazeBallView *view = (BlazeBallView *)self.glView;
    view.stopped = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc {
    [_window release];
    [_glView release];
    [_rootViewController release];
    [super dealloc];
}

@end
