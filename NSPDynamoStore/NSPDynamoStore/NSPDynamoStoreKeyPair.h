//
//  NSPDynamoStoreIndexDescriptor.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 17/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSPredicate;

@interface NSPDynamoStoreKeyPair : NSObject

-(instancetype)initWithString:(NSString*)string;
+(instancetype)keyPairWithString:(NSString*)string;

-(instancetype)initWithArray:(NSArray*)array;
+(instancetype)keyPairWithArray:(NSArray*)array;

+(NSDictionary*)indicesWithString:(NSString*)string;

@property (nonatomic, strong) NSString* hashKeyName;
@property (nonatomic, strong) NSString* rangeKeyName;

-(NSString*)dynamoProjectionExpression;

-(NSPredicate *)predicateForKeyObject:(id)object;

@end
