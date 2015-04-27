//
//  NSPDynamoStoreAWSConditionElement.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 02/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoStoreExpression.h"
#import "NSArray+NSPCollectionUtils.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"
#import "NSPDynamoStoreKeyPair.h"

#import <AWSDynamoDB/AWSDynamoDB.h>

AWSDynamoDBComparisonOperator NSPAWSOperatorInverse(AWSDynamoDBComparisonOperator operator)
{
    switch (operator) {
        case AWSDynamoDBComparisonOperatorEQ:           return AWSDynamoDBComparisonOperatorNE;
        case AWSDynamoDBComparisonOperatorNE:           return AWSDynamoDBComparisonOperatorEQ;
        case AWSDynamoDBComparisonOperatorLE:           return AWSDynamoDBComparisonOperatorGT;
        case AWSDynamoDBComparisonOperatorLT:           return AWSDynamoDBComparisonOperatorGE;
        case AWSDynamoDBComparisonOperatorGE:           return AWSDynamoDBComparisonOperatorLT;
        case AWSDynamoDBComparisonOperatorGT:           return AWSDynamoDBComparisonOperatorLE;
        case AWSDynamoDBComparisonOperatorNotNull:      return AWSDynamoDBComparisonOperatorNull;
        case AWSDynamoDBComparisonOperatorNull:         return AWSDynamoDBComparisonOperatorNotNull;
        case AWSDynamoDBComparisonOperatorContains:     return AWSDynamoDBComparisonOperatorNotContains;
        case AWSDynamoDBComparisonOperatorNotContains:  return AWSDynamoDBComparisonOperatorContains;

        case AWSDynamoDBComparisonOperatorBeginsWith:
        case AWSDynamoDBComparisonOperatorBetween:
        case AWSDynamoDBComparisonOperatorIN:
        default:
            NSCAssert(NO, @"NSPDynamoStore: NO operator is not supported for this operation");
            return AWSDynamoDBComparisonOperatorUnknown;
    }
}

AWSDynamoDBComparisonOperator NSPAWSOperatorFromNSOperator(NSPredicateOperatorType predicateOperatorType)
{
    switch (predicateOperatorType) {
        case NSLessThanPredicateOperatorType:               return AWSDynamoDBComparisonOperatorLT;
        case NSLessThanOrEqualToPredicateOperatorType:      return AWSDynamoDBComparisonOperatorLE;
        case NSGreaterThanPredicateOperatorType:            return AWSDynamoDBComparisonOperatorGT;
        case NSGreaterThanOrEqualToPredicateOperatorType:   return AWSDynamoDBComparisonOperatorGE;
        case NSEqualToPredicateOperatorType:                return AWSDynamoDBComparisonOperatorEQ;
        case NSNotEqualToPredicateOperatorType:             return AWSDynamoDBComparisonOperatorNE;

        case NSBeginsWithPredicateOperatorType:             return AWSDynamoDBComparisonOperatorBeginsWith;
        case NSInPredicateOperatorType:                     return AWSDynamoDBComparisonOperatorIN;
        case NSContainsPredicateOperatorType:               return AWSDynamoDBComparisonOperatorContains;
        case NSBetweenPredicateOperatorType:                return AWSDynamoDBComparisonOperatorBetween;

        case NSCustomSelectorPredicateOperatorType:
        case NSEndsWithPredicateOperatorType:
        case NSLikePredicateOperatorType:
        case NSMatchesPredicateOperatorType:
        default:
            NSCAssert(NO, @"NSPDynamoStore: predicate operator type %@ not supported", @(predicateOperatorType));
            return AWSDynamoDBComparisonOperatorUnknown;
    }
}

@implementation NSPDynamoStoreExpression

