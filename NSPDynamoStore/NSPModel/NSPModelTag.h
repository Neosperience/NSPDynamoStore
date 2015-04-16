//
//  NSPModelTag.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 16/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NSPModelTag : NSManagedObject

@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) id descriptions;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * lastModified;
@property (nonatomic, retain) NSString * tagId;

@end
