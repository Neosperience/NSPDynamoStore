//
//  NSRelationshipDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 15/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSRelationshipDescription+NSPDynamoStore.h"
#import "NSObject+NSPTypeCheck.h"

#import <NSDictionary+NSPCollectionUtils.h>
#import <NSPLogger.h>

NSString* const kNSPDynamoRelationshipFetchRequestKey = @"NSPDynamoRelationshipFetchRequest";
NSString* const kNSPDynamoRelationshipVariableMapKey = @"NSPDynamoRelationshipVariableMap";
NSString* const kNSPDynamoRelationshipUnmodeledInverseKey = @"NSPDynamoRelationshipUnmodeledInverse";

NSString* const kNSPDynamoStoreFetchRequestVariableKeyPathMapInvalidFormatMessage =
    @"NSPDynamoStore: fetch request variable key path must be in the following format: "
    "{ TEMPLATE_VAR1 : sourceObjectKeyPath1, TEMPLATE_VAR2 : sourceObjectKeyPath2 }";

@implementation NSRelationshipDescription (NSPDynamoStore)

-(NSString*)nsp_fetchRequestTemplateName
{
    NSString* fetchRequestTemplateName = self.userInfo[kNSPDynamoRelationshipFetchRequestKey];
    NSAssert(fetchRequestTemplateName, @"NSPDynamoStore: The user info of the relationship must contain a value for %@ key for relationship '%@.%@'",
             kNSPDynamoRelationshipFetchRequestKey, self.entity.name, self.name);
    return fetchRequestTemplateName;
}

-(NSDictionary*)nsp_fetchRequestVariableKeyPathMap
{
    NSString* mapString = self.userInfo[kNSPDynamoRelationshipVariableMapKey];

    NSData* mapData = [mapString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonReadError = nil;
    NSDictionary* map = [NSJSONSerialization JSONObjectWithData:mapData options:0 error:&jsonReadError];
    NSAssert(!jsonReadError, @"NSPDynamoStore: Error parsing fetch request variable key path map JSON in user info. Value: %@, error: %@",
             mapString, jsonReadError);
    [NSDictionary typeCheck:map];

    [map enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        [NSString typeCheck:key];
        [NSString typeCheck:value];
    }];

    return map;
}

-(BOOL)nsp_isUnmodeledInverseRelationship
{
    return [self.userInfo[kNSPDynamoRelationshipUnmodeledInverseKey] boolValue];
}

-(NSFetchRequest*)nsp_destinationFetchRequestForSourceObject:(id)sourceObject
{
    if ([self nsp_isUnmodeledInverseRelationship]) {
        return nil;
    }

    NSString* fetchRequestTemplateName = [self nsp_fetchRequestTemplateName];
    NSDictionary* fetchRequestVariableKeyPathMap = [self nsp_fetchRequestVariableKeyPathMap];

    __block BOOL incompleteRequest = NO;
    NSDictionary* substitutionDictionary = [fetchRequestVariableKeyPathMap map:^id(id key, id value) {
        id attributeKeyPathValue = [sourceObject valueForKeyPath:value];
        if (!attributeKeyPathValue) {
            // no relationship value for this object
            incompleteRequest = YES;
        }
        return attributeKeyPathValue;
    }];

    if (incompleteRequest) {
        NSPLogWarning(@"WARNING: incomplete fetch request for relationship %@.%@ -> %@, "
                      "fetchRequestTemplateName: %@, fetchRequestVariableKeyPathMap: %@, available attributes: %@",
                      relationship.entity.name, relationship.name, relationship.destinationEntity.name,
                      fetchRequestTemplateName, fetchRequestVariableKeyPathMap, nativeAttributes);
        return nil;
    }

    NSManagedObjectModel* model = self.entity.managedObjectModel;
    NSFetchRequest* fetchRequest = [model fetchRequestFromTemplateWithName:fetchRequestTemplateName
                                                     substitutionVariables:substitutionDictionary];
    return fetchRequest;
}

@end
