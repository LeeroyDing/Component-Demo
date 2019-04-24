/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKBuildComponent.h>
#import <ComponentKit/CKComponentHostingView.h>
#import <ComponentKit/CKComponentHostingViewProtocol.h>
#import <ComponentKit/CKDimension.h>
#import <ComponentKit/CKComponentLayout.h>
#import <ComponentKit/CKComponentScopeHandle.h>
#import <ComponentKit/CKComponentScopeRoot.h>
#import <ComponentKit/CKComponentScopeTypes.h>
#import <ComponentKit/CKInspectableView.h>

#import <unordered_set>

struct CKComponentHostingViewOptions {
  /// If set to YES, allows taps to pass though this hosting view to views behind it. Default NO.
  BOOL allowTapPassthrough;
  // If set to YES, invalidates controllers that are removed whilst the hosting view remains alive. Default NO.
  BOOL invalidateRemovedControllers;
};

@interface CKComponentHostingView () <CKComponentHostingViewProtocol, CKComponentStateListener>

/**
 @param componentProvider  provider conforming to CKComponentProvider protocol.
 @param sizeRangeProvider sizing range provider conforming to CKComponentSizeRangeProviding.
 @param componentPredicates A vector of C functions that are executed on each component constructed within the scope
                            root. By passing in the predicates on initialization, we are able to cache which components
                            match the predicate for rapid enumeration later.
 @param componentControllerPredicates Same as componentPredicates above, but for component controllers.
 @param analyticsListener listener conforming to AnalyticsListener will be used to get component lifecycle callbacks for logging
 @param options Set of CKComponentHostingViewOptions
 @see CKComponentProvider
 @see CKComponentSizeRangeProviding
 */
- (instancetype)initWithComponentProvider:(Class<CKComponentProvider>)componentProvider
                        sizeRangeProvider:(id<CKComponentSizeRangeProviding>)sizeRangeProvider
                      componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
            componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                        analyticsListener:(id<CKAnalyticsListener>)analyticsListener
                                  options:(const CKComponentHostingViewOptions &)options;

- (instancetype)initWithComponentProviderFunc:(CKComponentProviderFunc)componentProvider
                            sizeRangeProvider:(id<CKComponentSizeRangeProviding>)sizeRangeProvider
                          componentPredicates:(const std::unordered_set<CKComponentPredicate> &)componentPredicates
                componentControllerPredicates:(const std::unordered_set<CKComponentControllerPredicate> &)componentControllerPredicates
                            analyticsListener:(id<CKAnalyticsListener>)analyticsListener
                                      options:(const CKComponentHostingViewOptions &)options;

@property (nonatomic, strong, readonly) UIView *containerView;

/** Applies a result from a component built outside the hosting view. Main thread only. */
- (void)applyResult:(const CKBuildComponentResult &)result;

/**
 Function for setting default analytics listener that will be used if CKComponentHostingView doesn't have one

 @param defaultListener Analytics listener to be used if CKComponentHostingView don't inject one

 @warning This method is affined to the main thread and should only be called from it.
          You shouldn't set analytics listener more then once - this will cause a confusion on which one is used.
          If you want to pass a custom analytics listener to a particular hosting view, please use
           initWithComponentProvider:sizeRangeProvider:analyticsListener: to create it
 */

+ (void)setDefaultAnalyticsListener:(id<CKAnalyticsListener>)defaultListener;

@end
