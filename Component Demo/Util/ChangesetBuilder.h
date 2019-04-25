//
//  ChangesetBuilder.h
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/ComponentKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangesetBuilder<__covariant ModelType> : NSObject

- (instancetype)withUpdatedItems:(NSDictionary<NSIndexPath *, ModelType> *)updatedItems;
- (instancetype)withRemovedItems:(NSSet *)removedItems;
- (instancetype)withRemovedSections:(NSIndexSet *)removedSections;
- (instancetype)withMovedItems:(NSDictionary<NSIndexPath *, NSIndexPath *> *)movedItems;
- (instancetype)withInsertedSections:(NSIndexSet *)insertedSections;
- (instancetype)withInsertedItems:(NSDictionary<NSIndexPath *, ModelType> *)insertedItems;
- (CKDataSourceChangeset<ModelType> *)build;

@end

NS_ASSUME_NONNULL_END
