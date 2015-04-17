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
#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSEntityDescription+NSPDynamoStore.h"

#import "NSPModel.h"

#import <AWSDynamoDB/AWSDynamoDB.h>

NSString* const kAWSAccountID = @"[AWS account ID here]";
NSString* const kCognitoPoolID = @"[AWS cognito pool ID here]";
NSString* const kCognitoRoleUnauth = @"[AWS unauthenticated role ARN here]";

NSString* const kDynamoDBKey = @"NSPDynamoStoreExample";

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self setupDynamoDB];

    [self canopusTest];

//    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//    dispatch_async(lowQueue, ^{
//        [self migrate];
//    });

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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

- (void)canopusTest
{
    NSEntityDescription* itemEntity = [self.managedObjectModel entityForManagedObjectClass:[NSPModelItem class]];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:itemEntity.name];

    [self.managedObjectContext performBlock:^{
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error);
        } else {
            for (NSPModelItem* item in results) {
                NSLog(@"%@", item.code);
                NSLog(@"\tname: %@", item.name);
                NSLog(@"\tcity, state, country, zip: %@, %@, %@, %@", item.city, item.state,  item.country, item.zip);
                NSLog(@"\tstreet: %@", item.street);
                NSLog(@"\tcoordinates: %@, %@", item.latitude, item.longitude);
                NSLog(@"\tlastModified: %@", item.lastModified);

                NSLog(@"\ttags:");
                for (NSPModelTag* tag in item.tags) {
                    NSLog(@"\t\t%@", tag.code);
                    NSLog(@"\t\t\tlastModified: %@", tag.lastModified);
//                    NSLog(@"\t\t\tdescriptions: %@", tag.descriptions);
//                    NSLog(@"\t\t\tposition: %@", tag.position);
                }

                NSLog(@"\tcontents:");
                for (NSPModelContent* content in item.content) {
                    NSLog(@"\t\t%@", content.locale);
                    NSLog(@"\t\t\telements: %@", content.elements);
                    NSLog(@"\t\t\ttemplate: %@", content.template);
                    NSLog(@"\t\t\ttextForSearch: %@", content.textForSearch);
                    NSLog(@"\t\t\tlastModified: %@", content.lastModified);
                }

            }
        }
    }];
}

- (void)exampleTest
{
    [self setupDynamoDB];

    NSString* itemEntityName = [self.managedObjectModel entityForManagedObjectClass:[NSPExampleCategory class]].name;
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:itemEntityName];
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


    //    NSString* categoryEntityName = [self.managedObjectModel entityForManagedObjectClass:[NSPExampleCategory class]].name;
    //    NSFetchRequest* categoryFetchRequest = [[NSFetchRequest alloc] initWithEntityName:categoryEntityName];
    //
    //    __weak typeof(self) weakSelf = self;
    //
    //    [self.managedObjectContext performBlock:^{
    //
    //        NSError *error = nil;
    //        NSArray* categoryResults = [weakSelf.managedObjectContext executeFetchRequest:categoryFetchRequest error:&error];
    //
    //        if (error) {
    //            NSLog(@"ERROR: %@", error);
    //        } else {
    //            for (NSPExampleCategory* category in categoryResults) {
    //                NSLog(@"category.name: %@", category.name);
    //                NSLog(@"items: ");
    //                for (NSPExampleItem* item in category.items) {
    //                    NSLog(@"  item.name: %@", item.name);
    //                }
    //            }
    //        }
    //
    //    }];
    
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(lowQueue, ^{
        [self migrate];
    });
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.neosperience.NSPDynamoStore" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NSPDynamoStore" withExtension:@"momd"];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NSPCanopus" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    NSString* storeType = NSPDynamoStoreType;
    NSURL* storeURL = nil;

//    NSString* storeType = NSSQLiteStoreType;
//    NSURL* storeURL = [self cacheURL];

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
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
//    NSURL* cacheURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cache.sqlite"];
    NSURL* cacheURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"canopus.sqlite"];
    NSLog(@"cache URL: %@", cacheURL);
    return cacheURL;
}

-(NSMappingModel*)syncMapping
{
    NSError* error = nil;
    NSMappingModel* model = [NSMappingModel inferredMappingModelForSourceModel:[self managedObjectModel]
                                                              destinationModel:[self managedObjectModel]
                                                                         error:&error];

    if (error) {
        NSLog(@"Error creating mapping model: %@", error);
        return nil;
    }

    for (NSEntityMapping* entityMapping in model.entityMappings) {
        [entityMapping setEntityMigrationPolicyClassName:NSStringFromClass([NSPDynamoSyncEntityMigrationPolicy class])];
    }

    return model;
}

-(void)migrate
{
    NSMigrationManager* migrationManager = [[NSMigrationManager alloc] initWithSourceModel:[self managedObjectModel]
                                                                          destinationModel:[self managedObjectModel]];
    NSError* error = nil;

    NSMappingModel* model = [self syncMapping];
    if (!model) return;

    [migrationManager migrateStoreFromURL:nil
                                     type:NSPDynamoStoreType
                                  options:@{ NSPDynamoStoreDynamoDBKey : kDynamoDBKey }
                         withMappingModel:model
                         toDestinationURL:[self cacheURL]
                          destinationType:NSSQLiteStoreType
                       destinationOptions:nil
                                    error:&error];
    if (error) {
        NSLog(@"migration error: %@", error);
    }
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
