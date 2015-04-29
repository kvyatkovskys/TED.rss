//
//  AppDelegate.h
//  TED
//
//  Created by Kviatkovskii on 27.04.15.
//  Copyright (c) 2015 Kviatkovskii. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const ApiKey;

@interface KSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(void) downloadDataFromURL:(NSURL *) url withCompletionHandler:(void (^) (NSData *data)) completionHandler;

@end

