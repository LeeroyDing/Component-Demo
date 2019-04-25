//
//  RepositoriesCollectionViewController.mm
//  Component Demo
//
//  Created by Sicheng Ding on 24/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "RepositoriesCollectionViewController.h"
#import <ComponentKit/ComponentKit.h>
#import <CoreData/CoreData.h>

#import "RepositoryComponent.h"
#import "RepositoryDTO.h"
#import "RepositoryContext.h"
#import "ChangesetBuilder.h"

@interface RepositoriesCollectionViewController () <CKComponentProvider, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) CKCollectionViewDataSource *dataSource;
@property (nonatomic, retain) CKComponentFlexibleSizeRangeProvider *sizeRangeProvider;
@property (nonatomic, retain, nullable) ChangesetBuilder *changesetBuilder;
@property (nonatomic, retain, nullable) NSFetchedResultsController *frc;
@property (nonatomic, retain, nullable) RepositoryContext *repositoryContext;

@end

@implementation RepositoriesCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  if (self = [super initWithCollectionViewLayout:layout]) {
    self.sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
  }
  self.title = @"My Repositories";
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.delegate = self;

  RepositoryContext *context = [RepositoryContext newContext];

  // Size configuration
  const CKSizeRange sizeRange = [self.sizeRangeProvider sizeRangeForBoundingSize:self.collectionView.bounds.size];
  CKDataSourceConfiguration *configuration =
  [[CKDataSourceConfiguration alloc] initWithComponentProvider:[self class]
                                                       context:context
                                                     sizeRange:sizeRange];

  // Create data source
  self.dataSource = [[CKCollectionViewDataSource alloc]
                     initWithCollectionView:self.collectionView
                     supplementaryViewDataSource:nil
                     configuration:configuration];

  self.frc = [context repositoriesList];
  self.frc.delegate = self;
  [self.frc performFetch:nil];
  self.repositoryContext = context;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.repositoryContext fetchRepositories];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
  [self.dataSource announceWillDisplayCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
  [self.dataSource announceDidEndDisplayingCell:cell];
}

#pragma mark - CKComponentProvider

+ (CKComponent *)componentForModel:(RepositoryDTO *)repository context:(RepositoryContext *)context
{
  return [RepositoryComponent newWithRepository:repository context:context];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  NSLog(@"Change begins");
  self.changesetBuilder = [[ChangesetBuilder new] withInsertedSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  NSLog(@"section %lu: %ld", (unsigned long)sectionIndex, type);
  switch(type) {
    case NSFetchedResultsChangeInsert:
      self.changesetBuilder = [self.changesetBuilder withInsertedSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;

    case NSFetchedResultsChangeDelete:
      self.changesetBuilder = [self.changesetBuilder withRemovedSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      break;

    default: break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  RepositoryDTO *dto = [RepositoryDTO newFromEntity:anObject];
  NSLog(@"item %@ from %@ to %@, %lu",
        dto.debugDescription,
        indexPath.debugDescription,
        newIndexPath.debugDescription,
        (unsigned long)type
        );
  switch(type) {
    case NSFetchedResultsChangeInsert:
      self.changesetBuilder = [self.changesetBuilder withInsertedItems:@{newIndexPath: dto}];
      break;

    case NSFetchedResultsChangeDelete:
      self.changesetBuilder = [self.changesetBuilder withRemovedItems:[NSSet setWithObject:indexPath]];
      break;

    case NSFetchedResultsChangeUpdate:
      self.changesetBuilder = [self.changesetBuilder withUpdatedItems:@{indexPath: dto}];
      break;

    case NSFetchedResultsChangeMove:
      self.changesetBuilder = [self.changesetBuilder withMovedItems:@{indexPath: newIndexPath}];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  NSLog(@"Change ends");
  CKDataSourceChangeset *changeset = [self.changesetBuilder build];
  [self.dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
  self.changesetBuilder = nil;
}

@end