+(NSPDynamoStoreExpression*)elementWithPredicate:(NSPredicate *)predicate
{
    NSParameterAssert([predicate isKindOfClass:[NSComparisonPredicate class]] || [predicate isKindOfClass:[NSCompoundPredicate class]]);

    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate* comparisonPredicate = (NSComparisonPredicate*)predicate;
        return [NSPDynamoStoreComparisonExpression expressionWithComparisonPredicate:comparisonPredicate];
    } else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        NSCompoundPredicate* compoundPredicate = (NSCompoundPredicate*)predicate;

        if (compoundPredicate.compoundPredicateType == NSNotPredicateType) {
            NSAssert([compoundPredicate.subpredicates count] == 1, @"NSPDynamoStore: NOT expressions must have exactly one operand");
            NSPredicate* subPredicate = [compoundPredicate.subpredicates firstObject];
            return [[NSPDynamoStoreExpression elementWithPredicate:subPredicate] negatedElement];
        } else {
            return [NSPDynamoStoreCompoundExpression expressionWithCompoundPredicate:compoundPredicate];
        }
    }

    return nil;
}

-(NSPDynamoStoreExpression*)negatedElement
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return nil;
}

-(NSDictionary*)dynamoConditions
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return nil;
}

-(BOOL)operatorSupported:(NSPDynamoStoreExpressionOperator)elementOperator
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return NO;
}

-(BOOL)canQueryForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return NO;
}

-(BOOL)canGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return NO;
}

-(BOOL)canBatchGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair explodedConditions:(NSArray *__autoreleasing *)explodedConditions
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return NO;
}

@end

@implementation NSPDynamoStoreComparisonExpression

- (instancetype)initWithDynamoCondition:(AWSDynamoDBCondition *)condition key:(NSString *)key
{
    self = [self init];
    if (self) {
        self.condition = condition;
        self.key = key;
    }
    return self;
}

+(instancetype)expressionWithDynamoCondition:(AWSDynamoDBCondition *)condition key:(NSString *)key
{
    return [[self alloc] initWithDynamoCondition:condition key:key];
}

-(instancetype)initWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate
{
    self = [self init];
    if (self) {
        [self setupWithComparisonPredicate:comparisionPredicate];
    }
    return self;
}

+(instancetype)expressionWithComparisonPredicate:(NSComparisonPredicate *)comparisionPredicate
{
    return [[self alloc] initWithComparisonPredicate:comparisionPredicate];
}

