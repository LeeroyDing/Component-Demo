//
//  Initializer.m
//  Component Demo
//
//  Created by Sicheng Ding on 24/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "Initializer.h"
#import "RepositoriesCollectionViewController.h"

@implementation Initializer

+ (UIViewController *)getRootViewController {
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  [flowLayout setMinimumInteritemSpacing:0];
  [flowLayout setMinimumLineSpacing:0];

  RepositoriesCollectionViewController *viewController = [[RepositoriesCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
  return viewController;
}

@end
