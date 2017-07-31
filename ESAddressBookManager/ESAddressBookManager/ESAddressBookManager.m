//
//  ESAddressBookManager.m
//  ESAddressBookManager
//
//  Created by codeLocker on 2017/7/28.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import "ESAddressBookManager.h"

NSString * const ESContactLastName = @"ESContactLastName";
NSString * const ESContactMiddleName = @"ESContactMiddleName";
NSString * const ESContactFirstName = @"ESContactFirstName";
NSString * const ESContactFullName = @"ESContactFullName";
NSString * const ESContactLastNameFirstLetter = @"ESContactLastNameFirstLetter";
NSString * const ESContactPhoneNumbers = @"ESContactPhoneNumbers";

@implementation ESAddressBookManager

+ (BOOL)systemVersionGreaterThan_9_0 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0;
}

+ (ESAuthorizationStatus)authorizationState {
    if ([self systemVersionGreaterThan_9_0]) {
        //iOS >= 9.0
        switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
            case CNAuthorizationStatusNotDetermined:
                return ESAuthorizationStatusNotDetermined;
            case CNAuthorizationStatusRestricted:
                return ESAuthorizationStatusRestricted;
            case CNAuthorizationStatusDenied:
                return ESAuthorizationStatusDenied;
            case CNAuthorizationStatusAuthorized:
                return ESAuthorizationStatusAuthorized;
        }
    }else {
        //iOS < 9.0
        switch (ABAddressBookGetAuthorizationStatus()) {
            case kABAuthorizationStatusNotDetermined:
                return ESAuthorizationStatusNotDetermined;
            case kABAuthorizationStatusRestricted:
                return ESAuthorizationStatusRestricted;
            case kABAuthorizationStatusDenied:
                return ESAuthorizationStatusDenied;
            case kABAuthorizationStatusAuthorized:
                return ESAuthorizationStatusAuthorized;
        }
    }
}

+ (void)authorization:(void (^)(void))accept decline:(void (^)(NSError *))decline {
    if ([self systemVersionGreaterThan_9_0]) {
        //iOS >= 9.0
        [[[CNContactStore alloc]init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(granted){
                if (accept) accept();
            }else {
                if (decline) decline(error);
            }
        }];
    }else {
        //iOS < 9.0
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            if(granted){
                if (accept) accept();
            }else{
                if (decline) {
                    decline((__bridge NSError *)error);
                }
            }
        });
    }
}

+ (NSArray<ESContact *> *)fetchContactsWithKeys:(NSArray<NSString *> *)keys {
    if (!keys || ![keys isKindOfClass:[NSArray class]] || keys.count == 0) {
        keys = @[ESContactLastName,ESContactMiddleName,ESContactFirstName,ESContactFullName,ESContactLastNameFirstLetter,ESContactPhoneNumbers];
    }
    if ([self systemVersionGreaterThan_9_0]) {
        return [self fetchGreaterIOS9ContactsWithKeys:keys];
    }else {
        return [self fetchLessIOS9ContactsWithKeys:keys];
    }
    return nil;
}

