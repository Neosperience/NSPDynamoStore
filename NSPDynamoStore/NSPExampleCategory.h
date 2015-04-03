//
//  NSPExampleCategory.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 03/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSPExampleItem;

@interface NSPExampleCategory : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@end

@interface NSPExampleCategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(NSPExampleItem *)value;
- (void)removeItemsObject:(NSPExampleItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
