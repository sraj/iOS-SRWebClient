//
//  SRWebClient.h
//  SRWebClient
//
//  Created by Suman Raj on 02/04/15.
//  Copyright (c) 2015 Suman Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SRWEBCLIENT_DEFAULT_TIMEOUT 30.0f

typedef void (^SuccessBlock)(id respObj);
typedef void (^FailureBlock)(NSError *respError);

@interface SRWebClient : NSObject

+ (SRWebClient *) GET:(NSString *) url;

- (SRWebClient *) headers:(NSDictionary *) headerDict;
- (SRWebClient *) data:(NSDictionary *) dataDict;
- (SRWebClient *) send:(SuccessBlock) successBlock failure:(FailureBlock) failureBlock;

@end
