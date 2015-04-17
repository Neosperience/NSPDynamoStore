//
//  NSPModelContent.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 17/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NSPModelContent : NSManagedObject

@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) NSString * templateId;
@property (nonatomic, retain) id template;
@property (nonatomic, retain) id elements;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) NSString * textForSearch;

@end
