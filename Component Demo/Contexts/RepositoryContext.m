//
//  RepositoryContext.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "RepositoryContext.h"
#import "Component_Demo-Swift.h"

@implementation RepositoryContext

+ (instancetype)newContext {
  return [[RepositoryContextImpl alloc] init];
}

@end
