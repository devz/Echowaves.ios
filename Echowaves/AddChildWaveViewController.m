//
//  AddChildWaveViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "AddChildWaveViewController.h"

@interface AddChildWaveViewController ()

@end

@implementation AddChildWaveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.childWaveName becomeFirstResponder];
}

- (IBAction)createChildWave:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
