//
//  TrendingRepoDTO.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "TrendingRepoDTO.h"
#import "Component_Demo-Swift.h"

@implementation TrendingRepoDTO

+ (instancetype)newWithEntity:(id)entity {
  TrendingRepo *repo = entity;
  TrendingRepoDTO *dto = [[TrendingRepoDTO alloc] init];
  dto.author = repo.author;
  dto.desc = repo.desc;
  dto.forkCount = repo.forkCount;
  dto.language = repo.language;
  dto.name = repo.name;
  dto.rank = repo.rank;
  dto.starCount = repo.starCount;
  dto.starsToday = repo.starsToday;
  return dto;
}

@end
