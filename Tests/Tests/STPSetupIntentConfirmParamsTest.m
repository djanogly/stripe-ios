//
//  STPSetupIntentConfirmParamsTest.m
//  StripeiOS Tests
//
//  Created by Cameron Sabol on 7/15/19.
//  Copyright © 2019 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "STPSetupIntentConfirmParams.h"
#import "STPSetupIntentConfirmParams+Utilities.h"

#import "STPMandateCustomerAcceptanceParams.h"
#import "STPMandateDataParams.h"
#import "STPMandateOnlineParams+Private.h"
#import "STPPaymentMethodParams.h"

@interface STPSetupIntentConfirmParamsTest : XCTestCase

@end

@implementation STPSetupIntentConfirmParamsTest

- (void)testInit {
    for (STPSetupIntentConfirmParams *params in @[[[STPSetupIntentConfirmParams alloc] initWithClientSecret:@"secret"],
                                             [[STPSetupIntentConfirmParams alloc] init],
                                             [STPSetupIntentConfirmParams new],
                                             ]) {
        XCTAssertNotNil(params);
        XCTAssertNotNil(params.clientSecret);
        XCTAssertNotNil(params.additionalAPIParameters);
        XCTAssertEqual(params.additionalAPIParameters.count, 0UL);
        XCTAssertNil(params.paymentMethodID);
        XCTAssertNil(params.returnURL);
        XCTAssertNil(params.useStripeSDK);
        XCTAssertNil(params.mandateData);
    }
}

- (void)testDescription {
    STPSetupIntentConfirmParams *params = [[STPSetupIntentConfirmParams alloc] init];
    XCTAssertNotNil(params.description);
}

- (void)testDefaultMandateData {
    STPSetupIntentConfirmParams *params = [[STPSetupIntentConfirmParams alloc] init];

    // no configuration should have no mandateData
    XCTAssertNil(params.mandateData);

    params.paymentMethodParams = [[STPPaymentMethodParams alloc] init];

    params.paymentMethodParams.rawTypeString = @"card";
    // card type should have no default mandateData
    XCTAssertNil(params.mandateData);

    for (NSString *type in @[@"sepa_debit", @"au_becs_debit", @"bacs_debit"]) {
        params.mandateData = nil;
        params.paymentMethodParams.rawTypeString = type;
        // Mandate-required type should have mandateData
        XCTAssertNotNil(params.mandateData);
        XCTAssertEqual(params.mandateData.customerAcceptance.onlineParams.inferFromClient, @YES);

        params.mandateData = [[STPMandateDataParams alloc] init];
        // Default behavior should not override custom setting
        XCTAssertNotNil(params.mandateData);
        XCTAssertNil(params.mandateData.customerAcceptance);
    }
}

#pragma mark STPFormEncodable Tests

- (void)testRootObjectName {
    XCTAssertNil([STPSetupIntentConfirmParams rootObjectName]);
}

- (void)testPropertyNamesToFormFieldNamesMapping {
    STPSetupIntentConfirmParams *params = [STPSetupIntentConfirmParams new];

    NSDictionary *mapping = [STPSetupIntentConfirmParams propertyNamesToFormFieldNamesMapping];

    for (NSString *propertyName in [mapping allKeys]) {
        XCTAssertFalse([propertyName containsString:@":"]);
        XCTAssert([params respondsToSelector:NSSelectorFromString(propertyName)]);
    }

    for (NSString *formFieldName in [mapping allValues]) {
        XCTAssert([formFieldName isKindOfClass:[NSString class]]);
        XCTAssert([formFieldName length] > 0);
    }

    XCTAssertEqual([[mapping allValues] count], [[NSSet setWithArray:[mapping allValues]] count]);
}

- (void)testCopy {
    STPSetupIntentConfirmParams *params = [[STPSetupIntentConfirmParams alloc] initWithClientSecret:@"test_client_secret"];
    params.paymentMethodParams = [[STPPaymentMethodParams alloc] init];
    params.paymentMethodID = @"test_payment_method_id";
    params.returnURL = @"fake://testing_only";
    params.useStripeSDK = @YES;
    params.mandateData = [[STPMandateDataParams alloc] init];
    params.additionalAPIParameters = @{@"other_param" : @"other_value"};

    STPSetupIntentConfirmParams *paramsCopy = [params copy];
    XCTAssertEqualObjects(params.clientSecret, paramsCopy.clientSecret);
    XCTAssertEqualObjects(params.paymentMethodID, paramsCopy.paymentMethodID);

    // assert equal, not equal objects, because this is a shallow copy
    XCTAssertEqual(params.paymentMethodParams, paramsCopy.paymentMethodParams);
    XCTAssertEqual(params.mandateData, paramsCopy.mandateData);

    XCTAssertEqualObjects(params.returnURL, paramsCopy.returnURL);
    XCTAssertEqualObjects(params.useStripeSDK, paramsCopy.useStripeSDK);
    XCTAssertEqualObjects(params.additionalAPIParameters, paramsCopy.additionalAPIParameters);


}

- (void)testClientSecretValidation {
    XCTAssertFalse([STPSetupIntentConfirmParams isClientSecretValid:@"seti_12345"], @"'seti_12345' is not a valid client secret.");
    XCTAssertFalse([STPSetupIntentConfirmParams isClientSecretValid:@"seti_12345_secret_"], @"'seti_12345_secret_' is not a valid client secret.");
    XCTAssertFalse([STPSetupIntentConfirmParams isClientSecretValid:@"seti_a1b2c3_secret_x7y8z9seti_a1b2c3_secret_x7y8z9"], @"'seti_a1b2c3_secret_x7y8z9seti_a1b2c3_secret_x7y8z9' is not a valid client secret.");
    XCTAssertFalse([STPSetupIntentConfirmParams isClientSecretValid:@"pi_a1b2c3_secret_x7y8z9"], @"'pi_a1b2c3_secret_x7y8z9' is not a valid client secret.");

    XCTAssertTrue([STPSetupIntentConfirmParams isClientSecretValid:@"seti_a1b2c3_secret_x7y8z9"], @"'seti_a1b2c3_secret_x7y8z9' is a valid client secret.");
    XCTAssertTrue([STPSetupIntentConfirmParams isClientSecretValid:@"seti_1Eq5kyGMT9dGPIDGxiSp4cce_secret_FKlHb3yTI0YZWe4iqghS8ZXqwwMoMmy"], @"'seti_1Eq5kyGMT9dGPIDGxiSp4cce_secret_FKlHb3yTI0YZWe4iqghS8ZXqwwMoMmy' is a valid client secret.");
}

@end
