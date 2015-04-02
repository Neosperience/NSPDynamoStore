//
//  NSPDynamoStoreAWSConditionElement.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 02/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWSDynamoDBCondition;

typedef enum : NSUInteger {
    NSPDynamoStoreElementOperatorUnknown,
    NSPDynamoStoreElementOperatorOR,
    NSPDynamoStoreElementOperatorAND,
} NSPDynamoStoreElementOperator;

@interface NSPDynamoStoreFilterElement : NSObject

+(NSPDynamoStoreFilterElement*)elementWithPredicate:(NSPredicate*)predicate;
-(NSPDynamoStoreFilterElement*)negatedElement;

-(NSDictionary*)awsConditions;
-(BOOL)operatorSupported:(NSPDynamoStoreElementOperator)elementOperator;

@end

@interface NSPDynamoStoreConditionElement : NSPDynamoStoreFilterElement

-(instancetype)initWithCondition:(AWSDynamoDBCondition*)condition key:(NSString*)key;
+(instancetype)conditionElementWithCondition:(AWSDynamoDBCondition*)condition key:(NSString*)key;

-(instancetype)initWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate;
+(instancetype)elementWithComparisonPredicate:(NSComparisonPredicate *)comparisionPredicate;

@property (nonatomic, strong) AWSDynamoDBCondition* condition;
@property (nonatomic, strong) NSString* key;

@end

@interface NSPDynamoStoreCompoundElement : NSPDynamoStoreFilterElement

-(instancetype)initWithOperator:(NSPDynamoStoreElementOperator)compoundElementOperator subElements:(NSArray*)subElements;
+(instancetype)compoundElementWithOperator:(NSPDynamoStoreElementOperator)compoundElementOperator subElements:(NSArray*)subElements;

-(instancetype)initWithCompoundPredicate:(NSCompoundPredicate*)compoundPredicate;
+(instancetype)elementWithCompoundPredicate:(NSCompoundPredicate*)compoundPredicate;

@property (nonatomic, strong) NSArray* subElements;
@property (nonatomic, assign) NSPDynamoStoreElementOperator elementOperator;

@end
