//
//  NSPDynamoStoreIndexDescriptor.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 17/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoStoreKeyPairDescriptor.h"

NSString* const kNSPDynamoStoreIndexDescriptorInvalidFormatMessage =
    @"NSPDynamoStore: indices value must be in the following format: "
    "{ indexName1 : [ hashKeyName1, rangeKeyName1 ],  indexName2 : [ hashKeyName2, rangeKeyName2 ] }";

NSString* const kNSPDynamoStoreKeyPairDescriptorInvalidFormatMessage =
    @"NSPDynamoStore: key pair value must be in the following format: [ hashKeyName, rangeKeyName ]";

@implementation NSPDynamoStoreKeyPairDescriptor

- (instancetype)initWithArray:(NSArray*)array
{
    self = [self init];
    if (self) {
        NSAssert([array count] == 1 || [array count] == 2, kNSPDynamoStoreKeyPairDescriptorInvalidFormatMessage);
        NSAssert([array[0] isKindOfClass:[NSString class]], kNSPDynamoStoreKeyPairDescriptorInvalidFormatMessage);
        self.hashKeyName = array[0];
        if ([array count] == 2) {
            NSAssert([array[1] isKindOfClass:[NSString class]], kNSPDynamoStoreKeyPairDescriptorInvalidFormatMessage);
            self.rangeKeyName = array[1];
        }
    }
    return self;
}

+(instancetype)keyPairWithArray:(NSArray*)array
{
    return [[self alloc] initWithArray:array];
}

- (instancetype)initWithString:(NSString *)string
{
    NSData* keyPairData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonReadError = nil;
    id indicesObject = [NSJSONSerialization JSONObjectWithData:keyPairData options:0 error:&jsonReadError];
    NSAssert(!jsonReadError, @"NSPDynamoStore: Error parsing key pair JSON in user info. Value: %@, error: %@", string, jsonReadError);
    NSAssert([indicesObject isKindOfClass:[NSArray class]], kNSPDynamoStoreKeyPairDescriptorInvalidFormatMessage);
    return [self initWithArray:indicesObject];
}

+(instancetype)keyPairWithString:(NSString *)string
{
    return [[self alloc] initWithString:string];
}

+(NSDictionary*)indicesWithString:(NSString*)string
{
    NSData* indicesData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonReadError = nil;
    id indicesObject = [NSJSONSerialization JSONObjectWithData:indicesData options:0 error:&jsonReadError];
    NSAssert(!jsonReadError, @"NSPDynamoStore: Error parsing indices JSON in user info. Value: %@, error: %@", string, jsonReadError);
    NSAssert([indicesObject isKindOfClass:[NSDictionary class]], kNSPDynamoStoreIndexDescriptorInvalidFormatMessage);

    NSMutableDictionary* results = [NSMutableDictionary dictionaryWithCapacity:[indicesObject count]];
    for (NSString* indexName in [indicesObject allKeys]) {
        NSAssert([indexName isKindOfClass:[NSString class]], kNSPDynamoStoreIndexDescriptorInvalidFormatMessage);
        NSArray* keyNames = indicesObject[indexName];
        NSAssert(([keyNames isKindOfClass:[NSArray class]]), kNSPDynamoStoreIndexDescriptorInvalidFormatMessage);
        results[indexName] = [self keyPairWithArray:keyNames];
    }

    return results;
}

-(NSString *)dynamoProjectionExpression
{
    return self.rangeKeyName ? [NSString stringWithFormat:@"%@,%@", self.hashKeyName, self.rangeKeyName] : self.hashKeyName;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ hashKeyName: %@, rangeKeyName: %@", [super description], self.hashKeyName, self.rangeKeyName];
}

@end
