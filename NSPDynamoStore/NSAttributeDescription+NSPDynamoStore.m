//
//  NSAttributeDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 15/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSAttributeDescription+NSPDynamoStore.h"

@implementation NSAttributeDescription (NSPDynamoStore)

-(BOOL)nsp_isStringType
{
    return (self.attributeType == NSStringAttributeType);
}

-(BOOL)nsp_isNumberType
{
    return (self.attributeType == NSInteger16AttributeType ||
            self.attributeType == NSInteger32AttributeType ||
            self.attributeType == NSInteger64AttributeType ||
            self.attributeType == NSDecimalAttributeType ||
            self.attributeType == NSDoubleAttributeType ||
            self.attributeType == NSFloatAttributeType);
}

@end