-(void)setupWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate
{
    if (!(comparisionPredicate.leftExpression.expressionType == NSKeyPathExpressionType &&
          comparisionPredicate.rightExpression.expressionType == NSConstantValueExpressionType)) {
        NSAssert(NO, @"NSPDynamoStore: only key - constant type predicates are supported for predicate: %@", comparisionPredicate);
        return;
    }

    if ((comparisionPredicate.options & NSCaseInsensitivePredicateOption) ||
        (comparisionPredicate.options & NSDiacriticInsensitivePredicateOption)) {
        NSAssert(NO, @"NSPDynamoStore: case insesitive search is not supported for predicate: %@", comparisionPredicate);
        return;
    }

    AWSDynamoDBComparisonOperator dynamoOperator = AWSDynamoDBComparisonOperatorUnknown;

    id rightAttribute = comparisionPredicate.rightExpression.constantValue;
    NSMutableArray* dynamoRightAttributes = nil;

    if (!rightAttribute) {

        if (comparisionPredicate.predicateOperatorType == NSEqualToPredicateOperatorType) {
            dynamoOperator = AWSDynamoDBComparisonOperatorNull;
        } else if (comparisionPredicate.predicateOperatorType == NSNotEqualToPredicateOperatorType) {
            dynamoOperator = AWSDynamoDBComparisonOperatorNotNull;
        } else {
            NSAssert(NO, @"NULL attribute value is supported only with == and != operator type");
        }

    } else {

        dynamoOperator = NSPAWSOperatorFromNSOperator(comparisionPredicate.predicateOperatorType);
        dynamoRightAttributes = [NSMutableArray array];

        if ([rightAttribute respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
            for (id element in rightAttribute) {
                AWSDynamoDBAttributeValue* dynamoElement = [AWSDynamoDBAttributeValue new];
                [dynamoElement nsp_setAttributeValue:element];
                [dynamoRightAttributes addObject:dynamoElement];
            }
        } else {
            AWSDynamoDBAttributeValue* dynamoRightAttribute = [AWSDynamoDBAttributeValue new];
            [dynamoRightAttribute nsp_setAttributeValue:rightAttribute];
            [dynamoRightAttributes addObject:dynamoRightAttribute];
        }
    }

    NSString* key = comparisionPredicate.leftExpression.keyPath;

    NSAssert(![key containsString:@"."], @"NSPDynamoStore: keyPath type expressions are not supported");
    // TODO: convert to dynamo attribute name and evaluate supporting keyPaths

    AWSDynamoDBCondition* condition = [AWSDynamoDBCondition new];
    condition.comparisonOperator = dynamoOperator;
    condition.attributeValueList = dynamoRightAttributes;

    self.condition = condition;
    self.key = key;
}

-(instancetype)negatedElement
{
    AWSDynamoDBCondition* negatedCondition = [AWSDynamoDBCondition new];
    negatedCondition.attributeValueList = self.condition.attributeValueList;
    negatedCondition.comparisonOperator = NSPAWSOperatorInverse(self.condition.comparisonOperator);
    return [[self class] expressionWithDynamoCondition:negatedCondition key:self.key];
}

-(NSDictionary *)dynamoConditions
{
    if (self.key) {
        return @{ self.key : self.condition };
    } else {
        return nil;
    }
}

-(BOOL)operatorSupported:(NSPDynamoStoreExpressionOperator)elementOperator
{
    return (elementOperator == NSPDynamoStoreExpressionOperatorAND) || (elementOperator == NSPDynamoStoreExpressionOperatorOR);
}

-(BOOL)isHashKeyEQExpressionForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    BOOL operatorSupported = self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorEQ;
    return [self.key isEqualToString:keyPair.hashKeyName] && operatorSupported;
}

-(BOOL)isRangeKeyEQExpressionForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    BOOL operatorSupported = self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorEQ;
    return [self.key isEqualToString:keyPair.rangeKeyName] && operatorSupported;
}

-(BOOL)isHashKeyINExpressionForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    BOOL operatorSupported =
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorEQ ||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorIN;

    return [self.key isEqualToString:keyPair.hashKeyName] && operatorSupported;
}

-(BOOL)isRangeKeyINExpressionForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    BOOL operatorSupported =
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorEQ ||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorIN;

    return [self.key isEqualToString:keyPair.rangeKeyName] && operatorSupported;
}

-(BOOL)isRangeKeyFilterForKeyPair:(NSPDynamoStoreKeyPair*)keyPair
{
    BOOL operatorSupported =
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorEQ ||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorLE ||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorLT ||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorGE||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorGT||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorBeginsWith||
        self.condition.comparisonOperator == AWSDynamoDBComparisonOperatorBetween;

    return [self.key isEqualToString:keyPair.rangeKeyName] && operatorSupported;
}

-(BOOL)canQueryForKeyPair:(NSPDynamoStoreKeyPair *)keyPair
{
    return [self isHashKeyEQExpressionForKeyPair:keyPair];
}

-(BOOL)canGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair
{
    return [self isHashKeyEQExpressionForKeyPair:keyPair] && !keyPair.rangeKeyName;
}

-(BOOL)canBatchGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair explodedConditions:(NSArray *__autoreleasing *)explodedConditions
{
    BOOL canBatchGet = [self isHashKeyINExpressionForKeyPair:keyPair] && !keyPair.rangeKeyName;

    if (explodedConditions && canBatchGet) {

        NSArray* collectionAttributeValues = self.condition.attributeValueList;
        NSString* collectionAttributeName = self.key;

        *explodedConditions = [collectionAttributeValues map:^id(id item) {
            return @{ collectionAttributeName : item };
        }];
    }

    return canBatchGet;
}