+ (NSArray<ESContact *> *)fetchGreaterIOS9ContactsWithKeys:(NSArray<NSString *> *)keys {
    NSMutableArray *translateKeys = [NSMutableArray array];
    for (NSString *key in keys) {
        if ([key isEqualToString:ESContactLastName]) {
            [translateKeys addObject:CNContactFamilyNameKey];
            
        }else if ([key isEqualToString:ESContactMiddleName]) {
            [translateKeys addObject:CNContactMiddleNameKey];
            
        }else if ([key isEqualToString:ESContactFirstName]) {
            [translateKeys addObject:CNContactGivenNameKey];
            
        }else if ([key isEqualToString:ESContactFullName]) {
            if (![keys containsObject:ESContactLastName]) [translateKeys addObject:ESContactLastName];
            if (![keys containsObject:ESContactMiddleName]) [translateKeys addObject:ESContactMiddleName];
            if (![keys containsObject:ESContactFirstName]) [translateKeys addObject:ESContactFirstName];
            
        }else if ([key isEqualToString:ESContactLastNameFirstLetter]) {
            if (![keys containsObject:ESContactLastName]) [translateKeys addObject:ESContactLastName];
            
        }else if ([key isEqualToString:ESContactPhoneNumbers]) {
            [translateKeys addObject:CNContactPhoneNumbersKey];
        }
    }
    // 获取
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:translateKeys];
    // 遍历
    NSError *error;
    NSMutableArray *contacts = [NSMutableArray array];
    [contactStore enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact *cnContact, BOOL *stop) {
        if (error) {
        }else {
            ESContact *contact = [[ESContact alloc] init];
            if ([keys containsObject:ESContactLastName]) {
                contact.lastName = cnContact.familyName;
            }
            if ([keys containsObject:ESContactMiddleName]) {
                contact.middleName = cnContact.middleName;
            }
            if ([keys containsObject:ESContactFirstName]) {
                contact.firstName = cnContact.givenName;
            }
            if ([keys containsObject:ESContactFullName]) {
                contact.fullName = [NSString stringWithFormat:@"%@%@%@",cnContact.familyName, cnContact.middleName, cnContact.givenName];
            }
            if ([keys containsObject:ESContactLastNameFirstLetter]) {
                NSString *pinYin = [self transformToPinYin:cnContact.familyName];
                if (pinYin.length > 0) {
                    contact.lastNameFirstLetter = [[pinYin substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                }else {
                    contact.lastNameFirstLetter = @"#";
                }
            }
            if ([keys containsObject:ESContactPhoneNumbers]) {
                NSMutableArray *phoneNumbres = [NSMutableArray array];
                for (CNLabeledValue *labeledValue in cnContact.phoneNumbers) {
                    CNPhoneNumber *phoneNumer = labeledValue.value;
                    [phoneNumbres addObject:phoneNumer.stringValue];
                }
                contact.phoneNumbers = [phoneNumbres copy];
            }
            [contacts addObject:contact];
        }
    }];
    return [contacts copy];
}
+ (NSArray<ESContact *> *)fetchLessIOS9ContactsWithKeys:(NSArray<NSString *> *)keys {
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *allContacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBookRef));
    NSMutableArray *contacts = [NSMutableArray array];
    for (int i = 0 ; i < allContacts.count; i++) {
        ABRecordRef person = (__bridge ABRecordRef)(allContacts[i]);
        ESContact *contact = [[ESContact alloc] init];
        if ([keys containsObject:ESContactLastName]) {
            contact.lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        }
        if ([keys containsObject:ESContactMiddleName]) {
            contact.middleName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
        }
        if ([keys containsObject:ESContactFirstName]) {
            contact.firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        }
        if ([keys containsObject:ESContactFullName]) {
            contact.fullName = [NSString stringWithFormat:@"%@%@%@",(__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)), (__bridge NSString *)(ABRecordCopyValue(person, kABPersonMiddleNameProperty)), (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty))];
        }
        if ([keys containsObject:ESContactLastNameFirstLetter]) {
            NSString *pinYin = [self transformToPinYin:(__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty))];
            if (pinYin.length > 0) {
                contact.lastNameFirstLetter = [[pinYin substringWithRange:NSMakeRange(0, 1)] uppercaseString];
            }else {
                contact.lastNameFirstLetter = @"#";
            }
        }
        if ([keys containsObject:ESContactPhoneNumbers]) {
            NSMutableArray *phoneNumbres = [NSMutableArray array];
            ABMultiValueRef phoneRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (NSInteger i = 0; i< ABMultiValueGetCount(phoneRef); i++) {
                NSString *phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneRef, i));
                [phoneNumbres addObject:phoneNumber];
            }
            contact.phoneNumbers = phoneNumbres;
        }
        [contacts addObject:contact];
    }
    return contacts;
}

+ (NSArray<NSDictionary *> *)fetchContactsWithKeys:(NSArray<NSString *> *)keys groupOption:(ESGroupOption)groupOption sort:(ESSortOption)sortOption {
    if (![keys containsObject:ESContactLastNameFirstLetter]) {
        keys = [keys arrayByAddingObjectsFromArray:@[ESContactLastNameFirstLetter]];
    }
    NSArray *contacts = [self fetchContactsWithKeys:keys];
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];

    for (ESContact *contact in contacts) {
        if ([contactDic.allKeys containsObject:contact.lastNameFirstLetter]) {
            //已经存在
            NSMutableArray *array = contactDic[contact.lastNameFirstLetter];
            [array addObject:contact];
            [contactDic setObject:array forKey:contact.lastNameFirstLetter];
        }else {
            //不存在
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:contact];
            [contactDic setObject:array forKey:contact.lastNameFirstLetter];
        }
    }
    NSArray *sortedLastNameFirstLetters = [contactDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        switch (sortOption) {
            case ESSortOptionAscend:
                return [obj1 compare:obj2];
            case ESSortOptionDescend:
                return [obj2 compare:obj1];
        }
    }];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *key in sortedLastNameFirstLetters) {
        [result addObject:@{key : contactDic[key]}];
    }
    return result;
}

#pragma mark - Private_Methods
/**
 汉字转拼音

 @param string 汉字
 @return 拼音
 */
+ (NSString *)transformToPinYin:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [string mutableCopy];
    //将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    //返回最近结果
    return pinyin;
}
@end
