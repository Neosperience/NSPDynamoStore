//
//  NSManagedObjectContext+NSPTask.m
//  Canopus
//
//  Created by Janos Tolgyesi on 04/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSManagedObjectContext+NSPTask.h"

#import <Bolts/Bolts.h>

@implementation NSManagedObjectContext (NSPTask)

-(BFTask*)executeFetchRequestInBackground:(NSFetchRequest*)fetchRequest
{
    NSParameterAssert(fetchRequest);
    
    BFTaskCompletionSource* taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self performBlock:^{
        NSError* error = nil;
        NSArray* result = [self executeFetchRequest:fetchRequest error:&error];
        error ? [taskCompletionSource setError:error] : [taskCompletionSource setResult:result];
    }];

    return taskCompletionSource.task;
}

-(BFTask*)performBlockInBackground:(id (^)(NSError* __autoreleasing *))block
{
    BFTaskCompletionSource* taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self performBlock:^{
        NSError* error = nil;
        id result = block(&error);
        error ? [taskCompletionSource setError:error] : [taskCompletionSource setResult:result];
    }];

    return taskCompletionSource.task;
}


@end
