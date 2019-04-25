//
//  TrendingRepoContext.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "TrendingRepoContext.h"
#import "Component_Demo-Swift.h"

@implementation TrendingRepoContext

+ (instancetype)newContext {
  return [[TrendingRepoContextImpl alloc] init];
}

- (void)fetchTrendingRepos:(void (^)(void))completion {
  [self doesNotRecognizeSelector:_cmd];
}

- (NSFetchedResultsController *)trendingRepoList {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