@end

@implementation NSPDynamoStoreCompoundExpression

- (instancetype)initWithOperator:(NSPDynamoStoreExpressionOperator)compoundElementOperator subElements:(NSArray *)subElements
{
    self = [self init];
    if (self) {
        self.elementOperator = compoundElementOperator;
        self.subElements = subElements;
    }
    return self;
}

+(instancetype)expressionWithOperator:(NSPDynamoStoreExpressionOperator)compoundElementOperator subElements:(NSArray *)subElements
{
    return [[self alloc] initWithOperator:compoundElementOperator subElements:subElements];
}

-(instancetype)negatedElement
{
    NSArray* negatedSubElements = [self.subElements map:^id(NSPDynamoStoreExpression* filterElement) {
        return [filterElement negatedElement];
    }];

    NSPDynamoStoreExpressionOperator negatedOperator = NSPDynamoStoreExpressionOperatorUnknown;
    switch (self.elementOperator) {
        case NSPDynamoStoreExpressionOperatorOR:       negatedOperator = NSPDynamoStoreExpressionOperatorAND; break;
        case NSPDynamoStoreExpressionOperatorAND:      negatedOperator = NSPDynamoStoreExpressionOperatorOR; break;
        case NSPDynamoStoreExpressionOperatorUnknown:
        default:
            NSAssert(NO, @"NSPDynamoStore: invalid compound operator in NSPDynamoStoreCompoundElement: %@", @(self.elementOperator));
            break;
    }

    return [[self class] expressionWithOperator:negatedOperator subElements:negatedSubElements];
}

-(void)setupWithCompoundPredicate:(NSCompoundPredicate *)compoundPredicate
{
    NSParameterAssert(compoundPredicate.compoundPredicateType == NSOrPredicateType ||
                      compoundPredicate.compoundPredicateType == NSAndPredicateType);

    self.subElements = [compoundPredicate.subpredicates map:^id(NSPredicate* subPredicate) {
        return [NSPDynamoStoreExpression elementWithPredicate:subPredicate];
    }];

    if (compoundPredicate.compoundPredicateType == NSOrPredicateType) {
        self.elementOperator = NSPDynamoStoreExpressionOperatorOR;
    } else if (compoundPredicate.compoundPredicateType == NSAndPredicateType) {
        self.elementOperator = NSPDynamoStoreExpressionOperatorAND;
    }
}

- (instancetype)initWithCompoundPredicate:(NSCompoundPredicate *)compoundPredicate
{
    self = [self init];
    if (self) {
        [self setupWithCompoundPredicate:compoundPredicate];
    }
    return self;
}

+(instancetype)expressionWithCompoundPredicate:(NSCompoundPredicate *)compoundPredicate
{
    return [[self alloc] initWithCompoundPredicate:compoundPredicate];
}

-(BOOL)operatorSupported:(NSPDynamoStoreExpressionOperator)elementOperator
{
    BOOL operatorSupported = NO;
    if (self.elementOperator == elementOperator) {
        operatorSupported = YES;
        for (NSPDynamoStoreExpression* element in self.subElements) {
            operatorSupported &= [element operatorSupported:elementOperator];
        }
    }
    return operatorSupported;
}

-(NSDictionary *)dynamoConditions
{
    NSMutableDictionary* conditions = [NSMutableDictionary dictionary];

    for (NSPDynamoStoreExpression* element in self.subElements) {

        NSDictionary* elementConditions = [element dynamoConditions];

        NSMutableSet* conditionsKeys = [NSMutableSet setWithArray:[conditions allKeys]];
        NSSet* elementConditionsKeys = [NSSet setWithArray:[elementConditions allKeys]];
        [conditionsKeys intersectSet:elementConditionsKeys];
        NSAssert([conditionsKeys count] == 0, @"NSPDynamoStore: multiple conditions are not supported. Affected key(s): %@", conditionsKeys);

        [conditions addEntriesFromDictionary:elementConditions];
    }
    return conditions;
}

