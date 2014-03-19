//
//  HomeViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationTabBarViewController.h"
#import "EWWave.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (IBAction)backToHomeViewController:(UIStoryboardSegue *)segue
{
    NSLog(@"from segue id: %@", segue.identifier);
    [EWWave tuneOut];
}


- (void) viewDidLoad {
    //user is signed in before
    //try to sign in to see if connection is awailable
    NSURLCredential *credential = [EWWave getStoredCredential];
    if(credential) {
        NSLog(@"$$$$$$$$$$$$$$$$User %@ already connected with password.", credential.user);
        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~ preparing to sign in");
        [EWWave showLoadingIndicator:self];
        [EWWave tuneInWithName:credential.user
                   andPassword:credential.password
                       success:^(NSString *waveName) {
                           [EWWave hideLoadingIndicator:self];
                           [self performSegueWithIdentifier: @"AutoSignIn" sender: self];
                       }
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:self];
                       }];
        
    } else { // credentials are not set, can't really ever happen, something is really wrong here
        NSLog(@"this error should never happen credentials are not set, can't really ever happen, something is really wrong here");
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AutoSignIn"]) {
        NSLog(@"seguiing autosignin");
//        NavigationTabBarViewController* destinationController =  (NavigationTabBarViewController *)segue.destinationViewController;
    }
}


@end
