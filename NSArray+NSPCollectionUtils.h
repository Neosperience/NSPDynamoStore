//
//  NSArray+NSPCollectionUtils.h
//  Somebody
//
//  Created by Janos Tolgyesi on 02/01/15.
//  Copyright (c) 2015 Neoseperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSPCollectionUtils)

-(NSArray*)map:(id (^)(id))iteratee;
-(NSArray*)mapWithDictionary:(NSDictionary*)map;

-(NSArray*)reduce;
-(NSArray*)explodeToSubarraysWithLength:(NSUInteger)subArrayLength;

@end
