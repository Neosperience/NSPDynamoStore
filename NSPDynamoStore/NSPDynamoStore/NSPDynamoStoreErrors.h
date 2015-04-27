//
//  NSPDynamoStoreErrors.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 03/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <NSPCoreUtils.h>

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NSPDynamoStoreFetchErrorCode = 1000,
} NSPDynamoStoreErrorCode;

NSP_EXTERN NSString* const NSPDynamoStoreErrorDomain;

@interface NSPDynamoStoreErrors : NSObject

+(NSError*)fetchErrorWithUnderlyingError:(NSError*)error;

@end
