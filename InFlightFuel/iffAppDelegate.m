//
//  iffAppDelegate.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffAppDelegate.h"
#import "iffViewController.h"

@implementation iffAppDelegate

@synthesize window = _window;
@synthesize lastFiredLocalEvent;

- (id)init
{
    self = [super init];
    if (self) {
        self.lastFiredLocalEvent = nil;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
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
    [application cancelAllLocalNotifications];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)app didReceiveLocalNotification:(UILocalNotification *)n
{
    /* Sadly, sometimes these will get sent twice. There are bugs reports about this happening
       in the simulator, and some people have reported it happening on devices. I can definitely
       see it happening on the simulator. Let's be extra preventative here. */
    if (!self.lastFiredLocalEvent || ![self.lastFiredLocalEvent isEqualToDate:n.fireDate]) {
        self.lastFiredLocalEvent = n.fireDate;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:n.alertAction
                                                          message:n.alertBody
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
