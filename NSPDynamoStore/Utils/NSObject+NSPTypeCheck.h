//
//  NSObject+NSPTypeCheck.h
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @category NSPTypeCheck
 @brief Type cast and type check utils.
 */
@interface NSObject (NSPTypeCheck)

/**
 @brief Checks the type of an object.
 @param dataObject If the dataObject is not a kind of class of the receiver, raises an NSInternalInconsistencyException.
 */
+(void)typeCheck:(id)dataObject;

/**
 @brief Checks the type of an object and returns it casted to the reciever.
 @param dataObject If the dataObject is not a kind of class of the receiver, raises an NSInternalInconsistencyException.
 @return The passed object casted to the receiver class.
 */
+(instancetype)typeCheckedCast:(id)dataObject;

/**
 @brief Checks the type of an object and returns it casted to the reciever or returns nil.
 @param dataObject If the dataObject is not a kind of class of the receiver, this method returns nil.
 @return The passed object casted to the receiver class or nil if it can not be casted.
 */
+(instancetype)typeCastOrNil:(id)dataObject;

@end
