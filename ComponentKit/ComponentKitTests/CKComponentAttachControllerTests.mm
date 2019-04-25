/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <XCTest/XCTest.h>

#import <ComponentKit/CKComponent.h>
#import <ComponentKit/CKComponentInternal.h>
#import <ComponentKit/CKComponentLayout.h>
#import <ComponentKit/CKComponentAttachController.h>
#import <ComponentKit/CKComponentAttachControllerInternal.h>
#import <ComponentKit/CKComponentRootLayoutProvider.h>
#import <ComponentKitTestHelpers/CKAnalyticsListenerSpy.h>

@interface CKComponentRootLayoutTestProvider: NSObject <CKComponentRootLayoutProvider>

@end

@implementation CKComponentRootLayoutTestProvider
{
  CKComponentRootLayout _rootLayout;
}

- (instancetype)initWithRootLayout:(const CKComponentRootLayout &)rootLayout
{
  if (self = [super init]) {
    _rootLayout = rootLayout;
  }
  return self;
}

- (const CKComponentRootLayout &)rootLayout
{
  return _rootLayout;
}

@end

@interface CKComponentAttachControllerTests : XCTestCase
@end

@implementation CKComponentAttachControllerTests

- (void)testAttachingAndDetachingComponentLayoutOnViewResultsInCorrectAttachState
{
  auto const attachController = [CKComponentAttachController new];
  [self _testAttachingAndDetachingComponentLayoutOnViewResultsInCorrectAttachStateWithAttachController:attachController];
}

- (void)testAttachingOneComponentLayoutAfterAnotherToViewResultsInTheFirstOneBeingDetachedWithAttachController
{
  auto const attachController = [CKComponentAttachController new];
  [self _testAttachingOneComponentLayoutAfterAnotherToViewResultsInTheFirstOneBeingDetachedWithAttachController:attachController];
}

- (void)_testAttachingAndDetachingComponentLayoutOnViewResultsInCorrectAttachStateWithAttachController:(CKComponentAttachController *)attachController
{
  UIView *view = [UIView new];
  CKComponent *component = [CKComponent new];
  CKComponentScopeRootIdentifier scopeIdentifier = 0x5C09E;

  CKComponentAttachControllerAttachComponentRootLayout(
      attachController,
      {.layoutProvider =
        [[CKComponentRootLayoutTestProvider alloc]
         initWithRootLayout:CKComponentRootLayout {{component, {0, 0}}}],
       .scopeIdentifier = scopeIdentifier,
       .boundsAnimation = {},
       .view = view,
       .analyticsListener = nil});
  CKComponentAttachState *attachState = [attachController attachStateForScopeIdentifier:scopeIdentifier];
  XCTAssertEqualObjects(attachState.mountedComponents, [NSSet setWithObject:component]);
  XCTAssertEqual(attachState.scopeIdentifier, scopeIdentifier);

  [attachController detachComponentLayoutWithScopeIdentifier:scopeIdentifier];
  attachState = [attachController attachStateForScopeIdentifier:scopeIdentifier];
  XCTAssertNil(attachState);
}

- (void)_testAttachingOneComponentLayoutAfterAnotherToViewResultsInTheFirstOneBeingDetachedWithAttachController:(CKComponentAttachController *)attachController
{
  UIView *view = [UIView new];
  CKComponent *component = [CKComponent new];
  CKComponentScopeRootIdentifier scopeIdentifier = 0x5C09E;
  CKComponentAttachControllerAttachComponentRootLayout(
      attachController,
      {.layoutProvider =
        [[CKComponentRootLayoutTestProvider alloc]
         initWithRootLayout:CKComponentRootLayout {{component, {0, 0}}}],
       .scopeIdentifier = scopeIdentifier,
       .boundsAnimation = {},
       .view = view,
       .analyticsListener = nil});

  CKComponent *component2 = [CKComponent new];
  CKComponentScopeRootIdentifier scopeIdentifier2 = 0x5C09E2;
  CKComponentAttachControllerAttachComponentRootLayout(
      attachController,
      {.layoutProvider =
        [[CKComponentRootLayoutTestProvider alloc]
         initWithRootLayout:CKComponentRootLayout {{component2, {0, 0}}}],
       .scopeIdentifier = scopeIdentifier2,
       .boundsAnimation = {},
       .view = view,
       .analyticsListener = nil});

  // the first component is now detached
  CKComponentAttachState *attachState = [attachController attachStateForScopeIdentifier:scopeIdentifier];
  XCTAssertNil(attachState);

  // the second component is attached
  CKComponentAttachState *attachState2 = [attachController attachStateForScopeIdentifier:scopeIdentifier2];
  XCTAssertEqualObjects(attachState2.mountedComponents, [NSSet setWithObject:component2]);
  XCTAssertEqual(attachState2.scopeIdentifier, scopeIdentifier2);
}

- (void)test_WhenMountsLayout_ReportsWillCollectAnimationsEvent
{
  auto const attachController = [CKComponentAttachController new];
  auto const layout = CKComponentRootLayout {
    {[CKComponent new], {0, 0}}
  };
  auto const layoutProvider = [[CKComponentRootLayoutTestProvider alloc] initWithRootLayout:layout];
  auto const spy = [CKAnalyticsListenerSpy new];

  CKComponentAttachControllerAttachComponentRootLayout(attachController,
                                                                 {.layoutProvider =
                                                                   layoutProvider,
                                                                   .scopeIdentifier = 0x5C09E,
                                                                   .boundsAnimation = {},
                                                                   .view = [UIView new],
                                                                   .analyticsListener = spy});

  XCTAssertEqual(spy->_willCollectAnimationsHitCount, 1);
}

- (void)test_WhenMountsLayout_ReportsDidCollectAnimationsEvent
{
  auto const attachController = [CKComponentAttachController new];
  auto const layout = CKComponentRootLayout {
    {[CKComponent new], {0, 0}}
  };
  auto const layoutProvider = [[CKComponentRootLayoutTestProvider alloc] initWithRootLayout:layout];
  auto const spy = [CKAnalyticsListenerSpy new];

  CKComponentAttachControllerAttachComponentRootLayout(attachController,
                                                                 {.layoutProvider =
                                                                   layoutProvider,
                                                                   .scopeIdentifier = 0x5C09E,
                                                                   .boundsAnimation = {},
                                                                   .view = [UIView new],
                                                                   .analyticsListener = spy});

  XCTAssertEqual(spy->_didCollectAnimationsHitCount, 1);
}

@end
