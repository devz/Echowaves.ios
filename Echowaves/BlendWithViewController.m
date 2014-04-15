//
//  BlendWithViewController.m
//  Echowaves
//
//  Created by Dmitry on 2/8/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "BlendWithViewController.h"
#import "EWBlend.h"

@implementation BlendWithViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.blendWithSearchBar becomeFirstResponder];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    NSLog(@"search text: %@", searchText);
    if(searchText.length <100 && searchText.length > 3) {
        [EWBlend autoCompleteFor:searchText
                         success:^(NSArray *waveNames) {
                             self.searchResults = waveNames;
                             [self.wavesNamesTableView reloadInputViews];
                             [self.wavesNamesTableView reloadData];
                         }
                         failure:^(NSError *error) {
                             [EWWave showErrorAlertWithMessage:[error description] FromSender:nil];
                         }];
    } else {
        self.searchResults = [[NSArray alloc] init];
        [self.wavesNamesTableView reloadInputViews];
        [self.wavesNamesTableView reloadData];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"tableView number of rows: %lu", (unsigned long)self.searchResults.count);
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tableView cellForRowAtIndexPath: %ld", (long)indexPath.row);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaveCompletionTableCell" forIndexPath:indexPath];
    
    UILabel *waveNameLabel = (UILabel *)[cell viewWithTag:42];
    
    NSString *waveName = [((NSDictionary*)[self.searchResults objectAtIndex:indexPath.row]) objectForKey:@"label"];

    waveNameLabel.text = waveName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *waveNameSelected = [((NSDictionary*)[self.searchResults objectAtIndex:indexPath.row]) objectForKey:@"label"];
    NSLog(@"didSelectRowAtIndex: %ld, value %@", (long)indexPath.row, waveNameSelected);

    [EWBlend showLoadingIndicator:self];
    [EWBlend requestBlendingWith:waveNameSelected
                         success:^{
                             [EWBlend hideLoadingIndicator:self];
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         failure:^(NSError *error) {
                             [EWBlend hideLoadingIndicator:self];
                             [EWWave showErrorAlertWithMessage:@"error unblending" FromSender:nil];
                             [self.navigationController popViewControllerAnimated:YES];
                         }];
}


@end
