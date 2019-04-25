//
//  ChangesetBuilder.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "ChangesetBuilder.h"

@implementation ChangesetBuilder

{
  NSMutableDictionary *_updatedItems;
  NSMutableSet *_removedItems;
  NSMutableIndexSet *_removedSections;
  NSMutableDictionary *_movedItems;
  NSMutableIndexSet *_insertedSections;
  NSMutableDictionary *_insertedItems;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _updatedItems = [NSMutableDictionary new];
    _removedItems = [NSMutableSet new];
    _removedSections = [NSMutableIndexSet new];
    _movedItems = [NSMutableDictionary new];
    _insertedSections = [NSMutableIndexSet new];
    _insertedItems = [NSMutableDictionary new];
  }
  return self;
}

- (instancetype)withUpdatedItems:(NSDictionary *)updatedItems {
  [_updatedItems addEntriesFromDictionary:updatedItems];
  return self;
}

- (instancetype)withRemovedItems:(NSSet *)removedItems {
  [_removedItems unionSet:removedItems];
  return self;
}

- (instancetype)withRemovedSections:(NSIndexSet *)removedSections {
  [_removedSections addIndexes:removedSections];
  return self;
}

- (instancetype)withMovedItems:(NSDictionary *)movedItems {
  [_movedItems addEntriesFromDictionary:movedItems];
  return self;
}

- (instancetype)withInsertedSections:(NSIndexSet *)insertedSections {
  [_insertedSections addIndexes:insertedSections];
  return self;
}

- (instancetype)withInsertedItems:(NSDictionary *)insertedItems {
  [_insertedItems addEntriesFromDictionary:insertedItems];
  return self;
}

- (CKDataSourceChangeset *)build
{
  return [[[[[[[[CKDataSourceChangesetBuilder transactionalComponentDataSourceChangeset]
         withUpdatedItems:_updatedItems]
        withRemovedItems:_removedItems]
       withRemovedSections:_removedSections]
      withMovedItems:_movedItems]
     withInsertedSections:_insertedSections]
    withInsertedItems:_insertedItems]
   build];
}

@end