-(BOOL)canQueryForKeyPair:(NSPDynamoStoreKeyPair *)keyPair
{
    if ([self.subElements count] == 2) {
        NSPDynamoStoreComparisonExpression* firstElement = self.subElements[0];
        NSPDynamoStoreComparisonExpression* secondElement = self.subElements[1];

        if ([firstElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]] &&
            [secondElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]]) {
            return (
                ([firstElement isHashKeyEQExpressionForKeyPair:keyPair] && [secondElement isRangeKeyFilterForKeyPair:keyPair]) ||
                ([firstElement isRangeKeyFilterForKeyPair:keyPair] && [secondElement isHashKeyEQExpressionForKeyPair:keyPair])
            ) && (
                self.elementOperator == NSPDynamoStoreExpressionOperatorAND
            );
        }
    }
    return NO;
}

-(BOOL)canGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair
{
    if ([self.subElements count] == 2) {
        NSPDynamoStoreComparisonExpression* firstElement = self.subElements[0];
        NSPDynamoStoreComparisonExpression* secondElement = self.subElements[1];

        if ([firstElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]] &&
            [secondElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]]) {
            return (
                ([firstElement isHashKeyEQExpressionForKeyPair:keyPair] && [secondElement isRangeKeyEQExpressionForKeyPair:keyPair]) ||
                ([firstElement isRangeKeyEQExpressionForKeyPair:keyPair] && [secondElement isHashKeyEQExpressionForKeyPair:keyPair])
            ) && (
                self.elementOperator == NSPDynamoStoreExpressionOperatorAND
            );
        }
    }
    return NO;
}

-(BOOL)canBatchGetForKeyPair:(NSPDynamoStoreKeyPair *)keyPair explodedConditions:(NSArray* __autoreleasing *)explodedConditions
{
    BOOL canBatchGet = NO;

    if ([self.subElements count] == 2) {
        NSPDynamoStoreComparisonExpression* firstElement = self.subElements[0];
        NSPDynamoStoreComparisonExpression* secondElement = self.subElements[1];

        if ([firstElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]] &&
            [secondElement isKindOfClass:[NSPDynamoStoreComparisonExpression class]]) {

            if (self.elementOperator == NSPDynamoStoreExpressionOperatorAND) {

                AWSDynamoDBAttributeValue* singleAttributeValue = nil;
                NSArray* collectionAttributeValues = nil;
                NSString* singleAttributeName = nil;
                NSString* collectionAttributeName = nil;

                if ([firstElement isHashKeyEQExpressionForKeyPair:keyPair] && [secondElement isRangeKeyINExpressionForKeyPair:keyPair]) {
                    singleAttributeValue = [firstElement.condition.attributeValueList lastObject];
                    collectionAttributeValues = secondElement.condition.attributeValueList;
                    singleAttributeName = firstElement.key;
                    collectionAttributeName = secondElement.key;
                    canBatchGet = YES;
                } else if ([firstElement isRangeKeyEQExpressionForKeyPair:keyPair] && [secondElement isHashKeyINExpressionForKeyPair:keyPair]) {
                    singleAttributeValue = [secondElement.condition.attributeValueList lastObject];
                    collectionAttributeValues = firstElement.condition.attributeValueList;
                    singleAttributeName = secondElement.key;
                    collectionAttributeName = firstElement.key;
                    canBatchGet = YES;
                }

                if (explodedConditions && canBatchGet) {

                    NSMutableArray* results = [NSMutableArray arrayWithCapacity:[collectionAttributeValues count]];
                    for (AWSDynamoDBAttributeValue* enumeratedValue in collectionAttributeValues) {
                        NSDictionary* condition = @{ singleAttributeName : singleAttributeValue,
                                                     collectionAttributeName : enumeratedValue };
                        [results addObject:condition];
                    }

                    *explodedConditions = results;
                }

            }

        }
    }
    return canBatchGet;
}

@end
