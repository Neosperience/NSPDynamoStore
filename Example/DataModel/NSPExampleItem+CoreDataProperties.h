//
//  NSPExampleItem+CoreDataProperties.h
//  
//
//  Created by Janos Tolgyesi on 16/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NSPExampleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSPExampleItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *categoryId;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) id elements;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *personId;
@property (nullable, nonatomic, retain) NSString *photoURL;
@property (nullable, nonatomic, retain) NSString *tel;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSPExampleCategory *category;
@property (nullable, nonatomic, retain) NSPExamplePerson *person;

@end

NS_ASSUME_NONNULL_END
