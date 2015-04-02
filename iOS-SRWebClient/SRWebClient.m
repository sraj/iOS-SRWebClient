//
//  SRWebClient.m
//  SRWebClient
//
//  Created by Suman Raj on 02/04/15.
//  Copyright (c) 2015 Suman Raj. All rights reserved.
//

#import "SRWebClient.h"

@interface SRWebClient ()

@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSMutableURLRequest *urlRequest;
@property (nonatomic, assign) NSString *httpMethod;

@end

@implementation SRWebClient


+ (SRWebClient *) GET:(NSString *)url {
    return [[[SRWebClient alloc] initWithURL:url httpMethod:@"GET"] autorelease];
}

- (id) initWithURL:(NSString *)url httpMethod:(NSString *)httpMethod {
    self = [super init];
    if(self != nil) {
        self.urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        if (httpMethod) {
            self.httpMethod = httpMethod;
        } else {
            self.httpMethod = @"GET";
        }
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

- (NSString *) build:(NSDictionary *)reqData {
    NSMutableArray *pairs = [NSMutableArray array];
    
    for(NSString *key in [reqData keyEnumerator]) {
        NSString *value = (NSString *) [reqData objectForKey:key];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self encodeToPercentEscapeString:value]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

- (NSString *) encodeToPercentEscapeString:(NSString *)value {
    return (NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) value, NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}


- (SRWebClient *) headers:(NSDictionary *) headerDict {
    if (headerDict) {
        [self.urlRequest setAllHTTPHeaderFields:headerDict];
    }
    return self;
}

- (SRWebClient *) data:(NSDictionary *) dataDict {
    if (dataDict && [dataDict count] > 0) {
        if (self.httpMethod && [self.httpMethod isEqualToString:@"GET"]) {
            NSString *absoluteURL = [[self.urlRequest URL] absoluteString];
            [self.urlRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",
                                                          absoluteURL,
                                                          [self build:dataDict]]]];
        }
    }
    return self;
}


- (SRWebClient *) send:(SuccessBlock) successBlock failure:(FailureBlock) failureBlock {
    
    NSBlockOperation *operationBlock = [NSBlockOperation blockOperationWithBlock:^{
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        
        [self.urlRequest setHTTPMethod:self.httpMethod];
        [self.urlRequest setTimeoutInterval:SRWEBCLIENT_DEFAULT_TIMEOUT];
        
        NSData *result = [NSURLConnection sendSynchronousRequest:self.urlRequest
                                               returningResponse:&response
                                                           error:&error];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(error) {
                if(failureBlock) {
                    failureBlock(error);
                }
            } else {
                if(response && ([response statusCode] >= 200 && [response statusCode] <= 300)) {
                    NSDictionary *respHeaders = [response allHeaderFields];
                    if (respHeaders && [[respHeaders objectForKey:@"Content-Type"] isEqualToString:@"application/json"]) {
                        NSError *jsonError = nil;
                        id jsonResp = [NSJSONSerialization JSONObjectWithData:result
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:&jsonError];
                        if(jsonError && failureBlock) {
                            failureBlock(jsonError);
                        } else if (successBlock && jsonResp) {
                            successBlock(jsonResp);
                        }
                    } else {
                        NSString *strResp = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                        if (successBlock) {
                            successBlock(strResp);
                        }
                    }
                } else if (response != Nil && response != Nil && failureBlock != Nil) {
                    failureBlock([NSError errorWithDomain:[[self.urlRequest URL] path] code:[response statusCode] userInfo:nil]);
                }
            }
        }];
    }];
    [operationBlock setQueuePriority:NSOperationQueuePriorityNormal];
    [self.operationQueue addOperation:operationBlock];
    return self;
}


- (void) dealloc {
    [_operationQueue release]; _operationQueue = nil;
    [_urlRequest release]; _urlRequest = nil;
    [super dealloc];
}

@end
