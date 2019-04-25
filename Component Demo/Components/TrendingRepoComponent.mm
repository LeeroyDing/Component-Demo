//
//  TrendingRepoComponent.m
//  Component Demo
//
//  Created by Sicheng Ding on 25/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "TrendingRepoComponent.h"
#import "TrendingRepoDTO.h"

@implementation TrendingRepoComponent

+ (instancetype)newWithTrendingRepo:(TrendingRepoDTO *)trendingRepo context:(TrendingRepoContext *)context {
  CKComponent *fullName =
  [CKLabelComponent
   newWithLabelAttributes:{
     .string = [NSString stringWithFormat:@"%@ / %@",
                trendingRepo.author,
                trendingRepo.name]
   }
   viewAttributes:{}
   size:{}];
  CKComponent *description =
  [CKLabelComponent
   newWithLabelAttributes:{
     .string = trendingRepo.desc
   }
   viewAttributes:{}
   size:{}];
  CKComponent *language =
  [CKLabelComponent
   newWithLabelAttributes:{
     .string = trendingRepo.language ?: @"None"
   }
   viewAttributes:{}
   size:{}];
  CKComponent *stars =
  [CKLabelComponent
   newWithLabelAttributes:{
     .string = [NSString stringWithFormat:@"Stars: %d", trendingRepo.starCount]
   }
   viewAttributes:{}
   size:{}];
  CKComponent *forks =
  [CKLabelComponent
   newWithLabelAttributes:{
     .string = [NSString stringWithFormat:@"Forks: %d", trendingRepo.forkCount]
   }
   viewAttributes:{}
   size:{}];
  CKComponent *top = fullName;
  CKComponent *body = description;
  CKComponent *bottom =
  [CKFlexboxComponent
   newWithView:{
     [UIView class], {}
   }
   size:{}
   style:{
     .direction = CKFlexboxDirectionRow,
     .spacing = 12,
     .alignItems = CKFlexboxAlignItemsStretch,
   }
   children:{
     {language}, {stars}, {forks}
   }];

  return
  [super newWithComponent:
   [CKFlexboxComponent
    newWithView:{
      [UIView class], {}
    }
    size:{}
    style:{
      .direction = CKFlexboxDirectionColumn,
      .spacing = 8,
      .alignContent = CKFlexboxAlignContentSpaceBetween,
      .alignItems = CKFlexboxAlignItemsStretch,
    }
    children:{
      {top}, {body}, {bottom}
    }]];
}

@end
