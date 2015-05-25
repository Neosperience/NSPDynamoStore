//
//  AWSDynamoDBAttributeValue+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"

#import <AWSCategory.h>

@implementation AWSDynamoDBAttributeValue (NSPDynamoStore)

-(void)nsp_setAttributeValue:(id)attributeValue
{
    if ([attributeValue isKindOfClass:[[NSNumber numberWithBool:YES] class]]) {
        self.BOOLEAN = attributeValue;
    } else if ([attributeValue isKindOfClass:[NSString class]]) {
        self.S = attributeValue;
    } else if ([attributeValue isKindOfClass:[NSNumber class]]) {
        self.N = [attributeValue stringValue];
    } else if ([attributeValue isKindOfClass:[NSData class]]) {
        self.B = attributeValue;
    } else if ([attributeValue isKindOfClass:[NSSet class]] && [(NSSet *)attributeValue count] > 0) {
        id anyObject = [attributeValue anyObject];
        if ([anyObject isKindOfClass:[NSString class]]) {
            self.SS = [attributeValue allObjects];
        } else if ([anyObject isKindOfClass:[NSNumber class]]) {
            NSMutableArray *NS = [NSMutableArray new];
            [attributeValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [NS addObject:[obj stringValue]];
            }];
            self.NS = NS;
        } else if ([anyObject isKindOfClass:[NSData class]]) {
            self.BS = [attributeValue allObjects];
        }
    } else if ([attributeValue isKindOfClass:[NSArray class]] && [(NSArray *)attributeValue count] > 0) {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:[(NSArray *)attributeValue count]];
        for (id listItem in attributeValue) {
            AWSDynamoDBAttributeValue *listItemAttributeValue = [AWSDynamoDBAttributeValue new];
            [listItemAttributeValue nsp_setAttributeValue:listItem];
            [list addObject:listItemAttributeValue];
        }
        self.L = list;
    } else if ([attributeValue isKindOfClass:[NSDictionary class]] && [(NSDictionary *)attributeValue count] > 0) {
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:[(NSDictionary *)attributeValue count]];
        for (NSString *mapItemKey in attributeValue) {
            id mapItemValue = attributeValue[mapItemKey];
            AWSDynamoDBAttributeValue *mapItemAttributeValue = [AWSDynamoDBAttributeValue new];
            [mapItemAttributeValue nsp_setAttributeValue:mapItemValue];
            [map setObject:mapItemAttributeValue forKey:mapItemKey];
        }
        self.M = map;
    }
}

-(id)nsp_getAttributeValue
{
    if (self.BOOLEAN) {
        return self.BOOLEAN;
    } else if (self.S) {
        return self.S;
    } else if (self.N) {
        return [NSNumber aws_numberFromString:self.N];
    } else if (self.B) {
        return self.B;
    } else if (self.SS) {
        return [NSSet setWithArray:self.SS];
    } else if (self.NS) {
        NSMutableSet *mutableSet = [NSMutableSet new];
        [self.NS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mutableSet addObject:[NSNumber aws_numberFromString:obj]];
        }];

        return mutableSet;
    } else if (self.BS) {
        return [NSSet setWithArray:self.BS];
    } else if (self.L) {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:self.L.count];
        for (id listItemAttributeValue in self.L) {
            id attributeValue = [listItemAttributeValue nsp_getAttributeValue];
            if (attributeValue) [list addObject:attributeValue];
        }
        return list;

    } else if (self.M) {
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:self.M.count];
        for (NSString *entryAttributeKey in self.M) {
            id entryAttributeValue = self.M[entryAttributeKey];
            [map setValue:[entryAttributeValue nsp_getAttributeValue] forKey:entryAttributeKey];
        }
        return map;
    } 

    return nil;
}

@end
