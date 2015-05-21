//
//  BFTask+NSPUtils.m
//  Canopus
//
//  Created by Janos Tolgyesi on 21/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "BFTask+NSPUtils.h"

#import <NSPCoreUtils/NSArray+NSPCollectionUtils.h>

@implementation BFTask (NSPUtils)

+(instancetype)taskForSerialCompletionOfAllTasks:(NSArray *)tasks
{
    if ([tasks count] == 0) return [BFTask taskWithResult:nil];
    BFTask* currentTask = nil;
    NSArray* remainingTasks = [tasks shiftedArray:&currentTask];
    return [currentTask continueWithSuccessBlock:^id(BFTask *task) {
        return [self taskForSerialCompletionOfAllTasks:remainingTasks];
    }];
}

@end
