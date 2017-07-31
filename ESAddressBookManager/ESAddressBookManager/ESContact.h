//
//  ESContact.h
//  ESAddressBookManager
//
//  Created by codeLocker on 2017/7/31.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESContact : NSObject
/** 姓 */
@property (nonatomic, strong) NSString *lastName;
/** 中间名 */
@property (nonatomic, strong) NSString *middleName;
/** 名 */
@property (nonatomic, strong) NSString *firstName;
/** 全名 */
@property (nonatomic, strong) NSString *fullName;
/** 姓首字母 */
@property (nonatomic, strong) NSString *lastNameFirstLetter;
/** 电话号码 */
@property (nonatomic, strong) NSArray *phoneNumbers;
@end
