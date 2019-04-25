//
//  RepositoryDTO.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "RepositoryDTO.h"
#import "Component_Demo-Swift.h"

@implementation RepositoryDTO

+ (instancetype)newFromEntity:(id)entity {
  Repository *repo = entity;
  RepositoryDTO *dto = [RepositoryDTO new];
  dto.id = repo.id;
  dto.name = repo.name;
  dto.pushedAt = repo.pushedAt;
  return dto;
}

- (NSString *)debugDescription {
  return [NSString stringWithFormat:@"%lld: %@", self.id, self.name];
}

@end
