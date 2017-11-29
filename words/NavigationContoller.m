//
//  NavigationContoller.m
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "NavigationContoller.h"
#import "NewWordVC.h"
#import "Word.h"
#import "WordsTVC.h"

@interface NavigationContoller ()

@end

@implementation NavigationContoller

-(void)openComposerForWord:(Word*)word index:(NSInteger)index{
  NewWordVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"modalVC"];
  if (word){
    [vc setWord:word forIndex:index];
  }
  
  __weak typeof(vc) weakVC = vc;
  [vc setCancel:^{
    [weakVC dismissViewControllerAnimated:YES completion:nil];
    [self zoomBackIn];
  }];
  
  [vc setSave:^(Word *word, NSInteger index) {
    [weakVC dismissViewControllerAnimated:YES completion:nil];
    [self zoomBackIn];
    [self addWord:word forIndex:index];
  }];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
  [vc setModalPresentationStyle:UIModalPresentationOverFullScreen];
  [self presentViewController:vc animated:YES completion:nil];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.view.alpha = 0.7;
                     self.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
                   }];
}

-(void)addWord:(Word*)word forIndex:(NSInteger)index{
  WordsTVC *words = [self.viewControllers lastObject];
  [words addWord:word forIndex:index];
}

-(void)zoomBackIn{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.view.alpha = 1.0;
                     self.view.transform = CGAffineTransformIdentity;
                   }];
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
