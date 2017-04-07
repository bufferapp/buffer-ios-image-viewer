//
//  AppDelegate.m
//  BFRImageViewer
//
//  Created by Andrew Yates on 20/11/2015.
//  Copyright © 2015 Andrew Yates. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [UIWindow new];
    
    UITabBarController *tabVC = [UITabBarController new];
    tabVC.view.backgroundColor = [UIColor whiteColor];
    tabVC.viewControllers = @[[FirstViewController new], [SecondViewController new], [ThirdViewController new], [FourthViewController new]];
    
    self.window.rootViewController = tabVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
