//
//  NSEntityDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPropertyDescription+NSPDynamoStore.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"

#import <AWSDynamoDB.h>

NSString* const kNSPDynamoPrimaryHashKey = @"NSPDynamoPrimaryHashKey";
NSString* const kNSPDynamoPrimaryRangeKey = @"NSPDynamoPrimaryRangeKey";
NSString* const kNSPDynamoTableNameKey = @"NSPDynamoTableName";

@implementation NSEntityDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoHashKeyName
{
    NSString* hashKeyName = self.userInfo[kNSPDynamoPrimaryHashKey];
    NSAssert(hashKeyName, @"NSPDynamoStore: The user info of the entity must contain a value for %@ key for entity: %@",
             kNSPDynamoPrimaryHashKey, self);
    return hashKeyName;
}

-(NSString*)nsp_dynamoPrimaryRangeKeyName
{
    return self.userInfo[kNSPDynamoPrimaryRangeKey];
}

-(NSString*)nsp_dynamoTableName
{
    return self.userInfo[kNSPDynamoTableNameKey] ? : self.name;
}

@end
