//
//  NSEntityDescription+NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoHashKeyName;
-(NSString*)nsp_dynamoRangeKeyName;
-(NSString*)nsp_dynamoTableName;

-(NSDictionary*)nsp_dynamoDBAttributesToNativeAttributes:(NSDictionary*)dynamoAttributes;

@end
