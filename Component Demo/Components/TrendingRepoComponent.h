//
//  TrendingRepoComponent.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TrendingRepoDTO;
@class TrendingRepoContext;

@interface TrendingRepoComponent: CKCompositeComponent

+ (instancetype)newWithTrendingRepo:(TrendingRepoDTO *)trendingRepo context:(TrendingRepoContext *)context;

@end

NS_ASSUME_NONNULL_END
