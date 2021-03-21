//
//  AppDelegate.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 2/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "AppDelegate.h"
#import "common/EasyAddViewController.h"
#import "common/ListViewController.h"
#import "common/List1ViewController.h"
#import "common/TemplListViewController.h"
#import "common/EasyDisplayViewController.h"
#import "sharing/HomeViewController.h"
#import "common/AppCmnUtil.h"

#import <common/EasyListViewController.h>




@implementation AppDelegate



@synthesize dataSync;
@synthesize pFlMgr;
@synthesize pThumbNailsDir;
@synthesize pPicsDir;
@synthesize pDocsDir;

@synthesize fetchQueue;
@synthesize aViewController1;

@synthesize navViewController;
@synthesize no_of_lists;
@synthesize no_of_template_lists;
@synthesize no_of_edits;
@synthesize no_of_template_edits;


@synthesize pShrMgr;
@synthesize pShrDelegate;
@synthesize templViewCntrl;
@synthesize tabBarController;


@synthesize appUtl;
@synthesize selFrndCntrl;

@synthesize aViewController;





-(void) popView
{
    //putchar('N');
    [self.navViewController popViewControllerAnimated:NO];
    NSArray *vw = [self.navViewController viewControllers];
    NSUInteger cnt = [vw count];
    NSLog(@"No of view controllers %lu \n", (unsigned long)cnt);
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
    
    if(bSystemAbrt)
    {
        bSystemAbrt = false;
        return;
    }
    
    

    return;
}

-(void) shareContactsSetSelected
{
    
    self.selFrndCntrl.eViewCntrlMode = eModeShareToSelected;
    self.tabBarController.selectedIndex = 1;
    

}

-(void) runAlexaQuery
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSString *userID = [kvlocal objectForKey:@"syncUserID"];
    
    if (userID != nil)
    {
          NSLog(@"Running Alexa query with userID=%@" ,userID);
   //     [alexaSync runQuery:userID];
    }
}

- (void)getAlexaUserId:(NSString * _Nonnull)code {
    if ([code isEqualToString:@"no code"])
    {
        NSLog(@"No AlexaCode in the input returning");
        return;
    }
    
    NSInteger codeInt = [code integerValue];
    if (!codeInt)
    {
         NSLog(@"Invalid AlexaCode in the input returning");
        return;
    }
    NSLog(@"Getting Alexa UserID with code=%@", code);
   // [alexaSync getUserID:codeInt];
}


-(void) templShareMgrStartAndShow
{
    if (!bShrMgrStarted)
    {
        [pShrMgr start];
        bShrMgrStarted = true;
    }
   
    
    
    [appUtl showTemplShareView];
   [templViewCntrl refreshMasterList];
   
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [appUtl didRegisterForRemoteNotification:deviceToken];
    return;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for remote notification %@\n", error);
}

