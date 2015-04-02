//
//  NSPDynamoStoreAWSConditionElement.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 02/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoStoreConditionElement.h"
#import "NSArray+NSPCollectionUtils.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"

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

@implementation NSPDynamoStoreFilterElement

+(NSPDynamoStoreFilterElement*)elementWithPredicate:(NSPredicate *)predicate
{
    NSParameterAssert([predicate isKindOfClass:[NSComparisonPredicate class]] || [predicate isKindOfClass:[NSCompoundPredicate class]]);

    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate* comparisonPredicate = (NSComparisonPredicate*)predicate;
        return [NSPDynamoStoreConditionElement elementWithComparisonPredicate:comparisonPredicate];
    } else if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        NSCompoundPredicate* compoundPredicate = (NSCompoundPredicate*)predicate;

        if (compoundPredicate.compoundPredicateType == NSNotPredicateType) {
            NSAssert([compoundPredicate.subpredicates count] == 1, @"NSPDynamoStore: NOT expressions must have exactly one operand");
            NSPredicate* subPredicate = [compoundPredicate.subpredicates firstObject];
            return [[NSPDynamoStoreFilterElement elementWithPredicate:subPredicate] negatedElement];
        } else {
            return [NSPDynamoStoreCompoundElement elementWithCompoundPredicate:compoundPredicate];
        }
    }

    return nil;
}

-(NSPDynamoStoreFilterElement*)negatedElement
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return nil;
}

-(NSDictionary*)awsConditions
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return nil;
}

-(BOOL)operatorSupported:(NSPDynamoStoreElementOperator)elementOperator
{
    NSAssert(NO, @"NSPDynamoStore: abstract function called");
    return NO;
}

@end

@implementation NSPDynamoStoreConditionElement

- (instancetype)initWithCondition:(AWSDynamoDBCondition *)condition key:(NSString *)key
{
    self = [self init];
    if (self) {
        self.condition = condition;
        self.key = key;
    }
    return self;
}

+(instancetype)conditionElementWithCondition:(AWSDynamoDBCondition *)condition key:(NSString *)key
{
    return [[self alloc] initWithCondition:condition key:key];
}

-(instancetype)initWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate
{
    self = [self init];
    if (self) {
        [self setupWithComparisonPredicate:comparisionPredicate];
    }
    return self;
}

+(instancetype)elementWithComparisonPredicate:(NSComparisonPredicate *)comparisionPredicate
{
    return [[self alloc] initWithComparisonPredicate:comparisionPredicate];
}

-(void)setupWithComparisonPredicate:(NSComparisonPredicate*)comparisionPredicate
{
    if (!(comparisionPredicate.leftExpression.expressionType == NSKeyPathExpressionType &&
          comparisionPredicate.rightExpression.expressionType == NSConstantValueExpressionType)) {
        NSAssert(NO, @"NSPDynamoStore: only key - constant type predicates are supported");
        return;
    }

    if ((comparisionPredicate.options & NSCaseInsensitivePredicateOption) ||
        (comparisionPredicate.options & NSDiacriticInsensitivePredicateOption)) {
        NSAssert(NO, @"NSPDynamoStore: case insesitive search is not supported");
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
    return [[self class] conditionElementWithCondition:negatedCondition key:self.key];
}

-(NSDictionary *)awsConditions
{
    if (self.key) {
        return @{ self.key : self.condition };
    } else {
        return nil;
    }
}

-(BOOL)operatorSupported:(NSPDynamoStoreElementOperator)elementOperator
{
    return (elementOperator == NSPDynamoStoreElementOperatorAND) || (elementOperator == NSPDynamoStoreElementOperatorOR);
}

@end

@implementation NSPDynamoStoreCompoundElement

- (instancetype)initWithOperator:(NSPDynamoStoreElementOperator)compoundElementOperator subElements:(NSArray *)subElements
{
    self = [self init];
    if (self) {
        self.elementOperator = compoundElementOperator;
        self.subElements = subElements;
    }
    return self;
}

+(instancetype)compoundElementWithOperator:(NSPDynamoStoreElementOperator)compoundElementOperator subElements:(NSArray *)subElements
{
    return [[self alloc] initWithOperator:compoundElementOperator subElements:subElements];
}

-(instancetype)negatedElement
{
    NSArray* negatedSubElements = [self.subElements map:^id(NSPDynamoStoreFilterElement* filterElement) {
        return [filterElement negatedElement];
    }];

    NSPDynamoStoreElementOperator negatedOperator = NSPDynamoStoreElementOperatorUnknown;
    switch (self.elementOperator) {
        case NSPDynamoStoreElementOperatorOR:       negatedOperator = NSPDynamoStoreElementOperatorAND; break;
        case NSPDynamoStoreElementOperatorAND:      negatedOperator = NSPDynamoStoreElementOperatorOR; break;
        case NSPDynamoStoreElementOperatorUnknown:
        default:
            NSAssert(NO, @"NSPDynamoStore: invalid compound operator in NSPDynamoStoreCompoundElement: %@", @(self.elementOperator));
            break;
    }

    return [[self class] compoundElementWithOperator:negatedOperator subElements:negatedSubElements];
}

-(void)setupWithCompoundPredicate:(NSCompoundPredicate *)compoundPredicate
{
    NSParameterAssert(compoundPredicate.compoundPredicateType == NSOrPredicateType ||
                      compoundPredicate.compoundPredicateType == NSAndPredicateType);

    self.subElements = [compoundPredicate.subpredicates map:^id(NSPredicate* subPredicate) {
        return [NSPDynamoStoreFilterElement elementWithPredicate:subPredicate];
    }];

    if (compoundPredicate.compoundPredicateType == NSOrPredicateType) {
        self.elementOperator = NSPDynamoStoreElementOperatorOR;
    } else if (compoundPredicate.compoundPredicateType == NSAndPredicateType) {
        self.elementOperator = NSPDynamoStoreElementOperatorAND;
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

+(instancetype)elementWithCompoundPredicate:(NSCompoundPredicate *)compoundPredicate
{
    return [[self alloc] initWithCompoundPredicate:compoundPredicate];
}

-(BOOL)operatorSupported:(NSPDynamoStoreElementOperator)elementOperator
{
    BOOL operatorSupported = NO;
    if (self.elementOperator == elementOperator) {
        operatorSupported = YES;
        for (NSPDynamoStoreFilterElement* element in self.subElements) {
            operatorSupported &= [element operatorSupported:elementOperator];
        }
    }
    return operatorSupported;
}

-(NSDictionary *)awsConditions
{
    NSMutableDictionary* conditions = [NSMutableDictionary dictionary];

    for (NSPDynamoStoreFilterElement* element in self.subElements) {

        NSDictionary* elementConditions = [element awsConditions];

        NSMutableSet* conditionsKeys = [NSMutableSet setWithArray:[conditions allKeys]];
        NSSet* elementConditionsKeys = [NSSet setWithArray:[elementConditions allKeys]];
        [conditionsKeys intersectSet:elementConditionsKeys];
        NSAssert([conditionsKeys count] == 0, @"NSPDynamoStore: multiple conditions are not supported. Affected key(s): %@", conditionsKeys);

        [conditions addEntriesFromDictionary:elementConditions];
    }
    return conditions;
}

@end
