//
//  RepositoryDTO.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RepositoryDTO : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy, nonnull) NSString *name;
@property (nonatomic, copy, nonnull) NSDate *pushedAt;

+ (instancetype)newFromEntity:(id)entity;

@end

NS_ASSUME_NONNULL_END
