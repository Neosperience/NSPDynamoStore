//
//  AWSDynamoDBAttributeValue+NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDBModel.h>

@interface AWSDynamoDBAttributeValue (NSPDynamoStore)

- (void)nsp_setAttributeValue:(id)attributeValue;
- (id)nsp_getAttributeValue;

@end
