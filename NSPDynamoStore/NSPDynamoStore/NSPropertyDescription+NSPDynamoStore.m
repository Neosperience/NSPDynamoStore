//
//  NSPropertyDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 01/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPropertyDescription+NSPDynamoStore.h"

NSString* const kNSPDynamoStoreAttributeNameKey = @"NSPDynamoStoreAttributeName";

@implementation NSPropertyDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoName
{
    return self.userInfo[kNSPDynamoStoreAttributeNameKey] ? : self.name;
}

@end
