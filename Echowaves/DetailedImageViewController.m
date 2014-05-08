//
//  DetailedImageViewController.m
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "DetailedImageViewController.h"
#import "EWImage.h"

@interface DeleteImageAlertView : UIAlertView
@property (nonatomic) NSString *waveName;
@property (nonatomic) NSString *imageName;
@end
@implementation DeleteImageAlertView
@end


@implementation DetailedImageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //    NSLog(@"###########imageFromJson %@", self.imageFromJson);
    NSString* imageName = [self.imageFromJson objectForKey:@"name"];
    NSString* waveName = [self.imageFromJson objectForKey:@"name_2"];
    //    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/%@", EWAWSBucket, waveName, imageName];
    
//    [self.navigationItem setPrompt:waveName];
    [[self waveName] setText:waveName];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat : @"yyyyMMddHHmmssSSSS"];
    NSString *dateString = [imageName substringWithRange:NSMakeRange(0, 18)];
    NSLog(@"imageName  = %@", imageName);
    NSLog(@"dateString = %@", dateString);
    NSDate *dateTime = [formatter dateFromString:dateString];
    
//    [formatter release];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [self setTitle:[formatter stringFromDate:dateTime]];
    
//    [[self navigationItem].backBarButtonItem setTitle:@" "];
    
    if ([waveName isEqualToString:[APP_DELEGATE currentWaveName]]) {
        
        UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(deleteImage)];

        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(shareImage)];
        
        self.navigationItem.rightBarButtonItems = @[shareButton, deleteButton];
    } else {
        [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                 target:self
                                                                                                 action:@selector(saveImage)];
        
    }
    
    
    
    self.progressView.progress = 0.0;
    [self.progressView setHidden:FALSE];
    
    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
                          self.imageView.image = image;
                          self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                          [self.progressView setHidden:TRUE];
                      }
                      failure:^(NSError *error) {
                          [EWDataModel showErrorAlertWithMessage:@"Error Loading image" FromSender:nil];
                          NSLog(@"error: %@", error.description);
                      }
                     progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                         self.progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                     }];
    
}

//-(void) popBack {
//    [self.navigationController popViewControllerAnimated:YES];
//}


-(void)deleteImage {
    NSLog(@"deleting image");
    NSString* imageName = [self.imageFromJson objectForKey:@"name"];
    NSString* waveName = [APP_DELEGATE currentWaveName];
    
    DeleteImageAlertView *alertMessage = [[DeleteImageAlertView alloc] initWithTitle:@"Alert"
                                                                             message:@"Delete?"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                                   otherButtonTitles:@"OK", nil];
    alertMessage.waveName = waveName;
    alertMessage.imageName = imageName;
    alertMessage.tag = 20002;
    [alertMessage show];

    
    
}

-(void)shareImage {
    NSLog(@"sharing image");
    
    ABPeoplePickerNavigationController *peoplePicker =
    [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:YES completion:^{
        NSLog(@"done presenting");
    }];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {//OK button clicked, let's delete the wave
        [EWImage showLoadingIndicator:self];
        [EWImage deleteImage:[(DeleteImageAlertView*)alertView imageName]
                      inWave:[(DeleteImageAlertView*)alertView waveName]
                     success:^{
                         [self.navigationController popViewControllerAnimated:YES];
                         [EWImage hideLoadingIndicator:self];
                     }
                     failure:^(NSError *error) {
                         [EWImage hideLoadingIndicator:self];
                         [EWImage showErrorAlertWithMessage:@"Unable to delete image" FromSender:nil];
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
        
    }
}


-(void)saveImage {
    [EWImage saveImageToAssetLibrary:[self image]
                             success:^{
                                 [EWDataModel showAlertWithMessage:@"Photo Saved to iPhone"
                                                        FromSender:nil];
                             }
                             failure:^(NSError *error) {
                                 [EWDataModel showErrorAlertWithMessage:@"Error saving" FromSender:nil];
                             }]
    ;
}




@end
