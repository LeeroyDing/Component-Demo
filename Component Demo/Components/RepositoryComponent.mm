//
//  RepositoryComponent.m
//  Component Demo
//
//  Created by Sicheng Ding on 24/04/2019.
//  Copyright © 2019 IG Group. All rights reserved.
//

#import "RepositoryComponent.h"
#import "RepositoryDTO.h"

@implementation RepositoryComponent

+ (instancetype)newWithRepository:(RepositoryDTO *)repository
                          context:(RepositoryContext *)context {
  RepositoryComponent *c =
  [super
   newWithView:{
     [UIView class],
     {CKComponentTapGestureAttribute(@selector(didTap))}
   }
   component:
   [CKCenterLayoutComponent
    newWithCenteringOptions:CKCenterLayoutComponentCenteringXY
    sizingOptions:CKCenterLayoutComponentSizingOptionDefault
    child:
    [CKLabelComponent
     newWithLabelAttributes:{
       .string = repository.name,
       .alignment = NSTextAlignmentCenter
     }
     viewAttributes:{
       {@selector(setUserInteractionEnabled:), @NO}
     }
     size:{}]
    size:{
      .height = 44
    }
    ]
   ];
  return c;
}

- (void)didTap {
  NSLog(@"Oops");
}

@end
