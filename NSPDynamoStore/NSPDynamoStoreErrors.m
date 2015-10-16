//
//  NSPDynamoStoreErrors.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 03/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NSPDynamoStoreErrors.h"

NSString* const NSPDynamoStoreErrorDomain = @"com.neosperience.NSPDynamoStoreErrorDomain";

@implementation NSPDynamoStoreErrors

+(NSError *)fetchErrorWithUnderlyingError:(NSError *)error
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    userInfo[NSLocalizedDescriptionKey] = NSLocalizedStringFromTable(@"Failed to execute database request.", @"NSPDynamoStore", @"fetch error description");
    userInfo[NSLocalizedFailureReasonErrorKey] = NSLocalizedStringFromTable(@"DynamoDB returned an error.", @"NSPDynamoStore", @"fetch error reason");
    userInfo[NSUnderlyingErrorKey] = error;
    return [NSError errorWithDomain:NSPDynamoStoreErrorDomain code:NSPDynamoStoreFetchErrorCode userInfo:userInfo];
}

@end
