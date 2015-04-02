//
//  SRWebClientTest.m
//  iOS-SRWebClient
//
//  Created by Suman Raj on 02/04/15.
//  Copyright (c) 2015 Suman Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SRWebClient.h"

@interface SRWebClientTests : XCTestCase

@end

@implementation SRWebClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGetSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Handler called"];
    [[SRWebClient GET:@"http://headers.jsontest.com/"]
     send:^(id respObj) {
        [expectation fulfill];
         XCTAssertNotNil(respObj);
     }
     failure:^(NSError *respError) {
         XCTAssertNil(respError);
     }];
    [self waitForExpectationsWithTimeout:0.4 handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
