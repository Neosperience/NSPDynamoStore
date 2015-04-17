//
//  NSPTimestampValueTransformer.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 17/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPTimestampValueTransformer.h"

NSString* const NSPTimestampValueTransformerName = @"NSPTimestampValueTransformer";

@implementation NSPTimestampValueTransformer

+(void)load
{
    [NSValueTransformer setValueTransformer:[self new] forName:NSPTimestampValueTransformerName];
}

+ (Class)transformedValueClass
{
    return [NSDate class];
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
    } else {
        return nil;
    }
}

-(id)reverseTransformedValue:(id)value
{
    if ([value isKindOfClass:[NSDate class]]) {
        return @([value timeIntervalSince1970]);
    } else {
        return nil;
    }
}

@end
