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

/// This class wraps around CKDataSourceChangesetBuilder
/// Because calling insert items method multiple times in the original
/// changeset builder will override the previous result, instead of appending
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
