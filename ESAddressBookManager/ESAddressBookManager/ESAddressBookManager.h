//
//  ESAddressBookManager.h
//  ESAddressBookManager
//
//  Created by codeLocker on 2017/7/28.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ESContact.h"

typedef NS_ENUM(NSInteger, ESAuthorizationStatus)
{
    /** 未知 */
    ESAuthorizationStatusNotDetermined = 0,
    /** 保密 */
    ESAuthorizationStatusRestricted,
    /** 拒绝 */
    ESAuthorizationStatusDenied,
    /** 授权 */
    ESAuthorizationStatusAuthorized
};

typedef NS_ENUM(NSInteger, ESGroupOption) {
    /** 姓首字母 */
    ESGroupOptionLastNameFirstLetter
};

typedef NS_ENUM(NSInteger, ESSortOption) {
    /** 升序 */
    ESSortOptionAscend,
    /** 降序 */
    ESSortOptionDescend
};

/** 名 */
extern NSString * const ESContactLastName;
/** 中间名 */
extern NSString * const ESContactMiddleName;
/** 姓 */
extern NSString * const ESContactFirstName;
/** 全名 */
extern NSString * const ESContactFullName;
/** 姓的首字母 */
extern NSString * const ESContactLastNameFirstLetter;
/** 电话号码 */
extern NSString * const ESContactPhoneNumbers;

@interface ESAddressBookManager : NSObject

/**
 通讯录当前访问权限

 @return 访问权限
 */
+ (ESAuthorizationStatus)authorizationState;

/**
 通讯录授权
 
 @param accept 授权
 @param decline 拒绝
 */
+ (void)authorization:(void(^)(void))accept decline:(void(^)(NSError *error))decline;

/**
 获取通讯录联系人

 @param keys 需要获取的联系人的属性
 @return 联系人
 */
+ (NSArray<ESContact *> *)fetchContactsWithKeys:(NSArray<NSString *> *)keys;

/**
 获取通讯录联系人

 @param keys 需要获取的联系人的属性
 @param groupOption 根据什么分组
 @param sortOption 分组排序
 @return 联系人
 */
+ (NSArray<NSDictionary *> *)fetchContactsWithKeys:(NSArray<NSString *> *)keys groupOption:(ESGroupOption)groupOption sort:(ESSortOption)sortOption;

@end
