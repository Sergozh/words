  //
  //  UIPlaceHolderTextView.m
  //  Words
  //
  //  Created by Егор Иванов on 14/02/15.
  //  Copyright (c) 2015 hey. All rights reserved.
  //

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView ()

@property (nonatomic, copy) UITextView *placeHolderView;

@end

@implementation UIPlaceHolderTextView

- (void)textChanged{
  if(_placeholder.length == 0){
    return;
  }
  
  if(self.text.length == 0){
    _placeHolderView.hidden = NO;
  }
  else{
    _placeHolderView.hidden = YES;
  }
}

- (void)setText:(NSString *)text {

  [super setText:text];
  [self textChanged];
}

//- (void)drawRect:(CGRect)rect
//{
//  if(_placeholder.length > 0 ){
//    if (!_placeHolderView){
//      _placeHolderView = self;
//      _placeHolderView.textColor = [UIColor lightGrayColor];
//      _placeHolderView.text = _placeholder;
//      _placeHolderView.userInteractionEnabled = NO;
//    }
//  }
//  
//  if(self.text.length == 0 && _placeholder.length > 0 ){
//    _placeHolderView.hidden = NO;
//  }
//  
//  [super drawRect:rect];
//}

@end
