//
//  NSEntityDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSEntityDescription+NSPDynamoStore.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"

#import <AWSDynamoDB.h>

NSString* const kNSPDynamoStoreEntityHashKeyAttributeNameKey = @"NSPDynamoStoreEntityHashKeyAttributeName";
NSString* const kNSPDynamoStoreEntityRangeKeyAttributeNameKey = @"NSPDynamoStoreEntityRangeKeyAttributeName";
NSString* const kNSPDynamoStoreEntityDynamoDBTableNameKey = @"NSPDynamoStoreEntityDynamoDBTableName";

NSString* const kNSPDynamoStoreAttributeNameKey = @"NSPDynamoStoreAttributeName";

@implementation NSEntityDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoHashKeyName
{
    return self.userInfo[kNSPDynamoStoreEntityHashKeyAttributeNameKey];
}

-(NSString*)nsp_dynamoRangeKeyName
{
    return self.userInfo[kNSPDynamoStoreEntityRangeKeyAttributeNameKey];
}

-(NSString*)nsp_dynamoTableName
{
    return self.userInfo[kNSPDynamoStoreEntityDynamoDBTableNameKey] ? : self.name;
}

-(NSDictionary*)nsp_dynamoDBAttributesToNativeAttributes:(NSDictionary*)dynamoAttributes
{
    NSMutableDictionary* transformedValues = [NSMutableDictionary dictionaryWithCapacity:[dynamoAttributes count]];

    [self.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSAttributeDescription* attribute, BOOL *stop) {
        NSString* dynamoAttributeName = attribute.userInfo[kNSPDynamoStoreAttributeNameKey] ? : attributeName;
        AWSDynamoDBAttributeValue* dynamoAttribute = dynamoAttributes[dynamoAttributeName];
        if (dynamoAttribute) {
            [transformedValues setValue:[dynamoAttribute nsp_getAttributeValue] forKey:attributeName];
        }
     }];

    return transformedValues;
}

@end
