//
//  NSArray+NSPCollectionUtils.m
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 02/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import "NSArray+NSPCollectionUtils.h"

@implementation NSArray (NSPCollectionUtils)

-(NSArray*)mapIncludingNullValues:(BOOL)includeNullValues iteratee:(id (^)(id))iteratee
{
    NSParameterAssert(iteratee);
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id item in self) {
        id mappedItem = iteratee(item);
        if (mappedItem) {
            [result addObject:mappedItem];
        } else if (includeNullValues) {
            [result addObject:[NSNull null]];
        }
    }
    return [result copy];

}

-(NSArray*)map:(id (^)(id))iteratee
{
    return [self mapIncludingNullValues:NO iteratee:iteratee];
}

-(NSArray*)mapIncludingNullValues:(BOOL)includeNullValues withDictionary:(NSDictionary*)map
{
    return [self mapIncludingNullValues:includeNullValues iteratee:^id(id item) { return map[item]; }];
}

-(NSArray*)mapWithDictionary:(NSDictionary*)map
{
    return [self mapIncludingNullValues:NO withDictionary:map];
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

-(NSArray*)shiftedArray:(id __autoreleasing *)shiftedElement
{
    NSParameterAssert([self count] > 0);
    if (shiftedElement) *shiftedElement = [self firstObject];
    return [self subarrayWithRange:NSMakeRange(1, [self count] - 1)];
}

-(NSArray *)poppedArray:(__autoreleasing id *)poppedElement
{
    NSParameterAssert([self count] > 0);
    if (poppedElement) *poppedElement = [self lastObject];
    return [self subarrayWithRange:NSMakeRange(0, [self count] - 1)];
}

@end
