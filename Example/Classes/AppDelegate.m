//
//  AppDelegate.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "AppDelegate.h"

#import "NSPExampleItem.h"
#import "NSPExamplePerson.h"
#import "NSPExampleCategory.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <Bolts/Bolts.h>
#import <NSPDynamoStore/NSPDynamoStore.h>
#import <NSPDynamoStore/NSPDynamoSync.h>

NSString* const kCognitoPoolID = @"[AWS cognito pool ID here]";
const AWSRegionType kExampleRegionType = AWSRegionUSEast1;  // change AWS region if needed

NSString* const kDynamoDBKey = @"NSPDynamoStoreExample";

@interface AppDelegate ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSManagedObjectContext *dynamoManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *dynamoPersistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSManagedObjectContext *localManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *localPersistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;


@property (nonatomic, strong) NSPDynamoSync* syncManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSAssert(![kCognitoPoolID isEqualToString:@"[AWS cognito pool ID here]"], @"You must set kCognitoPoolID in AppDelegate.m");

    [self setupDynamoDB];

    self.syncManager = [[NSPDynamoSync alloc] initWithSourceContext:self.dynamoManagedObjectContext
                                                 destinationContext:self.localManagedObjectContext];
    
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
    AWSCognitoCredentialsProvider *credentialsProvider =
        [[AWSCognitoCredentialsProvider alloc] initWithRegionType:kExampleRegionType identityPoolId:kCognitoPoolID];

    AWSServiceConfiguration* serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
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

    [self.dynamoManagedObjectContext performBlock:^{
        NSError* error = nil;

        NSArray* results = [self.dynamoManagedObjectContext executeFetchRequest:fetchRequest error:&error];

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

#pragma mark - Shared object model

@synthesize managedObjectModel = _managedObjectModel;

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NSPDynamoStoreExample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - Dynamo Core Data stack

@synthesize dynamoManagedObjectContext = _dynamoManagedObjectContext;
@synthesize dynamoPersistentStoreCoordinator = _dynamoPersistentStoreCoordinator;

- (NSPersistentStoreCoordinator *)dynamoPersistentStoreCoordinator {
    if (_dynamoPersistentStoreCoordinator != nil) {
        return _dynamoPersistentStoreCoordinator;
    }
    
    _dynamoPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    NSString* storeType = NSPDynamoStoreType;
    NSURL* storeURL = nil;

    if (![_dynamoPersistentStoreCoordinator addPersistentStoreWithType:storeType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:@{ NSPDynamoStoreDynamoDBKey : kDynamoDBKey }
                                                                 error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the dynamo store persistent coordinator";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _dynamoPersistentStoreCoordinator;
}


- (NSManagedObjectContext *)dynamoManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_dynamoManagedObjectContext != nil) {
        return _dynamoManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self dynamoPersistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _dynamoManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_dynamoManagedObjectContext setPersistentStoreCoordinator:coordinator];
    return _dynamoManagedObjectContext;
}

#pragma mark - Local Core Data stack

@synthesize localManagedObjectContext = _localManagedObjectContext;
@synthesize localPersistentStoreCoordinator = _localPersistentStoreCoordinator;

-(NSPersistentStoreCoordinator *)localPersistentStoreCoordinator {
    if (_localPersistentStoreCoordinator) {
        return _localPersistentStoreCoordinator;
    }

    _localPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    NSString* storeType = NSSQLiteStoreType;
    NSURL* storeURL = [self localStoreURL];

    if (![_localPersistentStoreCoordinator addPersistentStoreWithType:storeType
                                                        configuration:nil
                                                                  URL:storeURL
                                                              options:nil
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

    return _localPersistentStoreCoordinator;
}

-(NSManagedObjectContext *)localManagedObjectContext
{
    if (_localManagedObjectContext != nil) {
        return _localManagedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self localPersistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _localManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_localManagedObjectContext setPersistentStoreCoordinator:coordinator];

    return _localManagedObjectContext;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSURL*)localStoreURL
{
    NSURL* localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cache.sqlite"];
    NSLog(@"local store URL: %@", localStoreURL);
    return localStoreURL;
}

@end
