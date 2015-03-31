//
//  AWSItem.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "AWSItem.h"

@implementation AWSItem

+(NSString *)dynamoDBTableName
{
    return @"Item";
}

+(NSString *)hashKeyAttribute
{
    return @"objectId";
}

@end
