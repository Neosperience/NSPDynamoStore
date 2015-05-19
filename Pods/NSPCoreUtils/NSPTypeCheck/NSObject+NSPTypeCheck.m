//
//  NSObject+NSPTypeCheck.m
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSObject+NSPTypeCheck.h"

@implementation NSObject (NSPTypeCheck)

+(instancetype)typeCheckedCast:(id)dataObject
{
    [self typeCheck:dataObject];
    return dataObject;
}

+(void)typeCheck:(id)dataObject
{
    NSAssert(!dataObject || [dataObject isKindOfClass:[self class]],
             @"Unexpected object type: %@ (expected %@)", NSStringFromClass([dataObject class]), NSStringFromClass([self class]));
}

+(instancetype)typeCastOrNil:(id)dataObject
{
    return [dataObject isKindOfClass:[self class]] ? dataObject : nil;
}

@end
