//
//  NSObject+NSPTypeCheck.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSPTypeCheck)

+(void)typeCheck:(id)dataObject;
+(instancetype)typeCheckedCast:(id)dataObject;
+(instancetype)typeCastOrNil:(id)dataObject;

@end
