//
//  AppDelegate.m
//  TED
//
//  Created by Kviatkovskii on 27.04.15.
//  Copyright (c) 2015 Kviatkovskii. All rights reserved.
//

#import "KSAppDelegate.h"

NSString *const ApiKey = @"wsqx8d26gv8jsq8wa5tc9qxx";

@interface KSAppDelegate ()

@end

@implementation KSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

+ (void) downloadDataFromURL:(NSURL *) url withCompletionHandler:(void (^) (NSData *)) completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            NSLog (@"%@", [error localizedDescription]);
        }
        else {
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *) response statusCode];
            
            if (HTTPStatusCode != 200) {
                NSLog (@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler (data);
            }];
        } 
    }];
    
    [task resume] ; 
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
