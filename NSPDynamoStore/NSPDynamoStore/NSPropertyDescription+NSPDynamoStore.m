//
//  NSPropertyDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 01/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPropertyDescription+NSPDynamoStore.h"

NSString* const kNSPDynamoAttributeKey = @"NSPDynamoAttributeKey";
NSString* const kNSPDynamoValueTransformerName = @"NSPDynamoValueTransformerName";

@implementation NSPropertyDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoName
{
    return self.userInfo[kNSPDynamoAttributeKey] ? : self.name;
}

-(NSValueTransformer*)nsp_valueTransformer
{
    NSString* valueTransformerName = self.userInfo[kNSPDynamoValueTransformerName];
    return valueTransformerName ? [NSValueTransformer valueTransformerForName:valueTransformerName] : nil;
}

@end
