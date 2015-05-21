//
//  BFTask+NSPUtils.h
//  Canopus
//
//  Created by Janos Tolgyesi on 21/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Bolts/BFTask.h>

@interface BFTask (NSPUtils)

+(instancetype)taskForSerialCompletionOfAllTasks:(NSArray *)tasks;

@end
