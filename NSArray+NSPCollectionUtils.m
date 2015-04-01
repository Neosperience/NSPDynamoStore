//
//  NSArray+NSPCollectionUtils.m
//  Somebody
//
//  Created by Janos Tolgyesi on 02/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import "NSArray+NSPCollectionUtils.h"

@implementation NSArray (NSPCollectionUtils)

-(NSArray*)map:(id (^)(id))iteratee
{
    NSParameterAssert(iteratee);
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id item in self) { [result addObject:(iteratee(item) ? : [NSNull null])]; }
    return [result copy];
}

-(NSArray*)mapWithDictionary:(NSDictionary*)map
{
    return [self map:^id(id item) { return map[item]; }];
}

-(NSArray*)reduce
{
    NSMutableArray* result = [NSMutableArray array];
    for (id item in self) {
        NSAssert([item respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)],
                 @"All items in the collection must implement NSFastEnumeration protocol!");
        for (id subItem in item) { [result addObject:subItem]; }
    }
    return [result copy];
}

-(NSArray *)explodeToSubarraysWithLength:(NSUInteger)subArrayLength
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count] / subArrayLength + 1];
    for (NSUInteger start = 0; start < [self count]; start += subArrayLength) {
        NSRange range = NSMakeRange(start, subArrayLength);
        NSInteger overFlow = NSMaxRange(range) - [self count];
        if (overFlow > 0) range.length -= overFlow;
        [result addObject:[self subarrayWithRange:range]];
    }
    return [result copy];
}

@end