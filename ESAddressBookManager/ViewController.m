//
//  ViewController.m
//  ESAddressBookManager
//
//  Created by codeLocker on 2017/7/28.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import "ViewController.h"
#import "ESAddressBookManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ESAuthorizationStatus status = [ESAddressBookManager authorizationState];
    switch (status) {
        case ESAuthorizationStatusDenied:
        case ESAuthorizationStatusRestricted:
            NSLog(@"denied");
            break;
        case ESAuthorizationStatusNotDetermined:
            
            [ESAddressBookManager authorization:^{
                NSLog(@"success");
            } decline:^(NSError *error) {
                NSLog(@"fail");
            }];
            break;
        case ESAuthorizationStatusAuthorized:
            NSLog(@"Authorized");
            break;
    }
//    NSArray *contacts = [ESAddressBookManager fetchContactsWithKeys:@[ESContactLastName]];
//    NSLog(@"%@",contacts);
    NSArray *array =  [ESAddressBookManager fetchContactsWithKeys:nil groupOption:ESGroupOptionLastNameFirstLetter sort:ESSortOptionAscend];
    NSLog(@"%@",array);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
