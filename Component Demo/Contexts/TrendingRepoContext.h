//
//  TrendingRepoContext.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchedResultsController;

NS_ASSUME_NONNULL_BEGIN

@interface TrendingRepoContext : NSObject

+ (instancetype)newContext;
- (void)fetchTrendingRepos:(void (^_Nonnull)(void))completion;;
- (NSFetchedResultsController *)trendingRepoList;

@end

NS_ASSUME_NONNULL_END
