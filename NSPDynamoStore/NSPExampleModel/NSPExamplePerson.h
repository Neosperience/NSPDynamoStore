//
//  NSPExamplePerson.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 16/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NSPExamplePerson : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;

@end
