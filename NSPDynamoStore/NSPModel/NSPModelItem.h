//
//  NSPModelItem.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 16/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSPModelContent, NSPModelTag;

@interface NSPModelItem : NSManagedObject

@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSNumber * lastModified;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * beaconId;
@property (nonatomic, retain) NSNumber * beaconMajor;
@property (nonatomic, retain) NSNumber * beaconMinor;
@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) id tagIds;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *content;
@end

@interface NSPModelItem (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSPModelTag *)value;
- (void)removeTagsObject:(NSPModelTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addContentObject:(NSPModelContent *)value;
- (void)removeContentObject:(NSPModelContent *)value;
- (void)addContent:(NSSet *)values;
- (void)removeContent:(NSSet *)values;

@end
