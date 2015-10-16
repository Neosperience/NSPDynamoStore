//
//  NSPExampleCategory+CoreDataProperties.h
//  
//
//  Created by Janos Tolgyesi on 16/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NSPExampleCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSPExampleCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) id itemIds;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSSet<NSPExampleItem *> *items;

@end

@interface NSPExampleCategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(NSPExampleItem *)value;
- (void)removeItemsObject:(NSPExampleItem *)value;
- (void)addItems:(NSSet<NSPExampleItem *> *)values;
- (void)removeItems:(NSSet<NSPExampleItem *> *)values;

@end

NS_ASSUME_NONNULL_END
