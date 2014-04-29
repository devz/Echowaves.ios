//
//  UploadProgressViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "UploadProgressViewController.h"
#import "EWWave.h"
#import "EWImage.h"

@interface UploadProgressViewController ()

@end

@implementation UploadProgressViewController


-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"sending photos to wave";
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view.
    [self cleanupCurrentUploadView];
    NSLog(@"#### WavingViewController viewDidLoad ");
    [self currentlyUploadingImage].contentMode = UIViewContentModeScaleAspectFit;
    self.uploadProgressBar.progress = 0.0;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForNewImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkForNewImages {
    //try to sign in to see if connection is awailable
    NSURLCredential *credential = [EWWave getStoredCredential];
    if(credential) {
        NSLog(@"User %@ already connected with password.", credential.user);
        
        [EWWave tuneInWithName:credential.user
                   andPassword:credential.password
                       success:^(NSString *waveName) {
                           NSLog(@"successsfully signed in");
                           
                           if (APP_DELEGATE.wavingViewController.waving.on) {
                               
                               [EWImage checkForNewAssetsToPostToWave:waveName
                                                     whenCheckingDone:^(NSArray* assets){
                                                         
//                                                         [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)assets.count];
                                                         //the following like is needed to force update the label
//                                                         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];

                                                         
                                                         NSLog(@"************* images to post %lu", (unsigned long)assets.count);
                                                         if(assets.count == 0) { // this means nothing is found to be posted
//                                                             [NSThread sleepForTimeInterval:2.0f];
                                                             [self.navigationController popViewControllerAnimated:YES];
                                                         } else {
//                                                             for(ALAsset *asset in assets) {
                                                             ALAsset* asset = assets[0];
                                                                 [EWImage operationFromAsset:asset
                                                                        forWaveName:waveName
                                                                       success:^(AFHTTPRequestOperation *operation, UIImage *image, NSDate *currentAssetDateTime) {
                                                                           __weak  AFHTTPRequestOperation* weakOperation = operation;
//                                                                           NSLog(@"1");
                                                                           [weakOperation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                                                                               NSInteger totalBytesWritten,
                                                                                                               NSInteger totalBytesExpectedToWrite) {
                                                                               if(!self.currentlyUploadingImage.image) { // beginning new upload operation here
                                                                                   self.cancelUpload.hidden = FALSE;
                                                                                   self.uploadProgressBar.hidden = FALSE;
                                                                                   
                                                                                   self.currentUploadOperation = weakOperation;
                                                                                   self.currentlyUploadingImage.image = image;
                                                                                   self.currentlyUploadingImage.hidden = FALSE;
                                                                                   [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)assets.count];
                                                                                   //                                            [self imagesToUpload].hidden = FALSE;
                                                                               }
                                                                               
                                                                               self.uploadProgressBar.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
                                                                           }];
                                                                           [weakOperation setCompletionBlock:^{
                                                                               [self cleanupCurrentUploadView];
                                                                               [USER_DEFAULTS setObject:currentAssetDateTime forKey:@"lastCheckTime"];
                                                                               [USER_DEFAULTS synchronize];
                                                                               [self checkForNewImages];
                                                                           }];
                                                                           [APP_DELEGATE.networkQueue addOperation:weakOperation];
//                                                                           [APP_DELEGATE.networkQueue setSuspended:NO];
                                                                       } //success
                                                                  ];// operationFromAsset
//                                                             } // for assets
                                                         } //else
                                                     } // when checking done
                                                            whenError:^(NSError *error) {
                                                                NSLog(@"this error should never happen %@", error.description);
                                                                [EWWave showErrorAlertWithMessage:[error description] FromSender:nil];
                                                                [self.navigationController popViewControllerAnimated:YES];

                                                            }];
                                
                           } // waving on
                       } // tune in with name
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:nil];
                           [self.navigationController popViewControllerAnimated:YES];
                       }];// tune in with name
        
    } else { // credentials are not set, can't really ever happen, something is really wrong here
        NSLog(@"this error should never happen credentials are not set, can't really ever happen, something is really wrong here");
    }
}

- (IBAction)cancelingCurrentUploadOperation:(id)sender {
    [self.currentUploadOperation cancel];
    [self cleanupCurrentUploadView];
}


- (void) cleanupCurrentUploadView {
    self.currentUploadOperation = nil;
    
    self.currentlyUploadingImage.hidden = TRUE;
    self.currentlyUploadingImage.image = nil;
    //    self.imagesToUpload.hidden = TRUE;
//    [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)APP_DELEGATE.networkQueue.operationCount];
    self.uploadProgressBar.progress = 0.0;
    self.uploadProgressBar.hidden = TRUE;
    self.cancelUpload.hidden = TRUE;
}


@end
