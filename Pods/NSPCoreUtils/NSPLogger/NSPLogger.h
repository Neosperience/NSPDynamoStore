//
//  NSPLogger.h
//  NSPCoreUtils
//
//  Created by Janos Tolgyesi on 11/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSPLOGGER_NOLOG           1
#define NSPLOGGER_NSLOG           2
#define NSPLOGGER_COCOALUMBERJACK 3

#ifndef NSPLOGGER_SELECTED_LOGGER

#define NSPLOGGER_SELECTED_LOGGER   NSPLOGGER_NOLOG

#endif

#if (NSPLOGGER_SELECTED_LOGGER == NSPLOGGER_NOLOG)

#define NSPLogVerbose(fmt, ...)
#define NSPLogInfo(fmt, ...)
#define NSPLogDebug(fmt, ...)
#define NSPLogWarning(fmt, ...)
#define NSPLogError(fmt, ...)

#elif (NSPLOGGER_SELECTED_LOGGER == NSPLOGGER_NSLOG)

#define NSPLogVerbose(fmt, ...)     NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define NSPLogInfo(fmt, ...)        NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define NSPLogDebug(fmt, ...)       NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define NSPLogWarning(fmt, ...)     NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define NSPLogError(fmt, ...)       NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#elif (NSPLOGGER_SELECTED_LOGGER == NSPLOGGER_COCOALUMBERJACK)

#import <DDLog.h>

extern const int ddLogLevel;

#define NSPLogVerbose(fmt, ...)     DDLogVerbose(fmt, ##__VA_ARGS__);
#define NSPLogInfo(fmt, ...)        DDLogInfo(fmt, ##__VA_ARGS__);
#define NSPLogDebug(fmt, ...)       DDLogDebug(fmt, ##__VA_ARGS__);
#define NSPLogWarning(fmt, ...)        DDLogWarn(fmt, ##__VA_ARGS__);
#define NSPLogError(fmt, ...)       DDLogError(fmt, ##__VA_ARGS__);

#endif
