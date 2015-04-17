//
//  NSRelationshipDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 15/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSRelationshipDescription+NSPDynamoStore.h"

NSString* const kNSPDynamoRelationshipFetchRequestKey = @"NSPDynamoRelationshipFetchRequest";
NSString* const kNSPDynamoRelationshipVariableMapKey = @"NSPDynamoRelationshipVariableMap";

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
    NSString* namesAsString = self.userInfo[kNSPDynamoRelationshipVariableMapKey];
    NSArray* mapElements = [namesAsString componentsSeparatedByString:@","];
    NSMutableDictionary* map = [NSMutableDictionary dictionaryWithCapacity:[mapElements count]];
    for (NSString* mapElement in mapElements) {
        NSArray* keyAndValue = [mapElement componentsSeparatedByString:@"="];
        NSAssert([keyAndValue count] == 2, @"NSPDynamoStore: Invalid value in userInfo of relationship '%@.%@' for key %@: %@ "
                 "(expected a map in fetchRequestVariable1=sourceObjectKeyPath1,fetchRequestVariable2=sourceObjectKeyPath2 format)",
                 self.entity.name, self.name, kNSPDynamoRelationshipVariableMapKey, namesAsString);
        map[keyAndValue[0]] = keyAndValue[1];
    }
    return map;
}

@end
