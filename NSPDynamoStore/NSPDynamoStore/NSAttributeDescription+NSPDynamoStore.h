//
//  NSAttributeDescription+NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 15/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSAttributeDescription (NSPDynamoStore)

-(BOOL)nsp_isStringType;
-(BOOL)nsp_isNumberType;

@end
