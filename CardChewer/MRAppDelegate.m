//
//  MRAppDelegate.m
//  CardChewer
//
//  Created by Michael Roher on 4/30/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRAppDelegate.h"

@implementation MRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //98	201	171
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:98.0/255.0 green:201.0/255.0 blue:171.0/255.0 alpha:1.0f]];
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:36.0/255.0 green:34.00/255.0 blue:31.0/255.0 alpha:1.0f]];
    UIColor *textColor = [UIColor colorWithRed:196.0/255.0 green:210.0/255.0 blue:242.0/255 alpha:1.0f];
//	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: textColor}];
    self.window.tintColor = textColor;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
