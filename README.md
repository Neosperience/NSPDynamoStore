NSPDynamoStore
==============

`NSPDynamoStore` is a [NSIncrementalStore](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSIncrementalStore_Class/index.html "NSIncrementalStore") subclass that allows seamless integration of [Amazon DynamoDB](http://aws.amazon.com/dynamodb/ "Amazon DynamoDB") backed databases into [Core Data](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html "Core Data") framework.

## Introduction ##

### What is Core Data? ###

This chapter is a brief introduction to Core Data. If you already know the architecture of Core Data stack, are familiar with conecpts of object faulting, managed object context, persistent stores and persistent store coordinators, feel free to skip this chapter.

"Core Data is an object graph and persistence framework provided by Apple in the Mac OS X and iOS operating systems." ([Wikipedia](http://en.wikipedia.org/wiki/Core_Data "Core Data on Wikipedia")) Core Data provides object lifecycle and object graph management with the help of a concept called *object faulting*. Faulted objects are placeholders of the data objects that are not yet loaded into the memory because for memory saving reasons or because the cost of retrieving an object is high (involves disk or network requests) and thus a lazy loading is desirable. 

Core Data is well-known to iOS and OS X developers as it comes with built-in support for saving data in an SQLite store and so it is one of the simplest solution to store local data on the device in a structured, object-oriented way. From this point of view Core Data is an object-relational mapper over SQLite.

Core Data has a stack like architecture:

 * The [managed object context](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/index.html#//apple_ref/occ/cl/NSManagedObjectContext "NSManagedObjectContext Class Reference") is a single “object space” or scratch pad in an application. Its responsibilities includes life-cycle management (including faulting), validation, inverse relationship handling, and undo/redo management of the data objects.
 * The [persistent store coordinator](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSPersistentStoreCoordinator_Class/index.html#//apple_ref/occ/cl/NSPersistentStoreCoordinator "NSPersistentStoreCoordinator Class Reference") is designed to present a façade to the managed object contexts such that a group of persistent stores appears as an aggregate store. In the case of `NSPDynamoStore` all data objects comes from the same source (DynamoDB) and thus typically one persitent store and persistent store coordinator are needed in an app.
 * A [persistent store](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSPersistentStore_Class/index.html#//apple_ref/occ/cl/NSPersistentStore "NSPersistentStore Class Reference") is associated with the external data store and is responsible for mapping between data in that store and corresponding objects in a managed object context.

Starting from iOS 5.0 and OS X 10.7 Apple has introduced the possibility to implement a persistent store subclass thus encapsulate the logic of fetching remote or local data within Core Data stack. In fact the [documentation](https://developer.apple.com/library/prerelease/mac/documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706 "Incremental Store Programming Guide") mentions the use case of backing a persistent store with remote web services.

For more information check out the [Core Data Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html#//apple_ref/doc/uid/TP30001200-SW1 "Core Data Programming Guide") and [Incremental Store Programming Guide](https://developer.apple.com/library/prerelease/mac/documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706 "Incremental Store Programming Guide").

### What is Amazon DynamoDB? ###

Amazon DynamoDB is a fully managed NoSQL database service that is offered by Amazon.com as part of the Amazon Web Services portfolio. The database can be accessed via web services forming part of AWS. For more information check out the [Amazon DynamoDB homepage](http://aws.amazon.com/dynamodb/ "AWS DynamoDB homepage"). 

### What is `NSPDynamoStore`? ###

`NSPDynamoStore` is a persistent store implementation that uses Amazon DynamoDB as a backing data store. To access data stored in DynamoDB it needs Internet connection and a configured DynamoDB service access. 

## Getting started ##

### Set up a DynamoDB client ###

Follow the steps described in the [AWS DynamoDB SDK for iOS Getting Started Guide](http://docs.aws.amazon.com/mobile/sdkforios/developerguide/dynamodb_om.html) to set up DynamoDB access from your app. You do not need to set up an Object Mapper Client or define Mapping Classes as described in the document, but set up an example DynamoDB table. 

Once you successfully created a `AWSServiceConfiguration` register a `AWSDynamoDB` instance with your custom key:

    AWSServiceConfiguration *configuration = …
    [AWSDynamoDB registerDynamoDBWithConfiguration:configuration forKey:@"your_dynamodb_key"];

### Create a Core Data Managed Object Model ###

Create the *Core Data Managed Object Model* in the *Managed Object Model Editor* of Xcode. If you are unsure how to do this, follow one of the numerous tutorials available online, for example that one on the site of [Ray Wenderlich](http://www.raywenderlich.com/934/core-data-tutorial-for-ios-getting-started "Core Data Tutorial for iOS on Ray Wenderlich's site"). 

We suggest that you use the *DynamoDB Table names* as *Core Data Entity names* but this is not obligatory. However if you use different names you should configure the DynamoDB Table names in the Managed Object Model as described later. The same is true for the Attribute names of your Core Data entity: if they match the column keys of your DynamoDB table then `NSPDynamoStore` will recognize them automatically, otherwise you should define the DynamoDB table keys in the Managed Object Model.

Currently the following attribute types are supported:

| Core Data attribute type | DynamoDB type           |
|--------------------------|-------------------------|
| String                   | String                  |
| Number types             | Number                  |
| to-one relationship      | String or Number        |
| to-many relationship     | StringSet or NumberSet  |

In the case of to-one relationship, the DynamoDB Table for the key should hold the Primary Hash Key value of the destination object. In the case of to-many relationship, the DynamoDB Table for the key should hold a Set containing the Primary Hash Key values of the destination objects.

### Define additional DynamoDB metadata in Managed Object Model ###

**Primary Hash Key**

Select an entity in Managed Object Model Editor and on the Utilities pane select the Data Model Inspector (Alt+Cmd+3). Create a new User Info key with the name `NSPDynamoStoreEntityHashKeyAttributeName` and with the value of the name of your Primary Hash Key of the associated DynamoDB table. 

Defining the Primary Hash Key attribute name is obligatory for each entity.

**DynamoDB Table Name**

If you used different names for your Core Data Entity and your DynamoDB table then you should tell the DynamoDB table name to the Core Data Entity. Define a new User Info key for the entity with the name `NSPDynamoStoreEntityDynamoDBTableName` and with the value of the name of your Table in DynamoDB. 

This step is not necessary if you used the same name for your Core Data Entity as the name of your DynamoDB Table.

**DynamoDB data key name**

If you used different names for your attributes of a Core Data Entity from the data keys used in the corresponding DynamoDB table then you should tell the DynamoDB key name to the Core Data Entity. Select the attribute of the entity and add a new User Info key with the name `NSPDynamoStoreAttributeName` and the value of the name of the key in the DynamoDB table.

This step is not necessary if you used the same name for your Core Data property as the corresponding data object key in the DynamoDB table.

### Create Managed Object subclasses ###

Create Managed Object subclasses for your model with Xcode selecting Editor -> Create NSManagedObject subclass or with [mogenerator](https://github.com/rentzsch/mogenerator) as you would do for a standard SQLite backed Core Data stack.

### Set up Core Data stack ###

Set up the `NSManagedObjectModel`, `NSPersistentStoreCoordinator` and `NSManagedObjectContext` instances for your application. This is automatically done for you in your `AppDelegate.m` file if you choosed "Use Core Data" when creating your Xcode project. Initialize your `NSManagedObjectContext` with `NSPrivateQueueConcurrencyType`:

    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

### Change the Persistent Store Coordinator to NSPDynamoStore ###

When adding the persistent store to the coordinator, replace the persistent store type from `NSSQLiteStoreType` to `[NSPDynamoStore storeType]`. Specify your `AWSDynamoDB` instance key in the options dictionary for the `NSPDynamoStoreDynamoDBKey`:

    NSDictionary *options = @{ NSPDynamoStoreDynamoDBKey : @"your_dynamodb_key" };
    [self.persistentStoreCoordinator addPersistentStoreWithType:[NSPDynamoStore storeType]
                                                  configuration:nil
                                                            URL:nil
                                                        options:options
                                                          error:nil];

### Make a fetch request ###

At this point you can make fetch requests to your DynamoDB table with the standard Core Data methods:

    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MyEntity"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"someValue"];
    
    [self.managedObjectContext performBlock:^{
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        id firstItem = [results firstObject];
		NSLog(@"%@", [firstItem valueForKey:@"name"]);
        }
    }];

`NSPDynamoPersistentStore` execute the requests synchronously as it is expected by Core Data.  As executing a request involves a network communication, it is suggested that you create a managed object context of `NSPrivateQueueConcurrencyType` and execute the requests on the background queue of the context.

 `NSPDynamoPersistentStore` currently supports only a strict subset of the predicate operators involving <, <=, ==, >=, >, BEGINSWITH, CONTAINS, BETWEEN and IN. It supports compound predicates ANDed or ORed together but not mixed.