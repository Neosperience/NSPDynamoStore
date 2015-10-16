//
//  AppDelegate.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "AppDelegate.h"
#import "NSPDynamoStore.h"
#import "NSPExampleItem.h"
#import "NSPExamplePerson.h"
#import "NSPExampleCategory.h"
#import "NSManagedObjectModel+NSPUtils.h"
#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPDynamoSync.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <Bolts/Bolts.h>

NSString* const kAWSAccountID = @"[AWS account ID here]";
NSString* const kCognitoPoolID = @"[AWS cognito pool ID here]";
NSString* const kCognitoRoleUnauth = @"[AWS unauthenticated role ARN here]";

NSString* const kDynamoDBKey = @"NSPDynamoStoreExample";

@interface AppDelegate ()

@property (nonatomic, strong) NSPDynamoSync* syncManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self setupDynamoDB];

    self.syncManager = [[NSPDynamoSync alloc] initWithManagedObjectModel:self.managedObjectModel
                                                             dynamoDBKey:kDynamoDBKey
                                                     destinationStoreURL:[self cacheURL]
                                                    destinationStoreType:NSSQLiteStoreType
                                                 destinationStoreOptions:nil];
    
    [[self.syncManager synchronizeWithFetchRequestParams:@{}
                                           progressBlock:^(float progress) {
        NSLog(@"SYNC progress: %@", @(progress));
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Synchronization error: %@", task.error);
        } else {
            NSLog(@"Synchronization success");
        }
        return nil;
    }];

    [self exampleTest];

    return YES;
}

-(void)setupDynamoDB
{
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                                                        accountId:kAWSAccountID
                                                                                                   identityPoolId:kCognitoPoolID
                                                                                                    unauthRoleArn:kCognitoRoleUnauth
                                                                                                      authRoleArn:nil];

    AWSServiceConfiguration* serviceConfiguration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                                 credentialsProvider:credentialsProvider];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

    [AWSDynamoDB registerDynamoDBWithConfiguration:serviceConfiguration forKey:kDynamoDBKey];
}

- (void)exampleTest
{
    [self setupDynamoDB];

    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    fetchRequest.returnsObjectsAsFaults = NO;

    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"section", @"church"];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K in %@", @"section", @[@"culture", @"church"]];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"longitude < 9.18"];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"Basilica"];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", @"di"];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"latitude BETWEEN %@", @[@45.45, @45.46]];
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"address BEGINSWITH 'Corso' AND NOT url == NULL"];

    //    Compund predicates are not supported yet
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"section == 'culture' AND name BEGINSWITH 'Antico'"];

    //    fetchRequest.predicate = predicate;
    fetchRequest.resultType = NSManagedObjectResultType;

    [self.managedObjectContext performBlock:^{
        NSError* error = nil;

        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

        if (error) {
            NSLog(@"ERROR: %@", error);
        } else {
            NSPExampleCategory* category = [results firstObject];
            NSLog(@"category name: %@", category.name);
            NSLog(@"category items count: %@", @([category.items count]));
            for (NSPExampleItem* item in category.items) {
                NSLog(@"\t%@", item.name);
                NSLog(@"\t\telements: %@", item.elements);
            }
        }

    }];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NSPDynamoStoreExample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    NSString* storeType = NSPDynamoStoreType;
    NSURL* storeURL = nil;

    if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:@{ NSPDynamoStoreDynamoDBKey : kDynamoDBKey }
                                                           error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

-(NSURL*)cacheURL
{
    NSURL* cacheURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cache.sqlite"];
    NSLog(@"cache URL: %@", cacheURL);
    return cacheURL;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
