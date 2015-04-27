//
//  NSArray+NSPCollectionUtils.h
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 02/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @category NSPCollectionUtils
 @brief Map-reduce type collection utils.
 */
@interface NSArray (NSPCollectionUtils)

/**
 @brief Maps an array to new array invoking the block parameter. This method calls -[NSArray mapIncludingNullValues:iteratee:]
 with NO includeNullValues parameter.
 @param iteratee The block to be called for each item. The item is passed to the block. The block should return the mapped item.
 @return A new array constructed from the mapped items.
 */
-(NSArray*)map:(id (^)(id item))iteratee;

/**
 @brief Maps an array to new array invoking the block parameter specifying the behavior in case of nil mapped items.
 @param includeNullValues If set to YES and iteratee returns nil for a particular item, an [NSNull null] instance will be added
 to the resulting array for that item. If set to NO, the item will be simple ignored. This leads to a resulting array of a
 different size than the receiver.
 @param iteratee The block to be called for each item. The item is passed to the block. The block should return the mapped item.
 @return A new array constructed from the mapped items.
 */
-(NSArray*)mapIncludingNullValues:(BOOL)includeNullValues iteratee:(id (^)(id item))iteratee;

/**
 @brief Maps an array to a new array with a dictionary.
 @param map The mapping dictionary.
 @return A new array constructed from the map dictionary values that correspond to the keys in the receiver.
 */
-(NSArray*)mapWithDictionary:(NSDictionary*)map;

/**
 @brief Maps an array to a new array with a dictionary specifying the behavior in case of nil mapped items.
 @param includeNullValues If set to YES and the an item in the receiver can not be found as key in the map dictionary,
 an [NSNull null] instance will be added to the resulting array for that item. If set to NO, the item will be simple ignored.
 This leads to a resulting array of a
 different size than the receiver.
 @param map The mapping dictionary.
 @return A new array constructed from the map dictionary values that correspond to the keys in the receiver.
 */
-(NSArray*)mapIncludingNullValues:(BOOL)includeNullValues withDictionary:(NSDictionary*)map;

/**
 @brief Flattens an array-of-collections type structure. Each element in the array must implement NSFastEnumeration protocol.
 @return An array containing each item in each collection of the receiver.
 */
-(NSArray*)reduce;

/**
 @brief Explodes the receiver into smaller fragments of a given lenght.
 @param subArrayLength The length of the resulting array fragments.
 @return An array of smaller arrays. Each array contains subArrayLength number of items, except the last one that might 
 contain less residuing elements.
 */
-(NSArray*)explodeToSubarraysWithLength:(NSUInteger)subArrayLength;

@end
