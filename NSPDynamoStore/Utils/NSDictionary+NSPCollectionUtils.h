//
//  NSDictionary+NSPCollectionUtils.h
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 09/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @category NSPCollectionUtils
 @brief Map, filter and reverse dictionary collection utils.
 */
@interface NSDictionary (NSPCollectionUtils)

/**
 @brief Maps a dictionary to a new dictionary invoking the block parameter. This method calls 
 -[NSDictionary mapIncludingNullValues:iteratee:] with NO includeNullValues parameter.
 @param iteratee The block to be called for each key. The key and the corresponding value is passed to the block.
 The block should return the mapped item.
 @return A new dictionary containing a subset of the original keys and the mapped values.
 */
-(NSDictionary*)map:(id (^)(id key, id value))iteratee;

/**
 @brief Maps a dictionary to a new dictionary invoking the block parameter specifying the behavior in case of nil mapped items.
 @param includeNullValues If set to YES and iteratee returns nil for a particular item, an [NSNull null] instance will be added
 to the resulting dictionary for the key. If set to NO, the item will be simple ignored.
 @param iteratee The block to be called for each key. The key and the corresponding value is passed to the block. 
 The block should return the mapped item.
 @return A new dictionary containing a subset of the original keys and the mapped values.
 */
-(NSDictionary *)mapIncludingNullValues:(BOOL)includeNullValues iteratee:(id (^)(id key, id value))iteratee;

/**
 @brief Returns a reverse dictionary using the values in the receiver as keys and the corrisponding keys as values.
 @return The reverse dictionary.
 */
-(NSDictionary*)reverseDictionary;

/**
 @brief Filters the dictionary for a subset of keys.
 @param keys Only keys presenting in this set will be included in the resulting dictionary.
 @return A filtered dictionary containing a subset of the receiver's keys and values.
 */
-(NSDictionary*)filteredDictionaryForSubsetOfKeys:(NSSet*)keys;

/**
 @brief Filters the dictionary with a predicate.
 @param predicate Only keys passing the predicate will be included in the resulting dictionary.
 @return A filtered dictionary containing a subset of the receiver's keys and values.
 */
-(NSDictionary*)filteredDictionaryForKeysPassingPredicate:(NSPredicate*)predicate;

/**
 @brief Filters the dictionary with a block.
 @param predicate The block should return YES if it wants to include the current key to the resulting dictionary.
 If you set *stop to YES, the evaluation stops.
 @return A filtered dictionary containing a subset of the receiver's keys and values.
 */
-(NSDictionary*)filteredDictionaryForKeysPassingTest:(BOOL (^)(id key, BOOL *stop))predicate;

@end
