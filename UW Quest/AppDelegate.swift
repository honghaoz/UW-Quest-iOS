//
//  AppDelegate.swift
//  UW Quest
//
//  Created by Honghao on 9/7/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        
        var rootViewController: UIViewController?
        
        if (Locator.user.isLoggedIn) {
            rootViewController = Locator.sharedLocator.slidingViewController
        }
        else {
            rootViewController = Locator.sharedLocator.loginViewController
        }
        
        UINavigationBar.appearance().barTintColor = UQMainColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        self.window!.rootViewController = rootViewController
        self.window!.makeKeyAndVisible()
        
        // Parse set up
        Parse.setApplicationId("JcvEfa2LZ6tdQQjDZ5nYAaJUslEOuU5qTrU9d4Yb", clientKey: "F66Ch6rXmkE75BcDXqS4cISJVcU4yh6CHmx5UZMP")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
//        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        ZHHParseDevice.trackDevice()
        
        // Analytics set up
        ARAnalytics.setupGoogleAnalyticsWithID("UA-45146473-5")
        ARAnalytics.setupCrashlyticsWithAPIKey("d3ec53bc16086eec715f67dbf095bf3be047762c")
        ARAnalytics.setupCountlyWithAppKey("7ab61899f0a5b444643df1c779ab724bdf16fd93", andHost: " https://cloud.count.ly")
        ARAnalytics.setupFlurryWithAPIKey("JBBY49SKN3T4GJWZVXFX")
        ARAnalytics.setupLocalyticsWithAppKey("4d84d1e95bd335fd372f8d0-9fcc6ef2-3e2a-11e4-a411-009c5fda0a25")
        ARAnalytics.setupParseAnalyticsWithApplicationID("JcvEfa2LZ6tdQQjDZ5nYAaJUslEOuU5qTrU9d4Yb", clientKey: "F66Ch6rXmkE75BcDXqS4cISJVcU4yh6CHmx5UZMP")
        
        Appsee.start("7f914911dabe41878792302113000594")
        
        ARAnalytics.event("App Launch")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

