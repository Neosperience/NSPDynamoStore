//
//  NSPExamplePerson+CoreDataProperties.h
//  
//
//  Created by Janos Tolgyesi on 16/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NSPExamplePerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSPExamplePerson (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;

@end

NS_ASSUME_NONNULL_END
