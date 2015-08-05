//
//  AppDelegate.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/4/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import CoreData
import Parse
import ParseUI
import Bolts
import FBSDKCoreKit
import Mixpanel

/// global debug variable -- switches between production and development Parse apps based on its value
var debugMode = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper { [unowned self] user, error in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
                
            } else if let user = user {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navController = storyboard.instantiateViewControllerWithIdentifier("NavController") as! UIViewController
                
                
                let currentInstallation = PFInstallation.currentInstallation()
                
                // store the user pointer
                if let donor = (PFUser.currentUser() as? User)?.donor {
                    currentInstallation["donor"] = donor
                } else if let org = (PFUser.currentUser() as? User)?.organization {
                    currentInstallation["org"] = org
                }
                
                currentInstallation.saveInBackground()
                
                self.window?.rootViewController!.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        User.registerSubclass()
        Organization.registerSubclass()
        Donor.registerSubclass()
        
        // Initialize Parse
        if (debugMode) {
            Parse.setApplicationId("cX7yVorAA99FNZyW5mWoEoGs07LE2jUCRKtEi0wt", clientKey: "ADboeEkiWri2efGeLzRJx8lTF4St9qZ64CZ7gmDX")
        } else {
            Parse.setApplicationId("DUJHLQUGe79QD2rOzbCRXjn1jrRDGqrSrpA5RdTD", clientKey: "Jphp5RR0YfXZPPvhRGal3L9YYes7cgfEAObcRfCr")
        }
        
        // set default ACL for all Parse objects
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
//        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // choose which screen to show first (login VC or donations VC)
        let user = PFUser.currentUser()
        let startViewController: UIViewController
        if user != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("NavController") as! UINavigationController
        } else {
            let loginViewController = MezzoLoginViewController()
            loginViewController.fields = .UsernameAndPassword | .LogInButton | .PasswordForgotten // | .Facebook
            loginViewController.delegate = parseLoginHelper
            
            loginViewController.signUpController?.delegate = parseLoginHelper
            
            startViewController = loginViewController
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController
        self.window?.makeKeyAndVisible()
        
        
        // Parse push notification setup
        let userNotificationTypes: UIUserNotificationType = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Mixpanel setup
        Mixpanel.sharedInstanceWithToken("addb634d2df408a6f26df48826cfa460")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        return true //FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// MARK: more Parse push notification setup
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // store the deviceToken in the current installation and save it to Parse
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        
        // store the user pointer
        if let donor = (PFUser.currentUser() as? User)?.donor {
            currentInstallation["donor"] = donor
        } else if let org = (PFUser.currentUser() as? User)?.organization {
            currentInstallation["org"] = org
        }
        
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("pushNotification", object: nil)
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
        
        // clear the badge count when the app is about to be launched
        let installation = PFInstallation.currentInstallation()
        if (installation.badge > 0) {
            installation.badge = 0
            installation.saveEventually()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.16hchung.Mezzo_1_0" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Mezzo_1_0", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Mezzo_1_0.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

