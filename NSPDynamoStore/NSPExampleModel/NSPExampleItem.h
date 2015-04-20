//
//  NSPExampleItem.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 16/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSPExampleCategory, NSPExamplePerson;

@interface NSPExampleItem : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) id elements;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * categoryId;
@property (nonatomic, retain) NSString * personId;
@property (nonatomic, retain) NSPExampleCategory *category;
@property (nonatomic, retain) NSPExamplePerson *person;

@end
