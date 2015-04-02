//
//  NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NSPDefines.h"

NSP_EXTERN NSString* const NSPDynamoStoreAWSServiceConfigurationKey;

@interface NSPDynamoStore : NSIncrementalStore

+ (NSString *)storeType;

@end
