//
//  Item.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * tel;

@end
