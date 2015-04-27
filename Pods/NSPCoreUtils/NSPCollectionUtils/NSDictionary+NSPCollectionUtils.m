//
//  NSDictionary+NSPCollectionUtils.m
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 09/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import "NSDictionary+NSPCollectionUtils.h"

@implementation NSDictionary (NSPCollectionUtils)

-(NSDictionary*)reverseDictionary
{
    NSMutableDictionary* reverseDictionary = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    
    for (id key in self) {
        id value = self[key];
        reverseDictionary[value] = key;
    }
    
    return [reverseDictionary copy];
}

-(NSDictionary *)filteredDictionaryForSubsetOfKeys:(NSSet *)keys
{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    for (id key in keys) {
        result[key] = self[key];
    }
    return [result copy];
}

-(NSDictionary *)filteredDictionaryForKeysPassingPredicate:(NSPredicate *)predicate
{
    NSSet* filteredKeys = [[NSSet setWithArray:[self allKeys]] filteredSetUsingPredicate:predicate];
    return [self filteredDictionaryForSubsetOfKeys:filteredKeys];
}

-(NSDictionary *)filteredDictionaryForKeysPassingTest:(BOOL (^)(id, BOOL *))predicate
{
    NSSet* filteredKeys = [[NSSet setWithArray:[self allKeys]] objectsPassingTest:predicate];
    return [self filteredDictionaryForSubsetOfKeys:filteredKeys];
}

-(NSDictionary *)mapIncludingNullValues:(BOOL)includeNullValues iteratee:(id (^)(id, id))iteratee
{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (id key in self.allKeys) {

        id mappedValue = iteratee(key, self[key]);
        if (mappedValue) {
            result[key] = mappedValue;
        } else if (includeNullValues) {
            result[key] = [NSNull null];
        }

        [result setValue:iteratee(key, self[key]) forKey:key];
    }
    return [result copy];
}

-(NSDictionary *)map:(id (^)(id, id))iteratee
{
    return [self mapIncludingNullValues:NO iteratee:iteratee];
}

@end
