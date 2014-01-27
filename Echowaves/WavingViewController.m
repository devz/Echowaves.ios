//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "WavingViewController.h"
#import "NavigationTabBarViewController.h"
#import "EWImage.h"

//@interface WavingViewController ()
//
//@end
//

@implementation WavingViewController


- (IBAction)wavingChanged:(id)sender {
    NSLog(@"=======waving changed to: %d", self.waving.on);

    if(self.waving.on) {
        NSLog(@"======== reset lastCheckTime");
        [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
    }
    
    [USER_DEFAULTS setBool:self.waving.on forKey:@"waving"];
    [USER_DEFAULTS synchronize];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"#### WavingViewController viewDidLoad ");
    APP_DELEGATE.wavingViewController = self;
    
    NSLog(@"=======waving initializing was %d changed to: %d", self.waving.on, [USER_DEFAULTS boolForKey:@"waving"]);
    self.waving.on = [USER_DEFAULTS boolForKey:@"waving"];
    [self appStatus].text = @"";
    [self checkForNewImages];
}

- (void) checkForNewImages {
    NavigationTabBarViewController *navigationTabBarViewController = (NavigationTabBarViewController*)self.tabBarController;
    NSString* waveName = navigationTabBarViewController.waveName.title;
    
    NSMutableArray *imagesToPostOperations = [NSMutableArray array];
    
    if (self.waving.on) {
        [EWImage checkForNewImagesToPostToWave:waveName
                                whenImageFound:^(UIImage *image, NSDate *imageDate) {
                                    AFHTTPRequestOperation* operation = [EWImage createPostOperationFromImage:image
                                                                                                    imageDate:imageDate
                                                                                                  forWaveName:waveName];
                                    
                                    [imagesToPostOperations addObject:operation];
                                    [self appStatus].text = [NSString stringWithFormat:@"found new images to post: %d", imagesToPostOperations.count];
                                    
                                }
                              whenCheckingDone:^{
                                  [self appStatus].text = @"";
                                  [EWImage postAllNewImages:imagesToPostOperations];
                              }
                                     whenError:^(NSError *error) {
                                         NSLog(@"this error should never happen %@", error.description);
                                         [self appStatus].text = error.description;
                                     }];
    }
}


@end
