//
//  TrendingRepoDTO.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrendingRepoDTO : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) int32_t forkCount;
@property (nonatomic, copy, nullable) NSString *language;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int16_t rank;
@property (nonatomic, assign) int32_t starCount;
@property (nonatomic, assign) int32_t starsToday;

+ (instancetype)newWithEntity:(id)entity;

@end

NS_ASSUME_NONNULL_END
