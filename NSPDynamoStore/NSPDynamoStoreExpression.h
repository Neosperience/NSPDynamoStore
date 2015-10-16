//
//  NSPDynamoStoreAWSConditionElement.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 02/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWSDynamoDBCondition, NSPDynamoStoreKeyPair;

typedef enum : NSUInteger {
    NSPDynamoStoreExpressionOperatorUnknown,
    NSPDynamoStoreExpressionOperatorOR,
    NSPDynamoStoreExpressionOperatorAND,
} NSPDynamoStoreExpressionOperator;

@interface NSPDynamoStoreExpression : NSObject

+(NSPDynamoStoreExpression*)elementWithPredicate:(NSPredicate*)predicate;
-(NSPDynamoStoreExpression*)negatedElement;

-(NSDictionary*)dynamoConditions;
-(BOOL)operatorSupported:(NSPDynamoStoreExpressionOperator)elementOperator;

-(BOOL)canQueryForKeyPair:(NSPDynamoStoreKeyPair*)keyPair;
-(BOOL)canGetForKeyPair:(NSPDynamoStoreKeyPair*)keyPair;
-(BOOL)canBatchGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair explodedConditions:(NSArray* __autoreleasing *)explodedConditions;

@end

@interface NSPDynamoStoreComparisonExpression : NSPDynamoStoreExpression

-(instancetype)initWithDynamoCondition:(AWSDynamoDBCondition*)condition key:(NSString*)key;
+(instancetype)expressionWithDynamoCondition:(AWSDynamoDBCondition*)condition key:(NSString*)key;

-(instancetype)initWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate;
+(instancetype)expressionWithComparisonPredicate:(NSComparisonPredicate *)comparisionPredicate;

@property (nonatomic, strong) AWSDynamoDBCondition* condition;
@property (nonatomic, strong) NSString* key;

@end

@interface NSPDynamoStoreCompoundExpression : NSPDynamoStoreExpression

-(instancetype)initWithOperator:(NSPDynamoStoreExpressionOperator)compoundElementOperator subElements:(NSArray*)subElements;
+(instancetype)expressionWithOperator:(NSPDynamoStoreExpressionOperator)compoundElementOperator subElements:(NSArray*)subElements;

-(instancetype)initWithCompoundPredicate:(NSCompoundPredicate*)compoundPredicate;
+(instancetype)expressionWithCompoundPredicate:(NSCompoundPredicate*)compoundPredicate;

@property (nonatomic, strong) NSArray* subElements;
@property (nonatomic, assign) NSPDynamoStoreExpressionOperator elementOperator;

@end
