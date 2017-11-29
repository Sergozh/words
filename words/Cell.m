//
//  Cell.m
//  Words
//
//  Created by Егор on 30/03/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "Cell.h"

@interface Cell()
@end

@implementation Cell

-(void)enableFolderIcon{
  if (!self.imageView.image){
    self.imageView.image = [[UIImage imageNamed:@"folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
  
  if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer){
    NSLog(@"Long press!");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reorderPlease" object:nil];
    return NO;
  }
  
  if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
    CGPoint velociy = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self.contentView];
    if (fabs(velociy.x) > fabs(velociy.y)){
      return YES;
    }
    return NO;
  }
  return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
