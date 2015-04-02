//
//  NSPDefines.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 02/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NSP_EXTERN
  #if defined(__cplusplus)
    #define NSP_EXTERN extern "C"
  #else
    #define NSP_EXTERN extern
  #endif
#endif