-(void) setShareId : (long long) shareId
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    pAppCmnUtil.share_id = shareId  ;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    selFrndCntrl.eViewCntrlMode = eModeContactsMgmt;
    return;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
   
   
     tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    pShrMgr = [ListShareMgr alloc];
    pShrMgr.appId = 4;
    pShrMgr = [pShrMgr init];
    pShrMgr.pNtwIntf.connectPort = @"16791";
    
    if (pShrMgr.pNtwIntf.connectAddr == nil)
    {
        pShrMgr.pNtwIntf.connectAddr = @"easygroclist.ddns.net";
       // pShrMgr.pNtwIntf.connectAddr = @"173.61.188.111";
        pShrMgr.pNtwIntf.port = 16805;
        NSLog(@"Set connect address=%@ port=%d %s:%d", pShrMgr.pNtwIntf.connectAddr, pShrMgr.pNtwIntf.port, __FILE__, __LINE__);
    }
    appUtl = [[AppShrUtil alloc] init];
    appUtl.pShrMgr = pShrMgr;
    bSystemAbrt = false;
    bShrMgrStarted = false;
    
    pFlMgr = [[NSFileManager alloc] init];
    NSURL *pHdir =[pFlMgr containerURLForSecurityApplicationGroupIdentifier:@"group.grocshared"];
    pThumbNailsDir = [pHdir URLByAppendingPathComponent:@"/Documents/pictures/thumbnails"];
    NSError *error;
    if ([pFlMgr createDirectoryAtURL:pThumbNailsDir withIntermediateDirectories:YES attributes:nil error:&error] == YES)
    {
        
        NSLog(@"Created album directory %@ \n", pThumbNailsDir);
    }
    else
        NSLog(@"Failed to create album directory %@ reason %@\n", pThumbNailsDir, [error localizedDescription]);
    NSLog(@"group container directory %@", [pFlMgr containerURLForSecurityApplicationGroupIdentifier:@"group.grocshared"]);

    pDocsDir = [pHdir URLByAppendingPathComponent:@"/Documents/"];
    pPicsDir = [pHdir URLByAppendingPathComponent:@"/Documents/pictures/"];
    
    dataSync = [[DataOps alloc] init];
    dataSync.appName = @"EasyGrocList";
    
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    pAppCmnUtil.dataSync = dataSync;
    pAppCmnUtil.pFlMgr = pFlMgr;
    pAppCmnUtil.pPicsDir    = pPicsDir;
    pAppCmnUtil.pThumbNailsDir = pThumbNailsDir;
    

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    aViewController = [EasyViewController alloc];
    
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    aViewController.bShowAlexaBtn = false;
    aViewController.bShareView = false;
    aViewController.delegate = self;
    UINavigationController *navCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController];
    UIImage *imageHome = [UIImage imageNamed:@"802-dog-house@2x.png"];
    UIImage *imageHomeSel = [UIImage imageNamed:@"895-dog-house-selected@2x.png"];
    aViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:imageHome selectedImage:imageHomeSel];
    
    self.navViewController = navCntrl;
    dataSync.navViewController = navCntrl;
    pAppCmnUtil.navViewController = navCntrl;
    pAppCmnUtil.bEasyGroc = true;
    pAppCmnUtil.appId = NSHARELIST_ID;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
   
    aViewController1 = [EasyViewController alloc];
    
    aViewController1 = [aViewController1 initWithNibName:nil bundle:nil];
    aViewController1.bShowAlexaBtn = false;
    aViewController1.bShareView = true;
    aViewController1.delegate = self;
    
    UIImage *image = [UIImage imageNamed:@"895-user-group@2x.png"];
    UIImage *imageSel = [UIImage imageNamed:@"895-user-group-selected@2x.png"];
     aViewController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Share" image:image selectedImage:imageSel];
    
    mainVwNavCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController1];
   

    pAppCmnUtil.aViewController1 = aViewController1;
    
      UIImage *imagePlanner = [UIImage imageNamed:@"ic_event_note_white_36pt"];
     UIImage *imagePlannerSel = [UIImage imageNamed:@"ic_event_note_36pt"];
    
    //The assignement to easyShareVw is just a dummy one to invoke loadView of aViewController1
     easyShareVw = aViewController1.view;
    self.window.backgroundColor = [UIColor whiteColor];
    //[self.window addSubview:self.navViewController.view];
    
    [self.window makeKeyAndVisible];
    appUtl.window = self.window;
    appUtl.navViewController = navViewController;
    pShrDelegate = [[SharingDelegate alloc] init];
    
    pShrMgr.shrMgrDelegate = pShrDelegate;
   
    
    templViewCntrl = [[TemplListViewController alloc]
                      initWithNibName:nil bundle:nil];
    templViewCntrl.delegate = self;
    templViewCntrl.bShareTemplView = false;
    templViewCntrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Planner" image:imagePlanner selectedImage:imagePlannerSel];
    mainTemplVwNavCntrl = [[UINavigationController alloc] initWithRootViewController:templViewCntrl];
    pAppCmnUtil.templNavViewController = mainTemplVwNavCntrl;
    
    selFrndCntrl = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    selFrndCntrl.pShrMgr = pShrMgr;
    selFrndCntrl.delegate = pShrDelegate;
    
    selFrndCntrl.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *selFrndNavCntrl = [[UINavigationController alloc] initWithRootViewController:selFrndCntrl];
    tabBarController.delegate = self;
    tabBarController.viewControllers = [NSArray arrayWithObjects:mainVwNavCntrl, selFrndNavCntrl, mainTemplVwNavCntrl, navCntrl, nil];
    dataSync.templListViewController = templViewCntrl;
    dataSync.templNavViewController = mainTemplVwNavCntrl;
    [self.window setRootViewController:self.tabBarController];
    self.tabBarController.selectedIndex = 3;
  //  [appUtl initializeTabBarCntrl:mainVwNavCntrl templNavCntrl:mainTemplVwNavCntrl ContactsDelegate:shrDelegate];
  
    [appUtl registerForRemoteNotifications];
   
    bShrMgrStarted = true;
   
    pAppCmnUtil.share_id = pShrMgr.share_id;
  
    [kvlocal setBool:YES forKey:@"ToDownload"];

    return YES;
}

-(NSUInteger) getShareId
{
    return pShrMgr.share_id;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification: Downloading items %s %d", __FILE__, __LINE__);
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"ToDownload"];
    completionHandler(UIBackgroundFetchResultNoData);
    return;
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
    
    NSLog(@"Application did become active app state=%ld %s %d", (long)[[UIApplication sharedApplication] applicationState], __FILE__, __LINE__);
    
    [pShrMgr start];
    [dataSync start];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
   
    NSString *userID = [kvlocal objectForKey:@"syncUserID"];
    
    if (userID != nil)
    {
        NSLog(@"RUNNING Alexa query with userID=%@" ,userID);
        //[alexaSync runQuery:userID];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self.dataSync saveEasyContext];
}


#pragma mark - Core Data stack


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return pDocsDir;
}

@end

