//
//  NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <NSPCoreUtils/NSPDefines.h>

NSP_EXTERN NSString* const NSPDynamoStoreType;
NSP_EXTERN NSString* const NSPDynamoStoreDynamoDBKey;

@interface NSPDynamoStore : NSIncrementalStore

@end
