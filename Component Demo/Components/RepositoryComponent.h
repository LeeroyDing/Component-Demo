//
//  RepositoryComponent.h
//  Component Demo
//
//  Created by Sicheng Ding on 24/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@class RepositoryDTO;
@class RepositoryContext;

NS_ASSUME_NONNULL_BEGIN

@interface RepositoryComponent: CKCompositeComponent

+ (instancetype)newWithRepository:(RepositoryDTO *)repository context:(RepositoryContext *)context;

@end

NS_ASSUME_NONNULL_END
