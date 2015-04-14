//
//  NSPExampleItem.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 14/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPExampleItem.h"
#import "NSPExampleCategory.h"
#import "NSPExamplePerson.h"

@implementation NSPExampleItem

@dynamic address;
@dynamic desc;
@dynamic email;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic objectId;
@dynamic photoURL;
@dynamic tel;
@dynamic url;
@dynamic elements;
@dynamic category;
@dynamic person;

-(id)elementsAsObject
{
    NSValueTransformer* dataTransformer = [NSValueTransformer valueTransformerForName:NSKeyedUnarchiveFromDataTransformerName];
    id decodedValue = nil;
    if (self.elements) {
        decodedValue = [dataTransformer transformedValue:self.elements];
    }
    return decodedValue;
}

@end
