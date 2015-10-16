/*
 Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at
 
 http://aws.amazon.com/apache2.0
 
 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */

#import "AWSAutoScalingResources.h"
#import "AWSLogging.h"

@interface AWSAutoScalingResources ()

@property (nonatomic, strong) NSDictionary *definitionDictionary;

@end

@implementation AWSAutoScalingResources

+ (instancetype)sharedInstance {
    static AWSAutoScalingResources *_sharedResources = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        _sharedResources = [AWSAutoScalingResources new];
    });
    
    return _sharedResources;
}
- (NSDictionary *)JSONObject {
    return self.definitionDictionary;
}

- (instancetype)init {
    if (self = [super init]) {
        //init method
        NSError *error = nil;
        _definitionDictionary = [NSJSONSerialization JSONObjectWithData:[[self definitionString] dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:kNilOptions
                                                                  error:&error];
        if (_definitionDictionary == nil) {
            if (error) {
                AWSLogError(@"Failed to parse JSON service definition: %@",error);
            }
        }
    }
    return self;
}

- (NSString *)definitionString {
    return @" \
    { \
      \"version\":\"2.0\", \
      \"metadata\":{ \
        \"apiVersion\":\"2011-01-01\", \
        \"endpointPrefix\":\"autoscaling\", \
        \"serviceFullName\":\"Auto Scaling\", \
        \"signatureVersion\":\"v4\", \
        \"xmlNamespace\":\"http://autoscaling.amazonaws.com/doc/2011-01-01/\", \
        \"protocol\":\"query\" \
      }, \
      \"documentation\":\"<fullname>Auto Scaling</fullname> <p> Auto Scaling is a web service designed to automatically launch or terminate Amazon Elastic Compute Cloud (Amazon EC2) instances based on user-defined policies, schedules, and health checks. This service is used in conjunction with Amazon CloudWatch and Elastic Load Balancing services. </p> <p>Auto Scaling provides APIs that you can call by submitting a Query Request. Query requests are HTTP or HTTPS requests that use the HTTP verbs GET or POST and a Query parameter named <i>Action</i> or <i>Operation</i> that specifies the API you are calling. Action is used throughout this documentation, although Operation is also supported for backward compatibility with other Amazon Web Services (AWS) Query APIs. </p> <p>Calling the API using a Query request is the most direct way to access the web service, but requires that your application handle low-level details such as generating the hash to sign the request and error handling. The benefit of calling the service using a Query request is that you are assured of having access to the complete functionality of the API. For information about signing a a query request, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/api_requests.html\\\">Use Query Requests to Call Auto Scaling APIs</a></p> <p> This guide provides detailed information about Auto Scaling actions, data types, parameters, and errors. For detailed information about Auto Scaling features and their associated API actions, go to the <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/\\\">Auto Scaling Developer Guide</a>. </p> <p>This reference is based on the current WSDL, which is available at:</p> <p><a href=\\\"http://autoscaling.amazonaws.com/doc/2011-01-01/AutoScaling.wsdl\\\">http://autoscaling.amazonaws.com/doc/2011-01-01/AutoScaling.wsdl</a> </p> <p><b>Endpoints</b></p> <p>The examples in this guide assume that your instances are launched in the US East (Northern Virginia) region and use us-east-1 as the endpoint.</p> <p>You can set up your Auto Scaling infrastructure in other AWS regions. For information about this product's regions and endpoints, see <a href=\\\"http://docs.aws.amazon.com/general/latest/gr/index.html?rande.html\\\">Regions and Endpoints</a> in the Amazon Web Services General Reference. </p>\", \
      \"operations\":{ \
        \"AttachInstances\":{ \
          \"name\":\"AttachInstances\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"AttachInstancesQuery\"}, \
          \"documentation\":\"<p> Attaches one or more Amazon EC2 instances to an existing Auto Scaling group. After the instance(s) is attached, it becomes a part of the Auto Scaling group. </p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/attach-instance-asg.html\\\">Attach Amazon EC2 Instances to Your Existing Auto Scaling Group</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
        }, \
        \"CompleteLifecycleAction\":{ \
          \"name\":\"CompleteLifecycleAction\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"CompleteLifecycleActionType\"}, \
          \"output\":{ \
            \"shape\":\"CompleteLifecycleActionAnswer\", \
            \"documentation\":\"<p>The output of the <a>CompleteLifecycleAction</a>. </p>\", \
            \"resultWrapper\":\"CompleteLifecycleActionResult\" \
          }, \
          \"documentation\":\"<p>Completes the lifecycle action for the associated token initiated under the given lifecycle hook with the specified result. </p> <p> This operation is a part of the basic sequence for adding a lifecycle hook to an Auto Scaling group: </p> <ol> <li> Create a notification target. A target can be either an Amazon SQS queue or an Amazon SNS topic. </li> <li> Create an IAM role. This role allows Auto Scaling to publish lifecycle notifications to the designated SQS queue or SNS topic. </li> <li> Create the lifecycle hook. You can create a hook that acts when instances launch or when instances terminate. </li> <li> If necessary, record the lifecycle action heartbeat to keep the instance in a pending state. </li> <li> <b>Complete the lifecycle action.</b> </li> </ol> <p>To learn more, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingPendingState.html\\\">Auto Scaling Pending State</a> and <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingTerminatingState.html\\\">Auto Scaling Terminating State</a>.</p>\" \
        }, \
        \"CreateAutoScalingGroup\":{ \
          \"name\":\"CreateAutoScalingGroup\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"CreateAutoScalingGroupType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"AlreadyExistsFault\", \
              \"error\":{ \
                \"code\":\"AlreadyExists\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The named Auto Scaling group or launch configuration already exists. </p>\" \
            }, \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Creates a new Auto Scaling group with the specified name and other attributes. When the creation request is completed, the Auto Scaling group is ready to be used in other calls. </p> <note> The Auto Scaling group name must be unique within the scope of your AWS account. </note>\" \
        }, \
        \"CreateLaunchConfiguration\":{ \
          \"name\":\"CreateLaunchConfiguration\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"CreateLaunchConfigurationType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"AlreadyExistsFault\", \
              \"error\":{ \
                \"code\":\"AlreadyExists\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The named Auto Scaling group or launch configuration already exists. </p>\" \
            }, \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Creates a new launch configuration. The launch configuration name must be unique within the scope of the client's AWS account. The maximum limit of launch configurations, which by default is 100, must not yet have been met; otherwise, the call will fail. When created, the new launch configuration is available for immediate use. </p>\" \
        }, \
        \"CreateOrUpdateTags\":{ \
          \"name\":\"CreateOrUpdateTags\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"CreateOrUpdateTagsType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            }, \
            { \
              \"shape\":\"AlreadyExistsFault\", \
              \"error\":{ \
                \"code\":\"AlreadyExists\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The named Auto Scaling group or launch configuration already exists. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Creates new tags or updates existing tags for an Auto Scaling group. </p> <note> A tag's definition is composed of a resource ID, resource type, key and value, and the propagate flag. Value and the propagate flag are optional parameters. See the Request Parameters for more information. </note> <p>For information on creating tags for your Auto Scaling group, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/ASTagging.html\\\">Tag Your Auto Scaling Groups and Amazon EC2 Instances</a>.</p>\" \
        }, \
        \"DeleteAutoScalingGroup\":{ \
          \"name\":\"DeleteAutoScalingGroup\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DeleteAutoScalingGroupType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"ScalingActivityInProgressFault\", \
              \"error\":{ \
                \"code\":\"ScalingActivityInProgress\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
            }, \
            { \
              \"shape\":\"ResourceInUseFault\", \
              \"error\":{ \
                \"code\":\"ResourceInUse\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> This is returned when you cannot delete a launch configuration or Auto Scaling group because it is being used. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Deletes the specified Auto Scaling group if the group has no instances and no scaling activities in progress. </p> <note> To remove all instances before calling <a>DeleteAutoScalingGroup</a>, you can call <a>UpdateAutoScalingGroup</a> to set the minimum and maximum size of the AutoScalingGroup to zero. </note>\" \
        }, \
        \"DeleteLaunchConfiguration\":{ \
          \"name\":\"DeleteLaunchConfiguration\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"LaunchConfigurationNameType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"ResourceInUseFault\", \
              \"error\":{ \
                \"code\":\"ResourceInUse\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> This is returned when you cannot delete a launch configuration or Auto Scaling group because it is being used. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Deletes the specified <a>LaunchConfiguration</a>. </p> <p> The specified launch configuration must not be attached to an Auto Scaling group. When this call completes, the launch configuration is no longer available for use. </p>\" \
        }, \
        \"DeleteLifecycleHook\":{ \
          \"name\":\"DeleteLifecycleHook\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DeleteLifecycleHookType\"}, \
          \"output\":{ \
            \"shape\":\"DeleteLifecycleHookAnswer\", \
            \"documentation\":\"<p>The output of the <a>DeleteLifecycleHook</a> action. </p>\", \
            \"resultWrapper\":\"DeleteLifecycleHookResult\" \
          }, \
          \"documentation\":\"<p>Deletes the specified lifecycle hook. If there are any outstanding lifecycle actions, they are completed first (ABANDON for launching instances, CONTINUE for terminating instances).</p>\" \
        }, \
        \"DeleteNotificationConfiguration\":{ \
          \"name\":\"DeleteNotificationConfiguration\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DeleteNotificationConfigurationType\", \
            \"documentation\":\"<p></p>\" \
          }, \
          \"documentation\":\"<p>Deletes notifications created by <a>PutNotificationConfiguration</a>.</p>\" \
        }, \
        \"DeletePolicy\":{ \
          \"name\":\"DeletePolicy\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DeletePolicyType\", \
            \"documentation\":\"<p></p>\" \
          }, \
          \"documentation\":\"<p>Deletes a policy created by <a>PutScalingPolicy</a>.</p>\" \
        }, \
        \"DeleteScheduledAction\":{ \
          \"name\":\"DeleteScheduledAction\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DeleteScheduledActionType\", \
            \"documentation\":\"<p></p>\" \
          }, \
          \"documentation\":\"<p>Deletes a scheduled action previously created using the <a>PutScheduledUpdateGroupAction</a>.</p>\" \
        }, \
        \"DeleteTags\":{ \
          \"name\":\"DeleteTags\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DeleteTagsType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"documentation\":\"<p>Removes the specified tags or a set of tags from a set of resources.</p>\" \
        }, \
        \"DescribeAccountLimits\":{ \
          \"name\":\"DescribeAccountLimits\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeAccountLimitsAnswer\", \
            \"documentation\":\"<p> The output of the <a>DescribeAccountLimitsResult</a> action. </p>\", \
            \"resultWrapper\":\"DescribeAccountLimitsResult\" \
          }, \
          \"documentation\":\"<p> Returns the limits for the Auto Scaling resources currently allowed for your AWS account. </p> <p>Your AWS account comes with default limits on resources for Auto Scaling. There is a default limit of <code>20</code> Auto Scaling groups and <code>100</code> launch configurations per region.</p> <p>If you reach the limits for the number of Auto Scaling groups or the launch configurations, you can go to the <a href=\\\"https://aws.amazon.com/support/\\\">Support Center</a> and place a request to raise the limits.</p>\" \
        }, \
        \"DescribeAdjustmentTypes\":{ \
          \"name\":\"DescribeAdjustmentTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeAdjustmentTypesAnswer\", \
            \"documentation\":\"<p> The output of the <a>DescribeAdjustmentTypes</a> action. </p>\", \
            \"resultWrapper\":\"DescribeAdjustmentTypesResult\" \
          }, \
          \"documentation\":\"<p> Returns policy adjustment types for use in the <a>PutScalingPolicy</a> action. </p>\" \
        }, \
        \"DescribeAutoScalingGroups\":{ \
          \"name\":\"DescribeAutoScalingGroups\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"AutoScalingGroupNamesType\", \
            \"documentation\":\"<p> The <code>AutoScalingGroupNamesType</code> data type. </p>\" \
          }, \
          \"output\":{ \
            \"shape\":\"AutoScalingGroupsType\", \
            \"documentation\":\"<p> The <code>AutoScalingGroupsType</code> data type. </p>\", \
            \"resultWrapper\":\"DescribeAutoScalingGroupsResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns a full description of each Auto Scaling group in the given list. This includes all Amazon EC2 instances that are members of the group. If a list of names is not provided, the service returns the full details of all Auto Scaling groups. </p> <p> This action supports pagination by returning a token if there are more pages to retrieve. To get the next page, call this action again with the returned token as the <code>NextToken</code> parameter. </p>\" \
        }, \
        \"DescribeAutoScalingInstances\":{ \
          \"name\":\"DescribeAutoScalingInstances\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DescribeAutoScalingInstancesType\"}, \
          \"output\":{ \
            \"shape\":\"AutoScalingInstancesType\", \
            \"documentation\":\"<p> The <code>AutoScalingInstancesType</code> data type. </p>\", \
            \"resultWrapper\":\"DescribeAutoScalingInstancesResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns a description of each Auto Scaling instance in the <code>InstanceIds</code> list. If a list is not provided, the service returns the full details of all instances up to a maximum of 50. By default, the service returns a list of 20 items. </p> <p> This action supports pagination by returning a token if there are more pages to retrieve. To get the next page, call this action again with the returned token as the <code>NextToken</code> parameter. </p>\" \
        }, \
        \"DescribeAutoScalingNotificationTypes\":{ \
          \"name\":\"DescribeAutoScalingNotificationTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeAutoScalingNotificationTypesAnswer\", \
            \"documentation\":\"<p>The <code>AutoScalingNotificationTypes</code> data type.</p>\", \
            \"resultWrapper\":\"DescribeAutoScalingNotificationTypesResult\" \
          }, \
          \"documentation\":\"<p> Returns a list of all notification types that are supported by Auto Scaling. </p>\" \
        }, \
        \"DescribeLaunchConfigurations\":{ \
          \"name\":\"DescribeLaunchConfigurations\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"LaunchConfigurationNamesType\", \
            \"documentation\":\"<p> The <code>LaunchConfigurationNamesType</code> data type. </p>\" \
          }, \
          \"output\":{ \
            \"shape\":\"LaunchConfigurationsType\", \
            \"documentation\":\"<p> The <code>LaunchConfigurationsType</code> data type. </p>\", \
            \"resultWrapper\":\"DescribeLaunchConfigurationsResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns a full description of the launch configurations, or the specified launch configurations, if they exist. </p> <p> If no name is specified, then the full details of all launch configurations are returned. </p>\" \
        }, \
        \"DescribeLifecycleHookTypes\":{ \
          \"name\":\"DescribeLifecycleHookTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeLifecycleHookTypesAnswer\", \
            \"resultWrapper\":\"DescribeLifecycleHookTypesResult\" \
          }, \
          \"documentation\":\"<p>Describes the available types of lifecycle hooks.</p>\" \
        }, \
        \"DescribeLifecycleHooks\":{ \
          \"name\":\"DescribeLifecycleHooks\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DescribeLifecycleHooksType\"}, \
          \"output\":{ \
            \"shape\":\"DescribeLifecycleHooksAnswer\", \
            \"documentation\":\"<p>The output of the <a>DescribeLifecycleHooks</a> action. </p>\", \
            \"resultWrapper\":\"DescribeLifecycleHooksResult\" \
          }, \
          \"documentation\":\"<p> Describes the lifecycle hooks that currently belong to the specified Auto Scaling group. </p>\" \
        }, \
        \"DescribeMetricCollectionTypes\":{ \
          \"name\":\"DescribeMetricCollectionTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeMetricCollectionTypesAnswer\", \
            \"documentation\":\"<p>The output of the <a>DescribeMetricCollectionTypes</a> action.</p>\", \
            \"resultWrapper\":\"DescribeMetricCollectionTypesResult\" \
          }, \
          \"documentation\":\"<p> Returns a list of metrics and a corresponding list of granularities for each metric. </p> <note> <p>The <code>GroupStandbyInstances</code> metric is not returned by default. You must explicitly request it when calling <a>EnableMetricsCollection</a>.</p> </note>\" \
        }, \
        \"DescribeNotificationConfigurations\":{ \
          \"name\":\"DescribeNotificationConfigurations\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DescribeNotificationConfigurationsType\"}, \
          \"output\":{ \
            \"shape\":\"DescribeNotificationConfigurationsAnswer\", \
            \"documentation\":\"<p>The output of the <a>DescribeNotificationConfigurations</a> action.</p>\", \
            \"resultWrapper\":\"DescribeNotificationConfigurationsResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns a list of notification actions associated with Auto Scaling groups for specified events. </p>\" \
        }, \
        \"DescribePolicies\":{ \
          \"name\":\"DescribePolicies\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DescribePoliciesType\"}, \
          \"output\":{ \
            \"shape\":\"PoliciesType\", \
            \"documentation\":\"<p> The <code>PoliciesType</code> data type. </p>\", \
            \"resultWrapper\":\"DescribePoliciesResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns descriptions of what each policy does. This action supports pagination. If the response includes a token, there are more records available. To get the additional records, repeat the request with the response token as the <code>NextToken</code> parameter. </p>\" \
        }, \
        \"DescribeScalingActivities\":{ \
          \"name\":\"DescribeScalingActivities\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DescribeScalingActivitiesType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"output\":{ \
            \"shape\":\"ActivitiesType\", \
            \"documentation\":\"<p> The output for the <a>DescribeScalingActivities</a> action. </p>\", \
            \"resultWrapper\":\"DescribeScalingActivitiesResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Returns the scaling activities for the specified Auto Scaling group. </p> <p> If the specified <code>ActivityIds</code> list is empty, all the activities from the past six weeks are returned. Activities are sorted by the start time. Activities still in progress appear first on the list. </p> <p> This action supports pagination. If the response includes a token, there are more records available. To get the additional records, repeat the request with the response token as the <code>NextToken</code> parameter. </p>\" \
        }, \
        \"DescribeScalingProcessTypes\":{ \
          \"name\":\"DescribeScalingProcessTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"ProcessesType\", \
            \"documentation\":\"<p> The output of the <a>DescribeScalingProcessTypes</a> action. </p>\", \
            \"resultWrapper\":\"DescribeScalingProcessTypesResult\" \
          }, \
          \"documentation\":\"<p>Returns scaling process types for use in the <a>ResumeProcesses</a> and <a>SuspendProcesses</a> actions.</p>\" \
        }, \
        \"DescribeScheduledActions\":{ \
          \"name\":\"DescribeScheduledActions\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DescribeScheduledActionsType\"}, \
          \"output\":{ \
            \"shape\":\"ScheduledActionsType\", \
            \"documentation\":\"<p> A scaling action that is scheduled for a future time and date. An action can be scheduled up to thirty days in advance. </p> <p> Starting with API version 2011-01-01, you can use <code>recurrence</code> to specify that a scaling action occurs regularly on a schedule. </p>\", \
            \"resultWrapper\":\"DescribeScheduledActionsResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Lists all the actions scheduled for your Auto Scaling group that haven't been executed. To see a list of actions already executed, see the activity record returned in <a>DescribeScalingActivities</a>. </p>\" \
        }, \
        \"DescribeTags\":{ \
          \"name\":\"DescribeTags\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"DescribeTagsType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"output\":{ \
            \"shape\":\"TagsType\", \
            \"documentation\":\"<p> </p>\", \
            \"resultWrapper\":\"DescribeTagsResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"InvalidNextToken\", \
              \"error\":{ \
                \"code\":\"InvalidNextToken\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Lists the Auto Scaling group tags. </p> <p> You can use filters to limit results when describing tags. For example, you can query for tags of a particular Auto Scaling group. You can specify multiple values for a filter. A tag must match at least one of the specified values for it to be included in the results. </p> <p> You can also specify multiple filters. The result includes information for a particular tag only if it matches all your filters. If there's no match, no special message is returned. </p>\" \
        }, \
        \"DescribeTerminationPolicyTypes\":{ \
          \"name\":\"DescribeTerminationPolicyTypes\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"output\":{ \
            \"shape\":\"DescribeTerminationPolicyTypesAnswer\", \
            \"documentation\":\"<p>The <code>TerminationPolicyTypes</code> data type.</p>\", \
            \"resultWrapper\":\"DescribeTerminationPolicyTypesResult\" \
          }, \
          \"documentation\":\"<p> Returns a list of all termination policies supported by Auto Scaling. </p>\" \
        }, \
        \"DetachInstances\":{ \
          \"name\":\"DetachInstances\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DetachInstancesQuery\"}, \
          \"output\":{ \
            \"shape\":\"DetachInstancesAnswer\", \
            \"documentation\":\"<p>The output of the <a>DetachInstances</a> action. </p>\", \
            \"resultWrapper\":\"DetachInstancesResult\" \
          }, \
          \"documentation\":\"<p>Using <code>DetachInstances</code>, you can remove an instance from an Auto Scaling group. After the instances are detached, you can manage them independently from the rest of the Auto Scaling group.</p> <p>To learn more about detaching instances, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/detach-instance-asg.html\\\">Detach Amazon EC2 Instances From Your Auto Scaling Group</a>.</p>\" \
        }, \
        \"DisableMetricsCollection\":{ \
          \"name\":\"DisableMetricsCollection\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"DisableMetricsCollectionQuery\"}, \
          \"documentation\":\"<p> Disables monitoring of group metrics for the Auto Scaling group specified in <code>AutoScalingGroupName</code>. You can specify the list of affected metrics with the <code>Metrics</code> parameter. </p>\" \
        }, \
        \"EnableMetricsCollection\":{ \
          \"name\":\"EnableMetricsCollection\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"EnableMetricsCollectionQuery\"}, \
          \"documentation\":\"<p> Enables monitoring of group metrics for the Auto Scaling group specified in <code>AutoScalingGroupName</code>. You can specify the list of enabled metrics with the <code>Metrics</code> parameter. </p> <p> Auto Scaling metrics collection can be turned on only if the <code>InstanceMonitoring</code> flag, in the Auto Scaling group's launch configuration, is set to <code>True</code>. </p>\" \
        }, \
        \"EnterStandby\":{ \
          \"name\":\"EnterStandby\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"EnterStandbyQuery\"}, \
          \"output\":{ \
            \"shape\":\"EnterStandbyAnswer\", \
            \"documentation\":\"<p>The output of the <a>EnterStandby</a> action. </p>\", \
            \"resultWrapper\":\"EnterStandbyResult\" \
          }, \
          \"documentation\":\"<p> Move instances in an Auto Scaling group into a Standby mode. </p> <p>To learn more about how to put instances into a Standby mode, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingInServiceState.html\\\">Auto Scaling InService State</a>.</p>\" \
        }, \
        \"ExecutePolicy\":{ \
          \"name\":\"ExecutePolicy\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"ExecutePolicyType\"}, \
          \"errors\":[ \
            { \
              \"shape\":\"ScalingActivityInProgressFault\", \
              \"error\":{ \
                \"code\":\"ScalingActivityInProgress\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
            } \
          ], \
          \"documentation\":\"<p>Executes the specified policy. </p>\" \
        }, \
        \"ExitStandby\":{ \
          \"name\":\"ExitStandby\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"ExitStandbyQuery\"}, \
          \"output\":{ \
            \"shape\":\"ExitStandbyAnswer\", \
            \"documentation\":\"<p>The output of the <a>ExitStandby</a> action. </p>\", \
            \"resultWrapper\":\"ExitStandbyResult\" \
          }, \
          \"documentation\":\"<p> Move an instance out of Standby mode. </p> <p>To learn more about how to put instances that are in a Standby mode back into service, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingInServiceState.html\\\">Auto Scaling InService State</a>.</p>\" \
        }, \
        \"PutLifecycleHook\":{ \
          \"name\":\"PutLifecycleHook\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"PutLifecycleHookType\"}, \
          \"output\":{ \
            \"shape\":\"PutLifecycleHookAnswer\", \
            \"documentation\":\"<p>The output of the <a>PutLifecycleHook</a> action. </p>\", \
            \"resultWrapper\":\"PutLifecycleHookResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p>Creates or updates a lifecycle hook for an Auto Scaling Group.</p> <p>A lifecycle hook tells Auto Scaling that you want to perform an action on an instance that is not actively in service; for example, either when the instance launches or before the instance terminates.</p> <p> This operation is a part of the basic sequence for adding a lifecycle hook to an Auto Scaling group: </p> <ol> <li> Create a notification target. A target can be either an Amazon SQS queue or an Amazon SNS topic. </li> <li> Create an IAM role. This role allows Auto Scaling to publish lifecycle notifications to the designated SQS queue or SNS topic. </li> <li> <b>Create the lifecycle hook. You can create a hook that acts when instances launch or when instances terminate.</b> </li> <li> If necessary, record the lifecycle action heartbeat to keep the instance in a pending state. </li> <li> Complete the lifecycle action. </li> </ol> <p>To learn more, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingPendingState.html\\\">Auto Scaling Pending State</a> and <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingTerminatingState.html\\\">Auto Scaling Terminating State</a>.</p>\" \
        }, \
        \"PutNotificationConfiguration\":{ \
          \"name\":\"PutNotificationConfiguration\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"PutNotificationConfigurationType\"}, \
          \"errors\":[ \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Configures an Auto Scaling group to send notifications when specified events take place. Subscribers to this topic can have messages for events delivered to an endpoint such as a web server or email address. </p> <p>For more information see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/ASGettingNotifications.html\\\">Get Email Notifications When Your Auto Scaling Group Changes</a></p> <p>A new <code>PutNotificationConfiguration</code> overwrites an existing configuration. </p>\" \
        }, \
        \"PutScalingPolicy\":{ \
          \"name\":\"PutScalingPolicy\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"PutScalingPolicyType\"}, \
          \"output\":{ \
            \"shape\":\"PolicyARNType\", \
            \"documentation\":\"<p> The <code>PolicyARNType</code> data type. </p>\", \
            \"resultWrapper\":\"PutScalingPolicyResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Creates or updates a policy for an Auto Scaling group. To update an existing policy, use the existing policy name and set the parameter(s) you want to change. Any existing parameter not changed in an update to an existing policy is not changed in this update request. </p>\" \
        }, \
        \"PutScheduledUpdateGroupAction\":{ \
          \"name\":\"PutScheduledUpdateGroupAction\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"PutScheduledUpdateGroupActionType\"}, \
          \"errors\":[ \
            { \
              \"shape\":\"AlreadyExistsFault\", \
              \"error\":{ \
                \"code\":\"AlreadyExists\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The named Auto Scaling group or launch configuration already exists. </p>\" \
            }, \
            { \
              \"shape\":\"LimitExceededFault\", \
              \"error\":{ \
                \"code\":\"LimitExceeded\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Creates or updates a scheduled scaling action for an Auto Scaling group. When updating a scheduled scaling action, if you leave a parameter unspecified, the corresponding value remains unchanged in the affected Auto Scaling group. </p> <p>For information on creating or updating a scheduled action for your Auto Scaling group, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/schedule_time.html\\\">Scale Based on a Schedule</a>.</p> <note> <p>Auto Scaling supports the date and time expressed in \\\"YYYY-MM-DDThh:mm:ssZ\\\" format in UTC/GMT only.</p> </note>\" \
        }, \
        \"RecordLifecycleActionHeartbeat\":{ \
          \"name\":\"RecordLifecycleActionHeartbeat\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"RecordLifecycleActionHeartbeatType\"}, \
          \"output\":{ \
            \"shape\":\"RecordLifecycleActionHeartbeatAnswer\", \
            \"documentation\":\"<p>The output of the <a>RecordLifecycleActionHeartbeat</a> action. </p>\", \
            \"resultWrapper\":\"RecordLifecycleActionHeartbeatResult\" \
          }, \
          \"documentation\":\"<p> Records a heartbeat for the lifecycle action associated with a specific token. This extends the timeout by the length of time defined by the <code>HeartbeatTimeout</code> parameter of the <a>PutLifecycleHook</a> operation. </p> <p> This operation is a part of the basic sequence for adding a lifecycle hook to an Auto Scaling group: </p> <ol> <li> Create a notification target. A target can be either an Amazon SQS queue or an Amazon SNS topic. </li> <li> Create an IAM role. This role allows Auto Scaling to publish lifecycle notifications to the designated SQS queue or SNS topic. </li> <li> Create the lifecycle hook. You can create a hook that acts when instances launch or when instances terminate. </li> <li> <b>If necessary, record the lifecycle action heartbeat to keep the instance in a pending state.</b> </li> <li> Complete the lifecycle action. </li> </ol> <p>To learn more, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingPendingState.html\\\">Auto Scaling Pending State</a> and <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingTerminatingState.html\\\">Auto Scaling Terminating State</a>.</p>\" \
        }, \
        \"ResumeProcesses\":{ \
          \"name\":\"ResumeProcesses\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"ScalingProcessQuery\"}, \
          \"documentation\":\"<p> Resumes all suspended Auto Scaling processes for an Auto Scaling group. For information on suspending and resuming Auto Scaling process, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/US_SuspendResume.html\\\">Suspend and Resume Auto Scaling Process</a>. </p>\" \
        }, \
        \"SetDesiredCapacity\":{ \
          \"name\":\"SetDesiredCapacity\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"SetDesiredCapacityType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"ScalingActivityInProgressFault\", \
              \"error\":{ \
                \"code\":\"ScalingActivityInProgress\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Sets the desired size of the specified <a>AutoScalingGroup</a>. </p>\" \
        }, \
        \"SetInstanceHealth\":{ \
          \"name\":\"SetInstanceHealth\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"SetInstanceHealthQuery\"}, \
          \"documentation\":\"<p> Sets the health status of a specified instance that belongs to any of your Auto Scaling groups. </p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/as-configure-healthcheck.html\\\">Configure Health Checks for Your Auto Scaling group</a>.</p>\" \
        }, \
        \"SuspendProcesses\":{ \
          \"name\":\"SuspendProcesses\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{\"shape\":\"ScalingProcessQuery\"}, \
          \"documentation\":\"<p> Suspends Auto Scaling processes for an Auto Scaling group. To suspend specific process types, specify them by name with the <code>ScalingProcesses.member.N</code> parameter. To suspend all process types, omit the <code>ScalingProcesses.member.N</code> parameter. </p> <important> <p> Suspending either of the two primary process types, <code>Launch</code> or <code>Terminate</code>, can prevent other process types from functioning properly. </p> </important> <p> To resume processes that have been suspended, use <a>ResumeProcesses</a> For more information on suspending and resuming Auto Scaling process, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/US_SuspendResume.html\\\">Suspend and Resume Auto Scaling Process</a>. </p>\" \
        }, \
        \"TerminateInstanceInAutoScalingGroup\":{ \
          \"name\":\"TerminateInstanceInAutoScalingGroup\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"TerminateInstanceInAutoScalingGroupType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"output\":{ \
            \"shape\":\"ActivityType\", \
            \"documentation\":\"<p> The output for the <a>TerminateInstanceInAutoScalingGroup</a> action. </p>\", \
            \"resultWrapper\":\"TerminateInstanceInAutoScalingGroupResult\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"ScalingActivityInProgressFault\", \
              \"error\":{ \
                \"code\":\"ScalingActivityInProgress\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Terminates the specified instance. Optionally, the desired group size can be adjusted. </p> <note> This call simply registers a termination request. The termination of the instance cannot happen immediately. </note>\" \
        }, \
        \"UpdateAutoScalingGroup\":{ \
          \"name\":\"UpdateAutoScalingGroup\", \
          \"http\":{ \
            \"method\":\"POST\", \
            \"requestUri\":\"/\" \
          }, \
          \"input\":{ \
            \"shape\":\"UpdateAutoScalingGroupType\", \
            \"documentation\":\"<p> </p>\" \
          }, \
          \"errors\":[ \
            { \
              \"shape\":\"ScalingActivityInProgressFault\", \
              \"error\":{ \
                \"code\":\"ScalingActivityInProgress\", \
                \"httpStatusCode\":400, \
                \"senderFault\":true \
              }, \
              \"exception\":true, \
              \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
            } \
          ], \
          \"documentation\":\"<p> Updates the configuration for the specified <a>AutoScalingGroup</a>. </p> <note> <p> To update an Auto Scaling group with a launch configuration that has the <code>InstanceMonitoring</code> flag set to <code>False</code>, you must first ensure that collection of group metrics is disabled. Otherwise, calls to <a>UpdateAutoScalingGroup</a> will fail. If you have previously enabled group metrics collection, you can disable collection of all group metrics by calling <a>DisableMetricsCollection</a>. </p> </note> <p> The new settings are registered upon the completion of this call. Any launch configuration settings take effect on any triggers after this call returns. Scaling activities that are currently in progress aren't affected. </p> <note> <ul> <li> <p>If a new value is specified for <i>MinSize</i> without specifying the value for <i>DesiredCapacity</i>, and if the new <i>MinSize</i> is larger than the current size of the Auto Scaling Group, there will be an implicit call to <a>SetDesiredCapacity</a> to set the group to the new <i>MinSize</i>. </p> </li> <li> <p>If a new value is specified for <i>MaxSize</i> without specifying the value for <i>DesiredCapacity</i>, and the new <i>MaxSize</i> is smaller than the current size of the Auto Scaling Group, there will be an implicit call to <a>SetDesiredCapacity</a> to set the group to the new <i>MaxSize</i>. </p> </li> <li> <p>All other optional parameters are left unchanged if not passed in the request.</p> </li> </ul> </note>\" \
        } \
      }, \
      \"shapes\":{ \
        \"Activities\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"Activity\"} \
        }, \
        \"ActivitiesType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"Activities\"], \
          \"members\":{ \
            \"Activities\":{ \
              \"shape\":\"Activities\", \
              \"documentation\":\"<p> A list of the requested scaling activities. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> Acts as a paging mechanism for large result sets. Set to a non-empty string if there are additional results waiting to be returned. Pass this in to subsequent calls to return additional results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The output for the <a>DescribeScalingActivities</a> action. </p>\" \
        }, \
        \"Activity\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"ActivityId\", \
            \"AutoScalingGroupName\", \
            \"Cause\", \
            \"StartTime\", \
            \"StatusCode\" \
          ], \
          \"members\":{ \
            \"ActivityId\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> Specifies the ID of the activity. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"Description\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> Contains a friendly, more verbose description of the scaling activity. </p>\" \
            }, \
            \"Cause\":{ \
              \"shape\":\"XmlStringMaxLen1023\", \
              \"documentation\":\"<p> Contains the reason the activity was begun. </p>\" \
            }, \
            \"StartTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> Provides the start time of this activity. </p>\" \
            }, \
            \"EndTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> Provides the end time of this activity. </p>\" \
            }, \
            \"StatusCode\":{ \
              \"shape\":\"ScalingActivityStatusCode\", \
              \"documentation\":\"<p> Contains the current status of the activity. </p>\" \
            }, \
            \"StatusMessage\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Contains a friendly, more verbose description of the activity status. </p>\" \
            }, \
            \"Progress\":{ \
              \"shape\":\"Progress\", \
              \"documentation\":\"<p> Specifies a value between 0 and 100 that indicates the progress of the activity. </p>\" \
            }, \
            \"Details\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> Contains details of the scaling activity. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> A scaling Activity is a long-running process that represents a change to your AutoScalingGroup, such as changing the size of the group. It can also be a process to replace an instance, or a process to perform any other long-running operations supported by the API. </p>\" \
        }, \
        \"ActivityIds\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlString\"} \
        }, \
        \"ActivityType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Activity\":{ \
              \"shape\":\"Activity\", \
              \"documentation\":\"<p> A scaling Activity. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The output for the <a>TerminateInstanceInAutoScalingGroup</a> action. </p>\" \
        }, \
        \"AdjustmentType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AdjustmentType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>A policy adjustment type. Valid values are <code>ChangeInCapacity</code>, <code>ExactCapacity</code>, and <code>PercentChangeInCapacity</code>.</p>\" \
            } \
          }, \
          \"documentation\":\"<p> Specifies whether the <a>PutScalingPolicy</a> <code>ScalingAdjustment</code> parameter is an absolute number or a percentage of the current capacity. </p>\" \
        }, \
        \"AdjustmentTypes\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"AdjustmentType\"} \
        }, \
        \"Alarm\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AlarmName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>The name of the alarm.</p>\" \
            }, \
            \"AlarmARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The Amazon Resource Name (ARN) of the alarm.</p>\" \
            } \
          }, \
          \"documentation\":\"<p>The Alarm data type.</p>\" \
        }, \
        \"Alarms\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"Alarm\"} \
        }, \
        \"AlreadyExistsFault\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"message\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> </p>\" \
            } \
          }, \
          \"error\":{ \
            \"code\":\"AlreadyExists\", \
            \"httpStatusCode\":400, \
            \"senderFault\":true \
          }, \
          \"exception\":true, \
          \"documentation\":\"<p> The named Auto Scaling group or launch configuration already exists. </p>\" \
        }, \
        \"AsciiStringMaxLen255\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":255, \
          \"pattern\":\"[A-Za-z0-9\\\\-_\\\\/]+\" \
        }, \
        \"AssociatePublicIpAddress\":{\"type\":\"boolean\"}, \
        \"AttachInstancesQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"InstanceIds\":{ \
              \"shape\":\"InstanceIds\", \
              \"documentation\":\"<p> One or more IDs of the Amazon EC2 instances to attach to the specified Auto Scaling group. You must specify at least one instance ID. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group to which to attach the specified instance(s). </p>\" \
            } \
          } \
        }, \
        \"AutoScalingGroup\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"LaunchConfigurationName\", \
            \"MinSize\", \
            \"MaxSize\", \
            \"DesiredCapacity\", \
            \"DefaultCooldown\", \
            \"AvailabilityZones\", \
            \"HealthCheckType\", \
            \"CreatedTime\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies the name of the group. </p>\" \
            }, \
            \"AutoScalingGroupARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The Amazon Resource Name (ARN) of the Auto Scaling group. </p>\" \
            }, \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies the name of the associated <a>LaunchConfiguration</a>. </p>\" \
            }, \
            \"MinSize\":{ \
              \"shape\":\"AutoScalingGroupMinSize\", \
              \"documentation\":\"<p> Contains the minimum size of the Auto Scaling group. </p>\" \
            }, \
            \"MaxSize\":{ \
              \"shape\":\"AutoScalingGroupMaxSize\", \
              \"documentation\":\"<p> Contains the maximum size of the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> Specifies the desired capacity for the Auto Scaling group. </p>\" \
            }, \
            \"DefaultCooldown\":{ \
              \"shape\":\"Cooldown\", \
              \"documentation\":\"<p> The number of seconds after a scaling activity completes before any further scaling activities can start. </p>\" \
            }, \
            \"AvailabilityZones\":{ \
              \"shape\":\"AvailabilityZones\", \
              \"documentation\":\"<p> Contains a list of Availability Zones for the group. </p>\" \
            }, \
            \"LoadBalancerNames\":{ \
              \"shape\":\"LoadBalancerNames\", \
              \"documentation\":\"<p> A list of load balancers associated with this Auto Scaling group. </p>\" \
            }, \
            \"HealthCheckType\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The service of interest for the health status check, either \\\"EC2\\\" for Amazon EC2 or \\\"ELB\\\" for Elastic Load Balancing. </p>\" \
            }, \
            \"HealthCheckGracePeriod\":{ \
              \"shape\":\"HealthCheckGracePeriod\", \
              \"documentation\":\"<p> The length of time that Auto Scaling waits before checking an instance's health status. The grace period begins when an instance comes into service. </p>\" \
            }, \
            \"Instances\":{ \
              \"shape\":\"Instances\", \
              \"documentation\":\"<p> Provides a summary list of Amazon EC2 instances. </p>\" \
            }, \
            \"CreatedTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> Specifies the date and time the Auto Scaling group was created. </p>\" \
            }, \
            \"SuspendedProcesses\":{ \
              \"shape\":\"SuspendedProcesses\", \
              \"documentation\":\"<p> Suspended processes associated with this Auto Scaling group. </p>\" \
            }, \
            \"PlacementGroup\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the cluster placement group, if applicable. For more information, go to <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using_cluster_computing.html\\\"> Using Cluster Instances</a> in the Amazon EC2 User Guide. </p>\" \
            }, \
            \"VPCZoneIdentifier\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The subnet identifier for the Amazon VPC connection, if applicable. You can specify several subnets in a comma-separated list. </p> <p> When you specify <code>VPCZoneIdentifier</code> with <code>AvailabilityZones</code>, ensure that the subnets' Availability Zones match the values you specify for <code>AvailabilityZones</code>. </p>\" \
            }, \
            \"EnabledMetrics\":{ \
              \"shape\":\"EnabledMetrics\", \
              \"documentation\":\"<p> A list of metrics enabled for this Auto Scaling group. </p>\" \
            }, \
            \"Status\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The current state of the Auto Scaling group when a <a>DeleteAutoScalingGroup</a> action is in progress. </p>\" \
            }, \
            \"Tags\":{ \
              \"shape\":\"TagDescriptionList\", \
              \"documentation\":\"<p> A list of tags for the Auto Scaling group. </p>\" \
            }, \
            \"TerminationPolicies\":{ \
              \"shape\":\"TerminationPolicies\", \
              \"documentation\":\"<p> A standalone termination policy or a list of termination policies for this Auto Scaling group. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The AutoScalingGroup data type. </p>\" \
        }, \
        \"AutoScalingGroupDesiredCapacity\":{\"type\":\"integer\"}, \
        \"AutoScalingGroupMaxSize\":{\"type\":\"integer\"}, \
        \"AutoScalingGroupMinSize\":{\"type\":\"integer\"}, \
        \"AutoScalingGroupNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ResourceName\"} \
        }, \
        \"AutoScalingGroupNamesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupNames\":{ \
              \"shape\":\"AutoScalingGroupNames\", \
              \"documentation\":\"<p> A list of Auto Scaling group names. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of records to return. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>AutoScalingGroupNamesType</code> data type. </p>\" \
        }, \
        \"AutoScalingGroups\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"AutoScalingGroup\"} \
        }, \
        \"AutoScalingGroupsType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroups\"], \
          \"members\":{ \
            \"AutoScalingGroups\":{ \
              \"shape\":\"AutoScalingGroups\", \
              \"documentation\":\"<p> A list of Auto Scaling groups. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>AutoScalingGroupsType</code> data type. </p>\" \
        }, \
        \"AutoScalingInstanceDetails\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"InstanceId\", \
            \"AutoScalingGroupName\", \
            \"AvailabilityZone\", \
            \"LifecycleState\", \
            \"HealthStatus\", \
            \"LaunchConfigurationName\" \
          ], \
          \"members\":{ \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> The instance ID of the Amazon EC2 instance. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Auto Scaling group associated with this instance. </p>\" \
            }, \
            \"AvailabilityZone\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The Availability Zone in which this instance resides. </p>\" \
            }, \
            \"LifecycleState\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The life cycle state of this instance. for more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#instance-lifecycle\\\">Instance Lifecycle State</a> in the <i>Auto Scaling Developer Guide</i>. </p>\" \
            }, \
            \"HealthStatus\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The health status of this instance. \\\"Healthy\\\" means that the instance is healthy and should remain in service. \\\"Unhealthy\\\" means that the instance is unhealthy. Auto Scaling should terminate and replace it. </p>\" \
            }, \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The launch configuration associated with this instance. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>AutoScalingInstanceDetails</code> data type. </p>\" \
        }, \
        \"AutoScalingInstances\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"AutoScalingInstanceDetails\"} \
        }, \
        \"AutoScalingInstancesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingInstances\":{ \
              \"shape\":\"AutoScalingInstances\", \
              \"documentation\":\"<p> A list of Auto Scaling instances. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>AutoScalingInstancesType</code> data type. </p>\" \
        }, \
        \"AutoScalingNotificationTypes\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen255\"} \
        }, \
        \"AvailabilityZones\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen255\"}, \
          \"min\":1 \
        }, \
        \"BlockDeviceEbsDeleteOnTermination\":{\"type\":\"boolean\"}, \
        \"BlockDeviceEbsIops\":{ \
          \"type\":\"integer\", \
          \"min\":100, \
          \"max\":4000 \
        }, \
        \"BlockDeviceEbsVolumeSize\":{ \
          \"type\":\"integer\", \
          \"min\":1, \
          \"max\":1024 \
        }, \
        \"BlockDeviceEbsVolumeType\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":255 \
        }, \
        \"BlockDeviceMapping\":{ \
          \"type\":\"structure\", \
          \"required\":[\"DeviceName\"], \
          \"members\":{ \
            \"VirtualName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>The virtual name associated with the device. </p>\" \
            }, \
            \"DeviceName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the device within Amazon EC2 (for example, /dev/sdh or xvdh). </p>\" \
            }, \
            \"Ebs\":{ \
              \"shape\":\"Ebs\", \
              \"documentation\":\"<p> The Elastic Block Storage volume information. </p>\" \
            }, \
            \"NoDevice\":{ \
              \"shape\":\"NoDevice\", \
              \"documentation\":\"<p> Suppresses the device mapping. </p> <note>If <code>NoDevice</code> is set to <code>true</code> for the root device, the instance might fail the EC2 health check. Auto Scaling launches a replacement instance if the instance fails the health check.</note>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>BlockDeviceMapping</code> data type. </p>\" \
        }, \
        \"BlockDeviceMappings\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"BlockDeviceMapping\"} \
        }, \
        \"CompleteLifecycleActionAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
          }, \
          \"documentation\":\"<p>The output of the <a>CompleteLifecycleAction</a>. </p>\" \
        }, \
        \"CompleteLifecycleActionType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"LifecycleHookName\", \
            \"AutoScalingGroupName\", \
            \"LifecycleActionToken\", \
            \"LifecycleActionResult\" \
          ], \
          \"members\":{ \
            \"LifecycleHookName\":{ \
              \"shape\":\"AsciiStringMaxLen255\", \
              \"documentation\":\"<p>The name of the lifecycle hook.</p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group to which the lifecycle hook belongs.</p>\" \
            }, \
            \"LifecycleActionToken\":{ \
              \"shape\":\"LifecycleActionToken\", \
              \"documentation\":\"<p>A universally unique identifier (UUID) that identifies a specific lifecycle action associated with an instance. Auto Scaling sends this token to the notification target you specified when you created the lifecycle hook.</p>\" \
            }, \
            \"LifecycleActionResult\":{ \
              \"shape\":\"LifecycleActionResult\", \
              \"documentation\":\"<p>The action the Auto Scaling group should take. The value for this parameter can be either <code>CONTINUE</code> or <code>ABANDON</code>.</p>\" \
            } \
          } \
        }, \
        \"Cooldown\":{\"type\":\"integer\"}, \
        \"CreateAutoScalingGroupType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"MinSize\", \
            \"MaxSize\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of an existing launch configuration to use to launch new instances. Use this attribute if you want to create an Auto Scaling group using an existing launch configuration instead of an EC2 instance. </p>\" \
            }, \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> The ID of the Amazon EC2 instance you want to use to create the Auto Scaling group. Use this attribute if you want to create an Auto Scaling group using an EC2 instance instead of a launch configuration. </p> <p> When you use an instance to create an Auto Scaling group, a new launch configuration is first created and then associated with the Auto Scaling group. The new launch configuration derives all its attributes from the instance that is used to create the Auto Scaling group, with the exception of <code>BlockDeviceMapping</code>. </p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/create-asg-from-instance.html\\\">Create an Auto Scaling Group Using EC2 Instance</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
            }, \
            \"MinSize\":{ \
              \"shape\":\"AutoScalingGroupMinSize\", \
              \"documentation\":\"<p> The minimum size of the Auto Scaling group. </p>\" \
            }, \
            \"MaxSize\":{ \
              \"shape\":\"AutoScalingGroupMaxSize\", \
              \"documentation\":\"<p> The maximum size of the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> The number of Amazon EC2 instances that should be running in the group. The desired capacity must be greater than or equal to the minimum size and less than or equal to the maximum size specified for the Auto Scaling group. </p>\" \
            }, \
            \"DefaultCooldown\":{ \
              \"shape\":\"Cooldown\", \
              \"documentation\":\"<p> The amount of time, in seconds, between a successful scaling activity and the succeeding scaling activity.</p> <p>If a <code>DefaultCooldown</code> period is not specified, Auto Scaling uses the default value of 300 as the default cool down period for the Auto Scaling group. For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#Cooldown\\\">Cooldown Period</a> </p>\" \
            }, \
            \"AvailabilityZones\":{ \
              \"shape\":\"AvailabilityZones\", \
              \"documentation\":\"<p> A list of Availability Zones for the Auto Scaling group. This is required unless you have specified subnets. </p>\" \
            }, \
            \"LoadBalancerNames\":{ \
              \"shape\":\"LoadBalancerNames\", \
              \"documentation\":\"<p> A list of existing Elastic Load Balancing load balancers to use. The load balancers must be associated with the AWS account. </p> <p>For information on using load balancers, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/US_SetUpASLBApp.html\\\">Load Balance Your Auto Scaling Group</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
            }, \
            \"HealthCheckType\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p>The service you want the health checks from, Amazon EC2 or Elastic Load Balancer. Valid values are <code>EC2</code> or <code>ELB</code>.</p> <p>By default, the Auto Scaling health check uses the results of Amazon EC2 instance status checks to determine the health of an instance. For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#healthcheck\\\">Health Check</a>.</p>\" \
            }, \
            \"HealthCheckGracePeriod\":{ \
              \"shape\":\"HealthCheckGracePeriod\", \
              \"documentation\":\"<p>Length of time in seconds after a new Amazon EC2 instance comes into service that Auto Scaling starts checking its health. During this time any health check failure for the that instance is ignored.</p> <p>This is required if you are adding <code>ELB</code> health check. Frequently, new instances need to warm up, briefly, before they can pass a health check. To provide ample warm-up time, set the health check grace period of the group to match the expected startup period of your application.</p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/as-add-elb-healthcheck.html#as-add-elb-healthcheck-api\\\">Add an Elastic Load Balancing Health Check</a>.</p>\" \
            }, \
            \"PlacementGroup\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>Physical location of an existing cluster placement group into which you want to launch your instances. For information about cluster placement group, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using_cluster_computing.html\\\">Using Cluster Instances</a></p>\" \
            }, \
            \"VPCZoneIdentifier\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>A comma-separated list of subnet identifiers of Amazon Virtual Private Clouds (Amazon VPCs).</p> <p>If you specify subnets and Availability Zones with this call, ensure that the subnets' Availability Zones match the Availability Zones specified. </p> <p>For information on launching your Auto Scaling group into Amazon VPC subnets, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/autoscalingsubnets.html\\\">Auto Scaling in Amazon Virtual Private Cloud</a> in the <i>Auto Scaling Developer Guide</i> .</p>\" \
            }, \
            \"TerminationPolicies\":{ \
              \"shape\":\"TerminationPolicies\", \
              \"documentation\":\"<p>A standalone termination policy or a list of termination policies used to select the instance to terminate. The policies are executed in the order that they are listed. </p> <p> For more information on configuring a termination policy for your Auto Scaling group, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/us-termination-policy.html\\\">Instance Termination Policy for Your Auto Scaling Group</a> in the <i>Auto Scaling Developer Guide</i>. </p>\" \
            }, \
            \"Tags\":{ \
              \"shape\":\"Tags\", \
              \"documentation\":\"<p> The tag to be created or updated. Each tag should be defined by its resource type, resource ID, key, value, and a propagate flag. Valid values: key=<i>value</i>, value=<i>value</i>, propagate=<i>true</i> or <i>false</i>. Value and propagate are optional parameters.</p> <p>For information about using tags, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/ASTagging.html\\\">Tag Your Auto Scaling Groups and Amazon EC2 Instances</a> in the <i>Auto Scaling Developer Guide</i>. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"CreateLaunchConfigurationType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"LaunchConfigurationName\"], \
          \"members\":{ \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the launch configuration to create. </p>\" \
            }, \
            \"ImageId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Unique ID of the Amazon Machine Image (AMI) you want to use to launch your EC2 instances. For information about finding Amazon EC2 AMIs, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html\\\">Finding a Suitable AMI</a> in the <i>Amazon Elastic Compute Cloud User Guide</i>.</p>\" \
            }, \
            \"KeyName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Amazon EC2 key pair. For more information, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/generating-a-keypair.html\\\">Getting a Key Pair</a> in the <i>Amazon Elastic Compute Cloud User Guide</i>. </p>\" \
            }, \
            \"SecurityGroups\":{ \
              \"shape\":\"SecurityGroups\", \
              \"documentation\":\"<p> The security groups with which to associate Amazon EC2 or Amazon VPC instances.</p> <p>If your instances are launched in EC2, you can either specify Amazon EC2 security group names or the security group IDs. For more information about Amazon EC2 security groups, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/index.html?using-network-security.html\\\"> Using Security Groups</a> in the <i>Amazon Elastic Compute Cloud User Guide</i>.</p> <p>If your instances are launched within VPC, specify Amazon VPC security group IDs. For more information about Amazon VPC security groups, see <a href=\\\"http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/index.html?VPC_SecurityGroups.html\\\">Security Groups</a> in the <i>Amazon Virtual Private Cloud User Guide</i>. </p>\" \
            }, \
            \"UserData\":{ \
              \"shape\":\"XmlStringUserData\", \
              \"documentation\":\"<p> The user data to make available to the launched Amazon EC2 instances. For more information about Amazon EC2 user data, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html#instancedata-user-data-retrieval\\\">User Data Retrieval</a> in the <i>Amazon Elastic Compute Cloud User Guide</i>. </p> <note> At this time, Auto Scaling launch configurations don't support compressed (e.g. zipped) user data files. </note>\" \
            }, \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> The ID of the Amazon EC2 instance you want to use to create the launch configuration. Use this attribute if you want the launch configuration to derive its attributes from an EC2 instance. </p> <p> When you use an instance to create a launch configuration, all you need to specify is the <code>InstanceId</code>. The new launch configuration, by default, derives all the attributes from the specified instance with the exception of <code>BlockDeviceMapping</code>. </p> <p>If you want to create a launch configuration with <code>BlockDeviceMapping</code> or override any other instance attributes, specify them as part of the same request.</p> <p>For more information on using an InstanceID to create a launch configuration, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/create-lc-with-instanceID.html\\\">Create a Launch Configuration Using an Amazon EC2 Instance</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
            }, \
            \"InstanceType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The instance type of the Amazon EC2 instance. For information about available Amazon EC2 instance types, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes\\\"> Available Instance Types</a> in the <i>Amazon Elastic Cloud Compute User Guide.</i> </p>\" \
            }, \
            \"KernelId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The ID of the kernel associated with the Amazon EC2 AMI. </p>\" \
            }, \
            \"RamdiskId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The ID of the RAM disk associated with the Amazon EC2 AMI. </p>\" \
            }, \
            \"BlockDeviceMappings\":{ \
              \"shape\":\"BlockDeviceMappings\", \
              \"documentation\":\"<p> A list of mappings that specify how block devices are exposed to the instance. Each mapping is made up of a <i>VirtualName</i>, a <i>DeviceName</i>, and an <i>ebs</i> data structure that contains information about the associated Elastic Block Storage volume. For more information about Amazon EC2 BlockDeviceMappings, go to <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/index.html?block-device-mapping-concepts.html\\\"> Block Device Mapping</a> in the Amazon EC2 product documentation. </p>\" \
            }, \
            \"InstanceMonitoring\":{ \
              \"shape\":\"InstanceMonitoring\", \
              \"documentation\":\"<p>Enables detailed monitoring if it is disabled. Detailed monitoring is enabled by default.</p> <p> When detailed monitoring is enabled, Amazon Cloudwatch will generate metrics every minute and your account will be charged a fee. When you disable detailed monitoring, by specifying <code>False</code>, Cloudwatch will generate metrics every 5 minutes. For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/as-instance-monitoring.html\\\">Monitor Your Auto Scaling Instances</a>. For information about Amazon CloudWatch, see the <a href=\\\"http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/Welcome.html\\\">Amazon CloudWatch Developer Guide</a>. </p>\" \
            }, \
            \"SpotPrice\":{ \
              \"shape\":\"SpotPrice\", \
              \"documentation\":\"<p>The maximum hourly price to be paid for any Spot Instance launched to fulfill the request. Spot Instances are launched when the price you specify exceeds the current Spot market price. For more information on launching Spot Instances, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/US-SpotInstances.html\\\"> Using Auto Scaling to Launch Spot Instances</a> in the <i>Auto Scaling Developer Guide</i>. </p>\" \
            }, \
            \"IamInstanceProfile\":{ \
              \"shape\":\"XmlStringMaxLen1600\", \
              \"documentation\":\"<p>The name or the Amazon Resource Name (ARN) of the instance profile associated with the IAM role for the instance.</p> <p>Amazon EC2 instances launched with an IAM role will automatically have AWS security credentials available. You can use IAM roles with Auto Scaling to automatically enable applications running on your Amazon EC2 instances to securely access other AWS resources. For information on launching EC2 instances with an IAM role, go to <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/us-iam-role.html\\\">Launching Auto Scaling Instances With an IAM Role</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
            }, \
            \"EbsOptimized\":{ \
              \"shape\":\"EbsOptimized\", \
              \"documentation\":\"<p> Whether the instance is optimized for EBS I/O. The optimization provides dedicated throughput to Amazon EBS and an optimized configuration stack to provide optimal EBS I/O performance. This optimization is not available with all instance types. Additional usage charges apply when using an EBS Optimized instance. By default the instance is not optimized for EBS I/O. For information about EBS-optimized instances, go to <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#EBSOptimized\\\">EBS-Optimized Instances</a> in the <i>Amazon Elastic Compute Cloud User Guide</i>. </p>\" \
            }, \
            \"AssociatePublicIpAddress\":{ \
              \"shape\":\"AssociatePublicIpAddress\", \
              \"documentation\":\"<p>Used for Auto Scaling groups that launch instances into an Amazon Virtual Private Cloud (Amazon VPC). Specifies whether to assign a public IP address to each instance launched in a Amazon VPC. For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/autoscalingsubnets.html\\\">Auto Scaling in Amazon Virtual Private Cloud</a>.</p> <note> <p>If you specify a value for this parameter, be sure to specify at least one VPC subnet using the <i>VPCZoneIdentifier</i> parameter when you create your Auto Scaling group. </p> </note> <p>Default: If the instance is launched into a default subnet in a default VPC, the default is <code>true</code>. If the instance is launched into a nondefault subnet in a VPC, the default is <code>false</code>. For information about default VPC and VPC platforms, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide//as-supported-platforms.html\\\">Supported Platforms</a>.</p>\" \
            }, \
            \"PlacementTenancy\":{ \
              \"shape\":\"XmlStringMaxLen64\", \
              \"documentation\":\"<p>The tenancy of the instance. An instance with a tenancy of <code>dedicated</code> runs on single-tenant hardware and can only be launched in a VPC.</p> <p>You must set the value of this parameter to <code>dedicated</code> if want to launch Dedicated Instances in a shared tenancy VPC (VPC with instance placement tenancy attribute set to <code>default</code>).</p> <p>If you specify a value for this parameter, be sure to specify at least one VPC subnet using the <i>VPCZoneIdentifier</i> parameter when you create your Auto Scaling group. </p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/autoscalingsubnets.html\\\">Auto Scaling in Amazon Virtual Private Cloud</a> in the <i>Auto Scaling Developer Guide</i>. </p> <p>Valid values: <code>default</code> | <code>dedicated</code></p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"CreateOrUpdateTagsType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"Tags\"], \
          \"members\":{ \
            \"Tags\":{ \
              \"shape\":\"Tags\", \
              \"documentation\":\"<p> The tag to be created or updated. Each tag should be defined by its resource type, resource ID, key, value, and a propagate flag. The resource type and resource ID identify the type and name of resource for which the tag is created. Currently, <code>auto-scaling-group</code> is the only supported resource type. The valid value for the resource ID is <i>groupname</i>. </p> <p>The <code>PropagateAtLaunch</code> flag defines whether the new tag will be applied to instances launched by the Auto Scaling group. Valid values are <code>true</code> or <code>false</code>. However, instances that are already running will not get the new or updated tag. Likewise, when you modify a tag, the updated version will be applied only to new instances launched by the Auto Scaling group after the change. Running instances that had the previous version of the tag will continue to have the older tag. </p> <p>When you create a tag and a tag of the same name already exists, the operation overwrites the previous tag definition, but you will not get an error message. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"DeleteAutoScalingGroupType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group to delete. </p>\" \
            }, \
            \"ForceDelete\":{ \
              \"shape\":\"ForceDelete\", \
              \"documentation\":\"<p>Starting with API version 2011-01-01, specifies that the Auto Scaling group will be deleted along with all instances associated with the group, without waiting for all instances to be terminated. This parameter also deletes any lifecycle actions associated with the group. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"DeleteLifecycleHookAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
          }, \
          \"documentation\":\"<p>The output of the <a>DeleteLifecycleHook</a> action. </p>\" \
        }, \
        \"DeleteLifecycleHookType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"LifecycleHookName\", \
            \"AutoScalingGroupName\" \
          ], \
          \"members\":{ \
            \"LifecycleHookName\":{ \
              \"shape\":\"AsciiStringMaxLen255\", \
              \"documentation\":\"<p>The name of the lifecycle hook.</p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group to which the lifecycle hook belongs.</p>\" \
            } \
          } \
        }, \
        \"DeleteNotificationConfigurationType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"TopicARN\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group.</p>\" \
            }, \
            \"TopicARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The Amazon Resource Name (ARN) of the Amazon Simple Notification Service (SNS) topic.</p>\" \
            } \
          }, \
          \"documentation\":\"<p></p>\" \
        }, \
        \"DeletePolicyType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"PolicyName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group.</p>\" \
            }, \
            \"PolicyName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name or PolicyARN of the policy you want to delete.</p>\" \
            } \
          }, \
          \"documentation\":\"<p></p>\" \
        }, \
        \"DeleteScheduledActionType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"ScheduledActionName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group.</p>\" \
            }, \
            \"ScheduledActionName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the action you want to delete.</p>\" \
            } \
          }, \
          \"documentation\":\"<p></p>\" \
        }, \
        \"DeleteTagsType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"Tags\"], \
          \"members\":{ \
            \"Tags\":{ \
              \"shape\":\"Tags\", \
              \"documentation\":\"<p>Each tag should be defined by its resource type, resource ID, key, value, and a propagate flag. Valid values are: Resource type = <i>auto-scaling-group</i>, Resource ID = <i>AutoScalingGroupName</i>, key=<i>value</i>, value=<i>value</i>, propagate=<i>true</i> or <i>false</i>. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"DescribeAccountLimitsAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"MaxNumberOfAutoScalingGroups\":{ \
              \"shape\":\"MaxNumberOfAutoScalingGroups\", \
              \"documentation\":\"<p> The maximum number of Auto Scaling groups allowed for your AWS account. </p>\" \
            }, \
            \"MaxNumberOfLaunchConfigurations\":{ \
              \"shape\":\"MaxNumberOfLaunchConfigurations\", \
              \"documentation\":\"<p> The maximum number of launch configurations allowed for your AWS account. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The output of the <a>DescribeAccountLimitsResult</a> action. </p>\" \
        }, \
        \"DescribeAdjustmentTypesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AdjustmentTypes\":{ \
              \"shape\":\"AdjustmentTypes\", \
              \"documentation\":\"<p> A list of specific policy adjustment types. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The output of the <a>DescribeAdjustmentTypes</a> action. </p>\" \
        }, \
        \"DescribeAutoScalingInstancesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"InstanceIds\":{ \
              \"shape\":\"InstanceIds\", \
              \"documentation\":\"<p> The list of Auto Scaling instances to describe. If this list is omitted, all auto scaling instances are described. The list of requested instances cannot contain more than 50 items. If unknown instances are requested, they are ignored with no error. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of Auto Scaling instances to be described with each call. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The token returned by a previous call to indicate that there is more data available. </p>\" \
            } \
          } \
        }, \
        \"DescribeAutoScalingNotificationTypesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingNotificationTypes\":{ \
              \"shape\":\"AutoScalingNotificationTypes\", \
              \"documentation\":\"<p>Returns a list of all notification types supported by Auto Scaling. They are:</p> <ul> <li><p><code>autoscaling:EC2_INSTANCE_LAUNCH</code></p></li> <li><p><code>autoscaling:EC2_INSTANCE_LAUNCH_ERROR</code></p></li> <li><p><code>autoscaling:EC2_INSTANCE_TERMINATE</code></p></li> <li><p><code>autoscaling:EC2_INSTANCE_TERMINATE_ERROR</code></p></li> <li><p><code>autoscaling:TEST_NOTIFICATION</code></p></li> </ul>\" \
            } \
          }, \
          \"documentation\":\"<p>The <code>AutoScalingNotificationTypes</code> data type.</p>\" \
        }, \
        \"DescribeLifecycleHookTypesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"LifecycleHookTypes\":{ \
              \"shape\":\"AutoScalingNotificationTypes\", \
              \"documentation\":\"<p>Returns a list of all notification types supported by Auto Scaling. They are:</p> <ul> <li><p><code>autoscaling:EC2_INSTANCE_LAUNCHING</code></p></li> <li><p><code>autoscaling:EC2_INSTANCE_TERMINATING</code></p></li> </ul>\" \
            } \
          } \
        }, \
        \"DescribeLifecycleHooksAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"LifecycleHooks\":{ \
              \"shape\":\"LifecycleHooks\", \
              \"documentation\":\"<p> A list describing the lifecycle hooks that belong to the specified Auto Scaling group. </p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>DescribeLifecycleHooks</a> action. </p>\" \
        }, \
        \"DescribeLifecycleHooksType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of one or more Auto Scaling groups.</p>\" \
            }, \
            \"LifecycleHookNames\":{ \
              \"shape\":\"LifecycleHookNames\", \
              \"documentation\":\"<p>The name of one or more lifecycle hooks.</p>\" \
            } \
          } \
        }, \
        \"DescribeMetricCollectionTypesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Metrics\":{ \
              \"shape\":\"MetricCollectionTypes\", \
              \"documentation\":\"<p>The list of Metrics collected. The following metrics are supported: </p> <ul> <li><p>GroupMinSize</p></li> <li><p>GroupMaxSize</p></li> <li><p>GroupDesiredCapacity</p></li> <li><p>GroupInServiceInstances</p></li> <li><p>GroupPendingInstances</p></li> <li><p>GroupStandbyInstances</p></li> <li><p>GroupTerminatingInstances</p></li> <li><p>GroupTotalInstances</p></li> </ul> <note> <p>The <code>GroupStandbyInstances</code> metric is not returned by default. You must explicitly request it when calling <a>EnableMetricsCollection</a>.</p> </note>\" \
            }, \
            \"Granularities\":{ \
              \"shape\":\"MetricGranularityTypes\", \
              \"documentation\":\"<p>A list of granularities for the listed Metrics.</p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>DescribeMetricCollectionTypes</a> action.</p>\" \
        }, \
        \"DescribeNotificationConfigurationsAnswer\":{ \
          \"type\":\"structure\", \
          \"required\":[\"NotificationConfigurations\"], \
          \"members\":{ \
            \"NotificationConfigurations\":{ \
              \"shape\":\"NotificationConfigurations\", \
              \"documentation\":\"<p>The list of notification configurations.</p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p>A string that is used to mark the start of the next batch of returned results for pagination.</p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>DescribeNotificationConfigurations</a> action.</p>\" \
        }, \
        \"DescribeNotificationConfigurationsType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupNames\":{ \
              \"shape\":\"AutoScalingGroupNames\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that is used to mark the start of the next batch of returned results for pagination. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p>Maximum number of records to be returned. </p>\" \
            } \
          } \
        }, \
        \"DescribePoliciesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"PolicyNames\":{ \
              \"shape\":\"PolicyNames\", \
              \"documentation\":\"<p> A list of policy names or policy ARNs to be described. If this list is omitted, all policy names are described. If an auto scaling group name is provided, the results are limited to that group. The list of requested policy names cannot contain more than 50 items. If unknown policy names are requested, they are ignored with no error. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that is used to mark the start of the next batch of returned results for pagination. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of policies that will be described with each call. </p>\" \
            } \
          } \
        }, \
        \"DescribeScalingActivitiesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"ActivityIds\":{ \
              \"shape\":\"ActivityIds\", \
              \"documentation\":\"<p> A list containing the activity IDs of the desired scaling activities. If this list is omitted, all activities are described. If an <code>AutoScalingGroupName</code> is provided, the results are limited to that group. The list of requested activities cannot contain more than 50 items. If unknown activities are requested, they are ignored with no error. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the <a>AutoScalingGroup</a>. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of scaling activities to return. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results for pagination. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"DescribeScheduledActionsType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"ScheduledActionNames\":{ \
              \"shape\":\"ScheduledActionNames\", \
              \"documentation\":\"<p> A list of scheduled actions to be described. If this list is omitted, all scheduled actions are described. The list of requested scheduled actions cannot contain more than 50 items. If an auto scaling group name is provided, the results are limited to that group. If unknown scheduled actions are requested, they are ignored with no error. </p>\" \
            }, \
            \"StartTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> The earliest scheduled start time to return. If scheduled action names are provided, this field will be ignored. </p>\" \
            }, \
            \"EndTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> The latest scheduled start time to return. If scheduled action names are provided, this field is ignored. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of scheduled actions to return. </p>\" \
            } \
          } \
        }, \
        \"DescribeTagsType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Filters\":{ \
              \"shape\":\"Filters\", \
              \"documentation\":\"<p> The value of the filter type used to identify the tags to be returned. For example, you can filter so that tags are returned according to Auto Scaling group, the key and value, or whether the new tag will be applied to instances launched after the tag is created (PropagateAtLaunch). </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of records to return. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"DescribeTerminationPolicyTypesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"TerminationPolicyTypes\":{ \
              \"shape\":\"TerminationPolicies\", \
              \"documentation\":\"<p> Termination policies supported by Auto Scaling. They are: <code>OldestInstance</code>, <code>OldestLaunchConfiguration</code>, <code>NewestInstance</code>, <code>ClosestToNextInstanceHour</code>, <code>Default</code> </p>\" \
            } \
          }, \
          \"documentation\":\"<p>The <code>TerminationPolicyTypes</code> data type.</p>\" \
        }, \
        \"DetachInstancesAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Activities\":{ \
              \"shape\":\"Activities\", \
              \"documentation\":\"<p> A list describing the activities related to detaching the instances from the Auto Scaling group. </p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>DetachInstances</a> action. </p>\" \
        }, \
        \"DetachInstancesQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"ShouldDecrementDesiredCapacity\" \
          ], \
          \"members\":{ \
            \"InstanceIds\":{ \
              \"shape\":\"InstanceIds\", \
              \"documentation\":\"<p> A list of instances to detach from the Auto Scaling group. You must specify at least one instance ID. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group from which to detach instances. </p>\" \
            }, \
            \"ShouldDecrementDesiredCapacity\":{ \
              \"shape\":\"ShouldDecrementDesiredCapacity\", \
              \"documentation\":\"<p> Specifies if the detached instance should decrement the desired capacity value for the Auto Scaling group. If set to <code>True</code>, the Auto Scaling group decrements the desired capacity value by the number of instances detached. </p>\" \
            } \
          } \
        }, \
        \"DisableMetricsCollectionQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name or ARN of the Auto Scaling Group. </p>\" \
            }, \
            \"Metrics\":{ \
              \"shape\":\"Metrics\", \
              \"documentation\":\"<p> The list of metrics to disable. If no metrics are specified, all metrics are disabled. The following metrics are supported: </p> <ul> <li><p>GroupMinSize</p></li> <li><p>GroupMaxSize</p></li> <li><p>GroupDesiredCapacity</p></li> <li><p>GroupInServiceInstances</p></li> <li><p>GroupPendingInstances</p></li> <li><p>GroupStandbyInstances</p></li> <li><p>GroupTerminatingInstances</p></li> <li><p>GroupTotalInstances</p></li> </ul>\" \
            } \
          } \
        }, \
        \"Ebs\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"SnapshotId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The snapshot ID. </p>\" \
            }, \
            \"VolumeSize\":{ \
              \"shape\":\"BlockDeviceEbsVolumeSize\", \
              \"documentation\":\"<p>The volume size, in gigabytes.</p> <p>Valid values: If the volume type is <code>io1</code>, the minimum size of the volume is 10.</p> <p>Default: If you're creating the volume from a snapshot, and you don't specify a volume size, the default is the snapshot size.</p> <p>Required: Required when the volume type is <code>io1</code>. </p>\" \
            }, \
            \"VolumeType\":{ \
              \"shape\":\"BlockDeviceEbsVolumeType\", \
              \"documentation\":\"<p>The volume type.</p> <p>Valid values: <code>standard | io1</code></p> <p>Default: <code>standard</code></p>\" \
            }, \
            \"DeleteOnTermination\":{ \
              \"shape\":\"BlockDeviceEbsDeleteOnTermination\", \
              \"documentation\":\"<p>Indicates whether to delete the volume on instance termination. </p> <p>Default: <code>true</code> </p>\" \
            }, \
            \"Iops\":{ \
              \"shape\":\"BlockDeviceEbsIops\", \
              \"documentation\":\"<p>The number of I/O operations per second (IOPS) that the volume supports.</p> <p>The maximum ratio of IOPS to volume size is 30.0</p> <p>Valid Values: Range is 100 to 4000.</p> <p>Default: None.</p>\" \
            } \
          }, \
          \"documentation\":\"<p>The Ebs data type.</p>\" \
        }, \
        \"EbsOptimized\":{\"type\":\"boolean\"}, \
        \"EnableMetricsCollectionQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"Granularity\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name or ARN of the Auto Scaling group.</p>\" \
            }, \
            \"Metrics\":{ \
              \"shape\":\"Metrics\", \
              \"documentation\":\"<p> The list of metrics to collect. If no metrics are specified, all metrics are enabled. The following metrics are supported: </p> <ul> <li><p>GroupMinSize</p></li> <li><p>GroupMaxSize</p></li> <li><p>GroupDesiredCapacity</p></li> <li><p>GroupInServiceInstances</p></li> <li><p>GroupPendingInstances</p></li> <li><p>GroupStandbyInstances</p></li> <li><p>GroupTerminatingInstances</p></li> <li><p>GroupTotalInstances</p></li> </ul> <note> <p>The <code>GroupStandbyInstances</code> metric is not returned by default. You must explicitly request it when calling <a>EnableMetricsCollection</a>.</p> </note>\" \
            }, \
            \"Granularity\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The granularity to associate with the metrics to collect. Currently, the only legal granularity is \\\"1Minute\\\". </p>\" \
            } \
          } \
        }, \
        \"EnabledMetric\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Metric\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the enabled metric. </p>\" \
            }, \
            \"Granularity\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The granularity of the enabled metric. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>EnabledMetric</code> data type. </p>\" \
        }, \
        \"EnabledMetrics\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"EnabledMetric\"} \
        }, \
        \"EnterStandbyAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Activities\":{ \
              \"shape\":\"Activities\", \
              \"documentation\":\"<p> A list describing the activities related to moving instances into Standby mode. </p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>EnterStandby</a> action. </p>\" \
        }, \
        \"EnterStandbyQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"ShouldDecrementDesiredCapacity\" \
          ], \
          \"members\":{ \
            \"InstanceIds\":{ \
              \"shape\":\"InstanceIds\", \
              \"documentation\":\"<p> The instances to move into Standby mode. You must specify at least one instance ID. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group from which to move instances into Standby mode. </p>\" \
            }, \
            \"ShouldDecrementDesiredCapacity\":{ \
              \"shape\":\"ShouldDecrementDesiredCapacity\", \
              \"documentation\":\"<p> Specifies whether the instances moved to Standby mode count as part of the Auto Scaling group's desired capacity. If set, the desired capacity for the Auto Scaling group decrements by the number of instances moved to Standby mode. </p>\" \
            } \
          } \
        }, \
        \"ExecutePolicyType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"PolicyName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name or the Amazon Resource Name (ARN) of the Auto Scaling group. </p>\" \
            }, \
            \"PolicyName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name or ARN of the policy you want to run. </p>\" \
            }, \
            \"HonorCooldown\":{ \
              \"shape\":\"HonorCooldown\", \
              \"documentation\":\"<p>Set to <code>True</code> if you want Auto Scaling to wait for the cooldown period associated with the Auto Scaling group to complete before executing the policy.</p> <p>Set to <code>False</code> if you want Auto Scaling to circumvent the cooldown period associated with the Auto Scaling group and execute the policy before the cooldown period ends. </p> <p>For information about cooldown period, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#Cooldown\\\">Cooldown Period</a> in the <i>Auto Scaling Developer Guide</i>.</p>\" \
            } \
          } \
        }, \
        \"ExitStandbyAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Activities\":{ \
              \"shape\":\"Activities\", \
              \"documentation\":\"<p>A list describing the activities related to moving instances out of Standby mode.</p>\" \
            } \
          }, \
          \"documentation\":\"<p>The output of the <a>ExitStandby</a> action. </p>\" \
        }, \
        \"ExitStandbyQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"InstanceIds\":{ \
              \"shape\":\"InstanceIds\", \
              \"documentation\":\"<p> A list of instances to move out of Standby mode. You must specify at least one instance ID. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group from which to move instances out of Standby mode. </p>\" \
            } \
          } \
        }, \
        \"Filter\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Name\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The name of the filter. Valid Name values are: <code>\\\"auto-scaling-group\\\"</code>, <code>\\\"key\\\"</code>, <code>\\\"value\\\"</code>, and <code>\\\"propagate-at-launch\\\"</code>. </p>\" \
            }, \
            \"Values\":{ \
              \"shape\":\"Values\", \
              \"documentation\":\"<p> The value of the filter. </p>\" \
            } \
          }, \
          \"documentation\":\"<p>The <code>Filter</code> data type.</p>\" \
        }, \
        \"Filters\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"Filter\"} \
        }, \
        \"ForceDelete\":{\"type\":\"boolean\"}, \
        \"GlobalTimeout\":{\"type\":\"integer\"}, \
        \"HealthCheckGracePeriod\":{\"type\":\"integer\"}, \
        \"HeartbeatTimeout\":{\"type\":\"integer\"}, \
        \"HonorCooldown\":{\"type\":\"boolean\"}, \
        \"Instance\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"InstanceId\", \
            \"AvailabilityZone\", \
            \"LifecycleState\", \
            \"HealthStatus\", \
            \"LaunchConfigurationName\" \
          ], \
          \"members\":{ \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> Specifies the ID of the Amazon EC2 instance. </p>\" \
            }, \
            \"AvailabilityZone\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Availability Zones associated with this instance. </p>\" \
            }, \
            \"LifecycleState\":{ \
              \"shape\":\"LifecycleState\", \
              \"documentation\":\"<p> Contains a description of the current <i>lifecycle</i> state. </p> <note> <p>The <code>Quarantined</code> lifecycle state is currently not used.</p> </note>\" \
            }, \
            \"HealthStatus\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The instance's health status. </p>\" \
            }, \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The launch configuration associated with this instance. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>Instance</code> data type. </p>\" \
        }, \
        \"InstanceIds\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen16\"} \
        }, \
        \"InstanceMonitoring\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Enabled\":{ \
              \"shape\":\"MonitoringEnabled\", \
              \"documentation\":\"<p> If <code>True</code>, instance monitoring is enabled. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>InstanceMonitoring</code> data type. </p>\" \
        }, \
        \"Instances\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"Instance\"} \
        }, \
        \"InvalidNextToken\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"message\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> </p>\" \
            } \
          }, \
          \"error\":{ \
            \"code\":\"InvalidNextToken\", \
            \"httpStatusCode\":400, \
            \"senderFault\":true \
          }, \
          \"exception\":true, \
          \"documentation\":\"<p> The <code>NextToken</code> value is invalid. </p>\" \
        }, \
        \"LaunchConfiguration\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"LaunchConfigurationName\", \
            \"ImageId\", \
            \"InstanceType\", \
            \"CreatedTime\" \
          ], \
          \"members\":{ \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies the name of the launch configuration. </p>\" \
            }, \
            \"LaunchConfigurationARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The launch configuration's Amazon Resource Name (ARN). </p>\" \
            }, \
            \"ImageId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Provides the unique ID of the <i>Amazon Machine Image</i> (AMI) that was assigned during registration. </p>\" \
            }, \
            \"KeyName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Provides the name of the Amazon EC2 key pair. </p>\" \
            }, \
            \"SecurityGroups\":{ \
              \"shape\":\"SecurityGroups\", \
              \"documentation\":\"<p> A description of the security groups to associate with the Amazon EC2 instances. </p>\" \
            }, \
            \"UserData\":{ \
              \"shape\":\"XmlStringUserData\", \
              \"documentation\":\"<p> The user data available to the launched Amazon EC2 instances. </p>\" \
            }, \
            \"InstanceType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies the instance type of the Amazon EC2 instance. </p>\" \
            }, \
            \"KernelId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Provides the ID of the kernel associated with the Amazon EC2 AMI. </p>\" \
            }, \
            \"RamdiskId\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Provides ID of the RAM disk associated with the Amazon EC2 AMI. </p>\" \
            }, \
            \"BlockDeviceMappings\":{ \
              \"shape\":\"BlockDeviceMappings\", \
              \"documentation\":\"<p> Specifies how block devices are exposed to the instance. Each mapping is made up of a <i>virtualName</i> and a <i>deviceName</i>. </p>\" \
            }, \
            \"InstanceMonitoring\":{ \
              \"shape\":\"InstanceMonitoring\", \
              \"documentation\":\"<p> Controls whether instances in this group are launched with detailed monitoring or not. </p>\" \
            }, \
            \"SpotPrice\":{ \
              \"shape\":\"SpotPrice\", \
              \"documentation\":\"<p>Specifies the price to bid when launching Spot Instances.</p>\" \
            }, \
            \"IamInstanceProfile\":{ \
              \"shape\":\"XmlStringMaxLen1600\", \
              \"documentation\":\"<p>Provides the name or the Amazon Resource Name (ARN) of the instance profile associated with the IAM role for the instance. The instance profile contains the IAM role. </p>\" \
            }, \
            \"CreatedTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> Provides the creation date and time for this launch configuration. </p>\" \
            }, \
            \"EbsOptimized\":{ \
              \"shape\":\"EbsOptimized\", \
              \"documentation\":\"<p>Specifies whether the instance is optimized for EBS I/O (<i>true</i>) or not (<i>false</i>).</p>\" \
            }, \
            \"AssociatePublicIpAddress\":{ \
              \"shape\":\"AssociatePublicIpAddress\", \
              \"documentation\":\"<p>Specifies whether the instance is associated with a public IP address (<code>true</code>) or not (<code>false</code>).</p>\" \
            }, \
            \"PlacementTenancy\":{ \
              \"shape\":\"XmlStringMaxLen64\", \
              \"documentation\":\"<p>Specifies the tenancy of the instance. It can be either <code>default</code> or <code>dedicated</code>. An instance with <code>dedicated</code> tenancy runs in an isolated, single-tenant hardware and it can only be launched in a VPC.</p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>LaunchConfiguration</code> data type. </p>\" \
        }, \
        \"LaunchConfigurationNameType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"LaunchConfigurationName\"], \
          \"members\":{ \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the launch configuration. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"LaunchConfigurationNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ResourceName\"} \
        }, \
        \"LaunchConfigurationNamesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"LaunchConfigurationNames\":{ \
              \"shape\":\"LaunchConfigurationNames\", \
              \"documentation\":\"<p> A list of launch configuration names. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            }, \
            \"MaxRecords\":{ \
              \"shape\":\"MaxRecords\", \
              \"documentation\":\"<p> The maximum number of launch configurations. The default is 100. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>LaunchConfigurationNamesType</code> data type. </p>\" \
        }, \
        \"LaunchConfigurations\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"LaunchConfiguration\"} \
        }, \
        \"LaunchConfigurationsType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"LaunchConfigurations\"], \
          \"members\":{ \
            \"LaunchConfigurations\":{ \
              \"shape\":\"LaunchConfigurations\", \
              \"documentation\":\"<p> A list of launch configurations. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>LaunchConfigurationsType</code> data type. </p>\" \
        }, \
        \"LifecycleActionResult\":{\"type\":\"string\"}, \
        \"LifecycleActionToken\":{ \
          \"type\":\"string\", \
          \"min\":36, \
          \"max\":36 \
        }, \
        \"LifecycleHook\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"LifecycleHookName\":{ \
              \"shape\":\"AsciiStringMaxLen255\", \
              \"documentation\":\"<p> The name of the lifecycle action hook. </p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group to which the lifecycle action belongs. </p>\" \
            }, \
            \"LifecycleTransition\":{ \
              \"shape\":\"LifecycleTransition\", \
              \"documentation\":\"<p>The Amazon EC2 instance state to which you want to attach the lifecycle hook. See <a>DescribeLifecycleHooks</a> for a list of available lifecycle hook types.</p>\" \
            }, \
            \"NotificationTargetARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The ARN of the notification target that Auto Scaling will use to notify you when an instance is in the transition state for the lifecycle hook. This ARN target can be either an SQS queue or an SNS topic. The notification message sent to the target will include:</p> <ul> <li>Lifecycle action token</li> <li>User account ID</li> <li>Name of the Auto Scaling group</li> <li>Lifecycle hook name</li> <li>EC2 instance ID</li> <li>Lifecycle transition</li> <li>Notification metadata</li> </ul>\" \
            }, \
            \"RoleARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The ARN of the Amazon IAM role that allows the Auto Scaling group to publish to the specified notification target.</p>\" \
            }, \
            \"NotificationMetadata\":{ \
              \"shape\":\"XmlStringMaxLen1023\", \
              \"documentation\":\"<p>Contains additional information that you want to include any time Auto Scaling sends a message to the notification target.</p>\" \
            }, \
            \"HeartbeatTimeout\":{ \
              \"shape\":\"HeartbeatTimeout\", \
              \"documentation\":\"<p>Defines the amount of time that can elapse before the lifecycle hook times out. When the lifecycle hook times out, Auto Scaling performs the action defined in the <code>DefaultResult</code> parameter. You can prevent the lifecycle hook from timing out by calling <a>RecordLifecycleActionHeartbeat</a>.</p>\" \
            }, \
            \"GlobalTimeout\":{ \
              \"shape\":\"GlobalTimeout\", \
              \"documentation\":\"<p>The maximum length of time an instance can remain in a <code>Pending:Wait</code> or <code>Terminating:Wait</code> state. Currently, this value is set at 48 hours.</p>\" \
            }, \
            \"DefaultResult\":{ \
              \"shape\":\"LifecycleActionResult\", \
              \"documentation\":\"<p>Defines the action the Auto Scaling group should take when the lifecycle hook timeout elapses or if an unexpected failure occurs. The value for this parameter can be either <code>CONTINUE</code> or <code>ABANDON</code>. The default value for this parameter is <code>CONTINUE</code>.</p>\" \
            } \
          }, \
          \"documentation\":\"<p> A lifecycle hook tells Auto Scaling that you want to perform an action when an instance launches or terminates. When you have a lifecycle hook in place, the Auto Scaling group will either: </p> <ul> <li> Pause the instance after it launches, but before it is put into service </li> <li> Pause the instance as it terminates, but before it is fully terminated </li> </ul> <p>To learn more, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingPendingState.html\\\">Auto Scaling Pending State</a> and <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingTerminatingState.html\\\">Auto Scaling Terminating State</a>.</p>\" \
        }, \
        \"LifecycleHookNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"AsciiStringMaxLen255\"} \
        }, \
        \"LifecycleHooks\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"LifecycleHook\"} \
        }, \
        \"LifecycleState\":{ \
          \"type\":\"string\", \
          \"enum\":[ \
            \"Pending\", \
            \"Pending:Wait\", \
            \"Pending:Proceed\", \
            \"Quarantined\", \
            \"InService\", \
            \"Terminating\", \
            \"Terminating:Wait\", \
            \"Terminating:Proceed\", \
            \"Terminated\", \
            \"Detaching\", \
            \"Detached\", \
            \"EnteringStandby\", \
            \"Standby\" \
          ] \
        }, \
        \"LifecycleTransition\":{\"type\":\"string\"}, \
        \"LimitExceededFault\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"message\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> </p>\" \
            } \
          }, \
          \"error\":{ \
            \"code\":\"LimitExceeded\", \
            \"httpStatusCode\":400, \
            \"senderFault\":true \
          }, \
          \"exception\":true, \
          \"documentation\":\"<p> The quota for capacity groups or launch configurations for this customer has already been reached. </p>\" \
        }, \
        \"LoadBalancerNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen255\"} \
        }, \
        \"MaxNumberOfAutoScalingGroups\":{\"type\":\"integer\"}, \
        \"MaxNumberOfLaunchConfigurations\":{\"type\":\"integer\"}, \
        \"MaxRecords\":{\"type\":\"integer\"}, \
        \"MetricCollectionType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Metric\":{\"shape\":\"XmlStringMaxLen255\"} \
          }, \
          \"documentation\":\"<p> The MetricCollectionType data type. </p>\" \
        }, \
        \"MetricCollectionTypes\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"MetricCollectionType\"} \
        }, \
        \"MetricGranularityType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Granularity\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The granularity of a Metric. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The MetricGranularityType data type. </p>\" \
        }, \
        \"MetricGranularityTypes\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"MetricGranularityType\"} \
        }, \
        \"Metrics\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen255\"} \
        }, \
        \"MinAdjustmentStep\":{\"type\":\"integer\"}, \
        \"MonitoringEnabled\":{\"type\":\"boolean\"}, \
        \"NoDevice\":{\"type\":\"boolean\"}, \
        \"NotificationConfiguration\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> Specifies the Auto Scaling group name. </p>\" \
            }, \
            \"TopicARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The Amazon Resource Name (ARN) of the Amazon Simple Notification Service (SNS) topic. </p>\" \
            }, \
            \"NotificationType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The types of events for an action to start. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>NotificationConfiguration</code> data type. </p>\" \
        }, \
        \"NotificationConfigurations\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"NotificationConfiguration\"} \
        }, \
        \"PoliciesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"ScalingPolicies\":{ \
              \"shape\":\"ScalingPolicies\", \
              \"documentation\":\"<p> A list of scaling policies. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>PoliciesType</code> data type. </p>\" \
        }, \
        \"PolicyARNType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"PolicyARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> A policy's Amazon Resource Name (ARN). </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>PolicyARNType</code> data type. </p>\" \
        }, \
        \"PolicyIncrement\":{\"type\":\"integer\"}, \
        \"PolicyNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ResourceName\"} \
        }, \
        \"ProcessNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen255\"} \
        }, \
        \"ProcessType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"ProcessName\"], \
          \"members\":{ \
            \"ProcessName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of a process. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> There are two primary Auto Scaling process types--<code>Launch</code> and <code>Terminate</code>. The <code>Launch</code> process creates a new Amazon EC2 instance for an Auto Scaling group, and the <code>Terminate</code> process removes an existing Amazon EC2 instance. </p> <p> The remaining Auto Scaling process types relate to specific Auto Scaling features: <ul> <li>AddToLoadBalancer</li> <li>AlarmNotification</li> <li>AZRebalance</li> <li>HealthCheck</li> <li>ReplaceUnhealthy</li> <li>ScheduledActions</li> </ul> </p> <important> <p> If you suspend <code>Launch</code> or <code>Terminate</code>, all other process types are affected to varying degrees. The following descriptions discuss how each process type is affected by a suspension of <code>Launch</code> or <code>Terminate</code>. </p> </important> <p> The <code>AddToLoadBalancer</code> process type adds instances to the load balancer when the instances are launched. If you suspend this process, Auto Scaling will launch the instances but will not add them to the load balancer. If you resume the <code>AddToLoadBalancer</code> process, Auto Scaling will also resume adding new instances to the load balancer when they are launched. However, Auto Scaling will not add running instances that were launched while the process was suspended; those instances must be added manually using the the <a href=\\\"http://docs.aws.amazon.com/ElasticLoadBalancing/latest/APIReference/API_RegisterInstancesWithLoadBalancer.html\\\"> RegisterInstancesWithLoadBalancer</a> call in the <i>Elastic Load Balancing API Reference</i>. </p> <p> The <code>AlarmNotification</code> process type accepts notifications from Amazon CloudWatch alarms that are associated with the Auto Scaling group. If you suspend the <code>AlarmNotification</code> process type, Auto Scaling will not automatically execute scaling policies that would be triggered by alarms. </p> <p> Although the <code>AlarmNotification</code> process type is not directly affected by a suspension of <code>Launch</code> or <code>Terminate</code>, alarm notifications are often used to signal that a change in the size of the Auto Scaling group is warranted. If you suspend <code>Launch</code> or <code>Terminate</code>, Auto Scaling might not be able to implement the alarm's associated policy. </p> <p> The <code>AZRebalance</code> process type seeks to maintain a balanced number of instances across Availability Zones within a Region. If you remove an Availability Zone from your Auto Scaling group or an Availability Zone otherwise becomes unhealthy or unavailable, Auto Scaling launches new instances in an unaffected Availability Zone before terminating the unhealthy or unavailable instances. When the unhealthy Availability Zone returns to a healthy state, Auto Scaling automatically redistributes the application instances evenly across all of the designated Availability Zones. </p> <important> <p> If you call <a>SuspendProcesses</a> on the <code>launch</code> process type, the <code>AZRebalance</code> process will neither launch new instances nor terminate existing instances. This is because the <code>AZRebalance</code> process terminates existing instances only after launching the replacement instances. </p> <p> If you call <a>SuspendProcesses</a> on the <code>terminate</code> process type, the <code>AZRebalance</code> process can cause your Auto Scaling group to grow up to ten percent larger than the maximum size. This is because Auto Scaling allows groups to temporarily grow larger than the maximum size during rebalancing activities. If Auto Scaling cannot terminate instances, your Auto Scaling group could remain up to ten percent larger than the maximum size until you resume the <code>terminate</code> process type. </p> </important> <p> The <code>HealthCheck</code> process type checks the health of the instances. Auto Scaling marks an instance as unhealthy if Amazon EC2 or Elastic Load Balancing informs Auto Scaling that the instance is unhealthy. The <code>HealthCheck</code> process can override the health status of an instance that you set with <a>SetInstanceHealth</a>. </p> <p> The <code>ReplaceUnhealthy</code> process type terminates instances that are marked as unhealthy and subsequently creates new instances to replace them. This process calls both of the primary process types--first <code>Terminate</code> and then <code>Launch</code>. </p> <important> <p> The <code>HealthCheck</code> process type works in conjunction with the <code>ReplaceUnhealthly</code> process type to provide health check functionality. If you suspend either <code>Launch</code> or <code>Terminate</code>, the <code>ReplaceUnhealthy</code> process type will not function properly. </p> </important> <p> The <code>ScheduledActions</code> process type performs scheduled actions that you create with <a>PutScheduledUpdateGroupAction</a>. Scheduled actions often involve launching new instances or terminating existing instances. If you suspend either <code>Launch</code> or <code>Terminate</code>, your scheduled actions might not function as expected. </p>\" \
        }, \
        \"Processes\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ProcessType\"} \
        }, \
        \"ProcessesType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Processes\":{ \
              \"shape\":\"Processes\", \
              \"documentation\":\"<p> A list of <a>ProcessType</a> names. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The output of the <a>DescribeScalingProcessTypes</a> action. </p>\" \
        }, \
        \"Progress\":{\"type\":\"integer\"}, \
        \"PropagateAtLaunch\":{\"type\":\"boolean\"}, \
        \"PutLifecycleHookAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
          }, \
          \"documentation\":\"<p>The output of the <a>PutLifecycleHook</a> action. </p>\" \
        }, \
        \"PutLifecycleHookType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"LifecycleHookName\", \
            \"AutoScalingGroupName\" \
          ], \
          \"members\":{ \
            \"LifecycleHookName\":{ \
              \"shape\":\"AsciiStringMaxLen255\", \
              \"documentation\":\"<p>The name of the lifecycle hook.</p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group to which you want to assign the lifecycle hook.</p>\" \
            }, \
            \"LifecycleTransition\":{ \
              \"shape\":\"LifecycleTransition\", \
              \"documentation\":\"<p>The Amazon EC2 instance state to which you want to attach the lifecycle hook. See <a>DescribeLifecycleHookTypes</a> for a list of available lifecycle hook types.</p> <note> <p>This parameter is required for new lifecycle hooks, but optional when updating existing hooks.</p> </note>\" \
            }, \
            \"RoleARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The ARN of the Amazon IAM role that allows the Auto Scaling group to publish to the specified notification target.</p> <note> <p>This parameter is required for new lifecycle hooks, but optional when updating existing hooks.</p> </note>\" \
            }, \
            \"NotificationTargetARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The ARN of the notification target that Auto Scaling will use to notify you when an instance is in the transition state for the lifecycle hook. This ARN target can be either an SQS queue or an SNS topic. </p> <note> <p>This parameter is required for new lifecycle hooks, but optional when updating existing hooks.</p> </note> <p>The notification message sent to the target will include:</p> <ul> <li> <b>LifecycleActionToken</b>. The Lifecycle action token.</li> <li> <b>AccountId</b>. The user account ID.</li> <li> <b>AutoScalingGroupName</b>. The name of the Auto Scaling group.</li> <li> <b>LifecycleHookName</b>. The lifecycle hook name.</li> <li> <b>EC2InstanceId</b>. The EC2 instance ID.</li> <li> <b>LifecycleTransition</b>. The lifecycle transition.</li> <li> <b>NotificationMetadata</b>. The notification metadata.</li> </ul> <p>This operation uses the JSON format when sending notifications to an Amazon SQS queue, and an email key/value pair format when sending notifications to an Amazon SNS topic.</p> <p>When you call this operation, a test message is sent to the notification target. This test message contains an additional key/value pair: <code>Event:autoscaling:TEST_NOTIFICATION</code>.</p>\" \
            }, \
            \"NotificationMetadata\":{ \
              \"shape\":\"XmlStringMaxLen1023\", \
              \"documentation\":\"<p>Contains additional information that you want to include any time Auto Scaling sends a message to the notification target.</p>\" \
            }, \
            \"HeartbeatTimeout\":{ \
              \"shape\":\"HeartbeatTimeout\", \
              \"documentation\":\"<p>Defines the amount of time, in seconds, that can elapse before the lifecycle hook times out. When the lifecycle hook times out, Auto Scaling performs the action defined in the <code>DefaultResult</code> parameter. You can prevent the lifecycle hook from timing out by calling <a>RecordLifecycleActionHeartbeat</a>. The default value for this parameter is 3600 seconds (1 hour).</p>\" \
            }, \
            \"DefaultResult\":{ \
              \"shape\":\"LifecycleActionResult\", \
              \"documentation\":\"<p>Defines the action the Auto Scaling group should take when the lifecycle hook timeout elapses or if an unexpected failure occurs. The value for this parameter can be either <code>CONTINUE</code> or <code>ABANDON</code>. The default value for this parameter is <code>ABANDON</code>.</p>\" \
            } \
          } \
        }, \
        \"PutNotificationConfigurationType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"TopicARN\", \
            \"NotificationTypes\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"TopicARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The Amazon Resource Name (ARN) of the Amazon Simple Notification Service (SNS) topic. </p>\" \
            }, \
            \"NotificationTypes\":{ \
              \"shape\":\"AutoScalingNotificationTypes\", \
              \"documentation\":\"<p>The type of event that will cause the notification to be sent. For details about notification types supported by Auto Scaling, see <a>DescribeAutoScalingNotificationTypes</a>.</p>\" \
            } \
          } \
        }, \
        \"PutScalingPolicyType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"PolicyName\", \
            \"ScalingAdjustment\", \
            \"AdjustmentType\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name or ARN of the Auto Scaling group. </p>\" \
            }, \
            \"PolicyName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p>The name of the policy you want to create or update.</p>\" \
            }, \
            \"ScalingAdjustment\":{ \
              \"shape\":\"PolicyIncrement\", \
              \"documentation\":\"<p> The number of instances by which to scale. <code>AdjustmentType</code> determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. </p>\" \
            }, \
            \"AdjustmentType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies whether the <code>ScalingAdjustment</code> is an absolute number or a percentage of the current capacity. Valid values are <code>ChangeInCapacity</code>, <code>ExactCapacity</code>, and <code>PercentChangeInCapacity</code>. </p> <p>For more information about the adjustment types supported by Auto Scaling, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/as-scale-based-on-demand.html\\\">Scale Based on Demand</a>.</p>\" \
            }, \
            \"Cooldown\":{ \
              \"shape\":\"Cooldown\", \
              \"documentation\":\"<p> The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. </p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#Cooldown\\\">Cooldown Period</a></p>\" \
            }, \
            \"MinAdjustmentStep\":{ \
              \"shape\":\"MinAdjustmentStep\", \
              \"documentation\":\"<p> Used with <code>AdjustmentType</code> with the value <code>PercentChangeInCapacity</code>, the scaling policy changes the <code>DesiredCapacity</code> of the Auto Scaling group by at least the number of instances specified in the value. </p> <p> You will get a <code>ValidationError</code> if you use <code>MinAdjustmentStep</code> on a policy with an <code>AdjustmentType</code> other than <code>PercentChangeInCapacity</code>. </p>\" \
            } \
          } \
        }, \
        \"PutScheduledUpdateGroupActionType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"ScheduledActionName\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name or ARN of the Auto Scaling group. </p>\" \
            }, \
            \"ScheduledActionName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of this scaling action. </p>\" \
            }, \
            \"Time\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p><code>Time</code> is deprecated.</p> <p>The time for this action to start. <code>Time</code> is an alias for <code>StartTime</code> and can be specified instead of <code>StartTime</code>, or vice versa. If both <code>Time</code> and <code>StartTime</code> are specified, their values should be identical. Otherwise, <code>PutScheduledUpdateGroupAction</code> will return an error.</p>\" \
            }, \
            \"StartTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p>The time for this action to start, as in <code>--start-time 2010-06-01T00:00:00Z</code>.</p> <p>If you try to schedule your action in the past, Auto Scaling returns an error message. </p> <p>When <code>StartTime</code> and <code>EndTime</code> are specified with <code>Recurrence</code>, they form the boundaries of when the recurring action will start and stop.</p>\" \
            }, \
            \"EndTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p>The time for this action to end.</p>\" \
            }, \
            \"Recurrence\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The time when recurring future actions will start. Start time is specified by the user following the Unix cron syntax format. For information about cron syntax, go to <a href=\\\"http://en.wikipedia.org/wiki/Cron\\\">Wikipedia, The Free Encyclopedia</a>.</p> <p>When <code>StartTime</code> and <code>EndTime</code> are specified with <code>Recurrence</code>, they form the boundaries of when the recurring action will start and stop.</p>\" \
            }, \
            \"MinSize\":{ \
              \"shape\":\"AutoScalingGroupMinSize\", \
              \"documentation\":\"<p> The minimum size for the new Auto Scaling group. </p>\" \
            }, \
            \"MaxSize\":{ \
              \"shape\":\"AutoScalingGroupMaxSize\", \
              \"documentation\":\"<p> The maximum size for the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> The number of Amazon EC2 instances that should be running in the group. </p>\" \
            } \
          } \
        }, \
        \"RecordLifecycleActionHeartbeatAnswer\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
          }, \
          \"documentation\":\"<p>The output of the <a>RecordLifecycleActionHeartbeat</a> action. </p>\" \
        }, \
        \"RecordLifecycleActionHeartbeatType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"LifecycleHookName\", \
            \"AutoScalingGroupName\", \
            \"LifecycleActionToken\" \
          ], \
          \"members\":{ \
            \"LifecycleHookName\":{ \
              \"shape\":\"AsciiStringMaxLen255\", \
              \"documentation\":\"<p>The name of the lifecycle hook.</p>\" \
            }, \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p>The name of the Auto Scaling group to which the hook belongs.</p>\" \
            }, \
            \"LifecycleActionToken\":{ \
              \"shape\":\"LifecycleActionToken\", \
              \"documentation\":\"<p>A token that uniquely identifies a specific lifecycle action associated with an instance. Auto Scaling sends this token to the notification target you specified when you created the lifecycle hook.</p>\" \
            } \
          } \
        }, \
        \"ResourceInUseFault\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"message\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> </p>\" \
            } \
          }, \
          \"error\":{ \
            \"code\":\"ResourceInUse\", \
            \"httpStatusCode\":400, \
            \"senderFault\":true \
          }, \
          \"exception\":true, \
          \"documentation\":\"<p> This is returned when you cannot delete a launch configuration or Auto Scaling group because it is being used. </p>\" \
        }, \
        \"ResourceName\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":1600, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"ScalingActivityInProgressFault\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"message\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> </p>\" \
            } \
          }, \
          \"error\":{ \
            \"code\":\"ScalingActivityInProgress\", \
            \"httpStatusCode\":400, \
            \"senderFault\":true \
          }, \
          \"exception\":true, \
          \"documentation\":\"<p> You cannot delete an Auto Scaling group while there are scaling activities in progress for that group. </p>\" \
        }, \
        \"ScalingActivityStatusCode\":{ \
          \"type\":\"string\", \
          \"enum\":[ \
            \"WaitingForSpotInstanceRequestId\", \
            \"WaitingForSpotInstanceId\", \
            \"WaitingForInstanceId\", \
            \"PreInService\", \
            \"InProgress\", \
            \"WaitingForELBConnectionDraining\", \
            \"MidLifecycleAction\", \
            \"Successful\", \
            \"Failed\", \
            \"Cancelled\" \
          ] \
        }, \
        \"ScalingPolicies\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ScalingPolicy\"} \
        }, \
        \"ScalingPolicy\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Auto Scaling group associated with this scaling policy. </p>\" \
            }, \
            \"PolicyName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the scaling policy. </p>\" \
            }, \
            \"ScalingAdjustment\":{ \
              \"shape\":\"PolicyIncrement\", \
              \"documentation\":\"<p> The number associated with the specified adjustment type. A positive value adds to the current capacity and a negative value removes from the current capacity. </p>\" \
            }, \
            \"AdjustmentType\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> Specifies whether the <code>ScalingAdjustment</code> is an absolute number or a percentage of the current capacity. Valid values are <code>ChangeInCapacity</code>, <code>ExactCapacity</code>, and <code>PercentChangeInCapacity</code>. </p>\" \
            }, \
            \"Cooldown\":{ \
              \"shape\":\"Cooldown\", \
              \"documentation\":\"<p> The amount of time, in seconds, after a scaling activity completes before any further trigger-related scaling activities can start. </p>\" \
            }, \
            \"PolicyARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The Amazon Resource Name (ARN) of the policy. </p>\" \
            }, \
            \"Alarms\":{ \
              \"shape\":\"Alarms\", \
              \"documentation\":\"<p> A list of CloudWatch Alarms related to the policy. </p>\" \
            }, \
            \"MinAdjustmentStep\":{ \
              \"shape\":\"MinAdjustmentStep\", \
              \"documentation\":\"<p> Changes the <code>DesiredCapacity</code> of the Auto Scaling group by at least the specified number of instances. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The <code>ScalingPolicy</code> data type. </p>\" \
        }, \
        \"ScalingProcessQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name or Amazon Resource Name (ARN) of the Auto Scaling group. </p>\" \
            }, \
            \"ScalingProcesses\":{ \
              \"shape\":\"ProcessNames\", \
              \"documentation\":\"<p> The processes that you want to suspend or resume, which can include one or more of the following: </p> <ul> <li>Launch</li> <li>Terminate</li> <li>HealthCheck</li> <li>ReplaceUnhealthy</li> <li>AZRebalance</li> <li>AlarmNotification</li> <li>ScheduledActions</li> <li>AddToLoadBalancer</li> </ul> <p> To suspend all process types, omit this parameter. </p>\" \
            } \
          } \
        }, \
        \"ScheduledActionNames\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ResourceName\"} \
        }, \
        \"ScheduledActionsType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"ScheduledUpdateGroupActions\":{ \
              \"shape\":\"ScheduledUpdateGroupActions\", \
              \"documentation\":\"<p> A list of scheduled actions designed to update an Auto Scaling group. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string that marks the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> A scaling action that is scheduled for a future time and date. An action can be scheduled up to thirty days in advance. </p> <p> Starting with API version 2011-01-01, you can use <code>recurrence</code> to specify that a scaling action occurs regularly on a schedule. </p>\" \
        }, \
        \"ScheduledUpdateGroupAction\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the Auto Scaling group to be updated. </p>\" \
            }, \
            \"ScheduledActionName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of this scheduled action. </p>\" \
            }, \
            \"ScheduledActionARN\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The Amazon Resource Name (ARN) of this scheduled action. </p>\" \
            }, \
            \"Time\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> <code>Time</code> is deprecated.</p> <p>The time that the action is scheduled to begin. <code>Time</code> is an alias for <code>StartTime</code>. </p>\" \
            }, \
            \"StartTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> The time that the action is scheduled to begin. This value can be up to one month in the future. </p> <p>When <code>StartTime</code> and <code>EndTime</code> are specified with <code>Recurrence</code>, they form the boundaries of when the recurring action will start and stop.</p>\" \
            }, \
            \"EndTime\":{ \
              \"shape\":\"TimestampType\", \
              \"documentation\":\"<p> The time that the action is scheduled to end. This value can be up to one month in the future. </p>\" \
            }, \
            \"Recurrence\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The regular schedule that an action occurs. </p>\" \
            }, \
            \"MinSize\":{ \
              \"shape\":\"AutoScalingGroupMinSize\", \
              \"documentation\":\"<p> The minimum size of the Auto Scaling group. </p>\" \
            }, \
            \"MaxSize\":{ \
              \"shape\":\"AutoScalingGroupMaxSize\", \
              \"documentation\":\"<p> The maximum size of the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> The number of instances you prefer to maintain in your Auto Scaling group. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> This data type stores information about a scheduled update to an Auto Scaling group. </p>\" \
        }, \
        \"ScheduledUpdateGroupActions\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"ScheduledUpdateGroupAction\"} \
        }, \
        \"SecurityGroups\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlString\"} \
        }, \
        \"SetDesiredCapacityType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"AutoScalingGroupName\", \
            \"DesiredCapacity\" \
          ], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> The new capacity setting for the Auto Scaling group. </p>\" \
            }, \
            \"HonorCooldown\":{ \
              \"shape\":\"HonorCooldown\", \
              \"documentation\":\"<p> By default, <code>SetDesiredCapacity</code> overrides any cooldown period associated with the Auto Scaling group. Set to <code>True</code> if you want Auto Scaling to wait for the cooldown period associated with the Auto Scaling group to complete before initiating a scaling activity to set your Auto Scaling group to the new capacity setting. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"SetInstanceHealthQuery\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"InstanceId\", \
            \"HealthStatus\" \
          ], \
          \"members\":{ \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> The identifier of the Amazon EC2 instance. </p>\" \
            }, \
            \"HealthStatus\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The health status of the instance. Set to <code>Healthy</code> if you want the instance to remain in service. Set to <code>Unhealthy</code> if you want the instance to be out of service. Auto Scaling will terminate and replace the unhealthy instance. </p>\" \
            }, \
            \"ShouldRespectGracePeriod\":{ \
              \"shape\":\"ShouldRespectGracePeriod\", \
              \"documentation\":\"<p>If the Auto Scaling group of the specified instance has a <code>HealthCheckGracePeriod</code> specified for the group, by default, this call will respect the grace period. Set this to <code>False</code>, if you do not want the call to respect the grace period associated with the group.</p> <p>For more information, see the <code>HealthCheckGracePeriod</code> parameter description in the <a>CreateAutoScalingGroup</a> action. </p>\" \
            } \
          } \
        }, \
        \"ShouldDecrementDesiredCapacity\":{\"type\":\"boolean\"}, \
        \"ShouldRespectGracePeriod\":{\"type\":\"boolean\"}, \
        \"SpotPrice\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":255 \
        }, \
        \"SuspendedProcess\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"ProcessName\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the suspended process. </p>\" \
            }, \
            \"SuspensionReason\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The reason that the process was suspended. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> An Auto Scaling process that has been suspended. For more information, see <a>ProcessType</a>. </p>\" \
        }, \
        \"SuspendedProcesses\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"SuspendedProcess\"} \
        }, \
        \"Tag\":{ \
          \"type\":\"structure\", \
          \"required\":[\"Key\"], \
          \"members\":{ \
            \"ResourceId\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"ResourceType\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The kind of resource to which the tag is applied. Currently, Auto Scaling supports the <code>auto-scaling-group</code> resource type. </p>\" \
            }, \
            \"Key\":{ \
              \"shape\":\"TagKey\", \
              \"documentation\":\"<p> The key of the tag. </p>\" \
            }, \
            \"Value\":{ \
              \"shape\":\"TagValue\", \
              \"documentation\":\"<p> The value of the tag. </p>\" \
            }, \
            \"PropagateAtLaunch\":{ \
              \"shape\":\"PropagateAtLaunch\", \
              \"documentation\":\"<p> Specifies whether the new tag will be applied to instances launched after the tag is created. The same behavior applies to updates: If you change a tag, the changed tag will be applied to all instances launched after you made the change. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The tag applied to an Auto Scaling group. </p>\" \
        }, \
        \"TagDescription\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"ResourceId\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"ResourceType\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> The kind of resource to which the tag is applied. Currently, Auto Scaling supports the <code>auto-scaling-group</code> resource type. </p>\" \
            }, \
            \"Key\":{ \
              \"shape\":\"TagKey\", \
              \"documentation\":\"<p> The key of the tag. </p>\" \
            }, \
            \"Value\":{ \
              \"shape\":\"TagValue\", \
              \"documentation\":\"<p> The value of the tag. </p>\" \
            }, \
            \"PropagateAtLaunch\":{ \
              \"shape\":\"PropagateAtLaunch\", \
              \"documentation\":\"<p> Specifies whether the new tag will be applied to instances launched after the tag is created. The same behavior applies to updates: If you change a tag, the changed tag will be applied to all instances launched after you made the change. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> The tag applied to an Auto Scaling group. </p>\" \
        }, \
        \"TagDescriptionList\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"TagDescription\"} \
        }, \
        \"TagKey\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":128, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"TagValue\":{ \
          \"type\":\"string\", \
          \"min\":0, \
          \"max\":256, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"Tags\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"Tag\"} \
        }, \
        \"TagsType\":{ \
          \"type\":\"structure\", \
          \"members\":{ \
            \"Tags\":{ \
              \"shape\":\"TagDescriptionList\", \
              \"documentation\":\"<p> The list of tags. </p>\" \
            }, \
            \"NextToken\":{ \
              \"shape\":\"XmlString\", \
              \"documentation\":\"<p> A string used to mark the start of the next batch of returned results. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"TerminateInstanceInAutoScalingGroupType\":{ \
          \"type\":\"structure\", \
          \"required\":[ \
            \"InstanceId\", \
            \"ShouldDecrementDesiredCapacity\" \
          ], \
          \"members\":{ \
            \"InstanceId\":{ \
              \"shape\":\"XmlStringMaxLen16\", \
              \"documentation\":\"<p> The ID of the Amazon EC2 instance to be terminated. </p>\" \
            }, \
            \"ShouldDecrementDesiredCapacity\":{ \
              \"shape\":\"ShouldDecrementDesiredCapacity\", \
              \"documentation\":\"<p> Specifies whether (<i>true</i>) or not (<i>false</i>) terminating this instance should also decrement the size of the <a>AutoScalingGroup</a>. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"TerminationPolicies\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlStringMaxLen1600\"} \
        }, \
        \"TimestampType\":{\"type\":\"timestamp\"}, \
        \"UpdateAutoScalingGroupType\":{ \
          \"type\":\"structure\", \
          \"required\":[\"AutoScalingGroupName\"], \
          \"members\":{ \
            \"AutoScalingGroupName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the Auto Scaling group. </p>\" \
            }, \
            \"LaunchConfigurationName\":{ \
              \"shape\":\"ResourceName\", \
              \"documentation\":\"<p> The name of the launch configuration. </p>\" \
            }, \
            \"MinSize\":{ \
              \"shape\":\"AutoScalingGroupMinSize\", \
              \"documentation\":\"<p> The minimum size of the Auto Scaling group. </p>\" \
            }, \
            \"MaxSize\":{ \
              \"shape\":\"AutoScalingGroupMaxSize\", \
              \"documentation\":\"<p> The maximum size of the Auto Scaling group. </p>\" \
            }, \
            \"DesiredCapacity\":{ \
              \"shape\":\"AutoScalingGroupDesiredCapacity\", \
              \"documentation\":\"<p> The desired capacity for the Auto Scaling group. </p>\" \
            }, \
            \"DefaultCooldown\":{ \
              \"shape\":\"Cooldown\", \
              \"documentation\":\"<p> The amount of time, in seconds, after a scaling activity completes before any further scaling activities can start. For more information, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AS_Concepts.html#Cooldown\\\">Cooldown Period</a>. </p>\" \
            }, \
            \"AvailabilityZones\":{ \
              \"shape\":\"AvailabilityZones\", \
              \"documentation\":\"<p> Availability Zones for the group. </p>\" \
            }, \
            \"HealthCheckType\":{ \
              \"shape\":\"XmlStringMaxLen32\", \
              \"documentation\":\"<p> The type of health check for the instances in the Auto Scaling group. The health check type can either be <code>EC2</code> for Amazon EC2 or <code>ELB</code> for Elastic Load Balancing. </p>\" \
            }, \
            \"HealthCheckGracePeriod\":{ \
              \"shape\":\"HealthCheckGracePeriod\", \
              \"documentation\":\"<p> The length of time that Auto Scaling waits before checking an instance's health status. The grace period begins when the instance passes System Status and the Instance Status checks from Amazon EC2. For more information, see <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/APIReference/ApiReference-query-DescribeInstanceStatus.html\\\">DescribeInstanceStatus</a>. </p>\" \
            }, \
            \"PlacementGroup\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The name of the cluster placement group, if applicable. For more information, go to <a href=\\\"http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using_cluster_computing.html\\\"> Using Cluster Instances</a> in the Amazon EC2 User Guide. </p>\" \
            }, \
            \"VPCZoneIdentifier\":{ \
              \"shape\":\"XmlStringMaxLen255\", \
              \"documentation\":\"<p> The subnet identifier for the Amazon VPC connection, if applicable. You can specify several subnets in a comma-separated list. </p> <p> When you specify <code>VPCZoneIdentifier</code> with <code>AvailabilityZones</code>, ensure that the subnets' Availability Zones match the values you specify for <code>AvailabilityZones</code>. </p> <p> For more information on creating your Auto Scaling group in Amazon VPC by specifying subnets, see <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/autoscalingsubnets.html\\\">Launch Auto Scaling Instances into Amazon VPC</a> in the the <i>Auto Scaling Developer Guide</i>. </p>\" \
            }, \
            \"TerminationPolicies\":{ \
              \"shape\":\"TerminationPolicies\", \
              \"documentation\":\"<p> A standalone termination policy or a list of termination policies used to select the instance to terminate. The policies are executed in the order that they are listed. </p> <p> For more information on creating a termination policy for your Auto Scaling group, go to <a href=\\\"http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/us-termination-policy.html\\\">Instance Termination Policy for Your Auto Scaling Group</a> in the the <i>Auto Scaling Developer Guide</i>. </p>\" \
            } \
          }, \
          \"documentation\":\"<p> </p>\" \
        }, \
        \"Values\":{ \
          \"type\":\"list\", \
          \"member\":{\"shape\":\"XmlString\"} \
        }, \
        \"XmlString\":{ \
          \"type\":\"string\", \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen1023\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":1023, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen16\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":16, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen1600\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":1600, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen255\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":255, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen32\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":32, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringMaxLen64\":{ \
          \"type\":\"string\", \
          \"min\":1, \
          \"max\":64, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        }, \
        \"XmlStringUserData\":{ \
          \"type\":\"string\", \
          \"max\":21847, \
          \"pattern\":\"[\\\\u0020-\\\\uD7FF\\\\uE000-\\\\uFFFD\\\\uD800\\\\uDC00-\\\\uDBFF\\\\uDFFF\\\\r\\\\n\\\\t]*\" \
        } \
      } \
    } \
     \
    ";
}

@end
