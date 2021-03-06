//
//  RepositoryContext.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchedResultsController;

NS_ASSUME_NONNULL_BEGIN

/// This class is a bridge to introduce the underlying Swift context to the View Controller
@interface RepositoryContext : NSObject

+ (instancetype)newContext;
- (void)fetchRepositories:(void (^_Nonnull)(void))completion;;
- (NSFetchedResultsController *)repositoriesList;

@end

NS_ASSUME_NONNULL_END
