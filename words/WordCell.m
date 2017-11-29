//
//  WordCell.m
//  Words
//
//  Created by Егор Иванов on 15/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "WordCell.h"

@interface WordCell() <UIGestureRecognizerDelegate>
@property UIView *hintBackground;
@property UIView *greenView;
@property UIImageView *checkView;
@property UIView *checkBackground;
@property UILabel *hintLabel;
@property UIColor *greenColor;
@property UIColor *grayColor;
@property CGFloat initialTextOffset;
@property BOOL checked;
@property UILongPressGestureRecognizer *tap;

@property UIView *whiteOverlay;
@property UIView *snapshot;
@property UIView *handle;

@property CGFloat textCenter;
@property CGFloat hintCenter;

@end

@implementation WordCell

-(void)awakeFromNib{
  [super awakeFromNib];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneReordering) name:@"doneReordering" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginReordering) name:@"reorderPlease" object:nil];
  self.contentView.backgroundColor = [UIColor whiteColor];
  self.backgroundColor = [UIColor whiteColor];
  _greenColor = [UIColor colorWithRed:0.32 green:0.8 blue:0.399 alpha:1];
  _grayColor = [UIColor colorWithRed:0.672 green:0.672 blue:0.7 alpha:1];
  _initialTextOffset = CGRectGetMinX(self.textLabel.frame);
  
//  _tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
//  _tap.minimumPressDuration = 0.01;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slide:)];
  pan.delegate = self;
  [self.contentView addGestureRecognizer:pan];
//  [self.contentView addGestureRecognizer:_tap];
  self.contentView.userInteractionEnabled = YES;
  
  _hintBackground = [[UIView alloc] init];
  _hintBackground.backgroundColor = _grayColor;
  [self.contentView addSubview:_hintBackground];
  
  _hintLabel = [[UILabel alloc] init];
  _hintLabel.font = self.textLabel.font;
  _hintLabel.numberOfLines = 0;
  [_hintLabel setAdjustsFontSizeToFitWidth:YES];
  [_hintLabel setMinimumScaleFactor:0.1];
  _hintLabel.textColor = [UIColor whiteColor];
  if (_hintText){
    _hintLabel.text = _hintText;
  }
  [_hintBackground addSubview:_hintLabel];
  
  _checkBackground = [[UIView alloc] init];
  _checkBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
  _checkBackground.clipsToBounds = YES;
  [self.contentView addSubview:_checkBackground];
  
  _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
  [_checkBackground addSubview:_checkView];
}

-(void)beginReordering{
  self.hintBackground.hidden = YES;
}

-(void)setReordering:(BOOL)reordering animated:(BOOL)animated{
  [self.tableView bringSubviewToFront:self];
  _reordering = reordering;
  
  _snapshot = [self.contentView snapshotViewAfterScreenUpdates:YES];
  
  _whiteOverlay = [[UIView alloc] initWithFrame:self.contentView.bounds];
  _whiteOverlay.userInteractionEnabled = YES;
  _whiteOverlay.backgroundColor = [UIColor whiteColor];
  [self.contentView addSubview:_whiteOverlay];
  [self.contentView addSubview:_snapshot];
  
  _handle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(self.contentView.bounds))];
  _handle.backgroundColor = [UIColor blueColor];
  [_snapshot addSubview:_handle];
  _snapshot.userInteractionEnabled = YES;
  _handle.userInteractionEnabled = YES;
  
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHandle:)];
  [_handle addGestureRecognizer:pan];
  
}

-(void)moveHandle:(UIPanGestureRecognizer*)pan{
  
  if (pan.state == UIGestureRecognizerStateEnded){
    [UIView animateWithDuration:0.3
                     animations:^{
                       _snapshot.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
                       _snapshot.transform = CGAffineTransformIdentity;
                     }];
    return;
  }
  
  if (pan.state == UIGestureRecognizerStateBegan){
    [UIView animateWithDuration:0.2
                     animations:^{
                       _snapshot.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }];
  }
  
  CGPoint offset = [pan translationInView:self.contentView];
  _snapshot.center = CGPointMake(_snapshot.center.x + offset.x, _snapshot.center.y + offset.y);
  [pan setTranslation:CGPointZero inView:self.contentView];
}

-(void)doneReordering{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.hintBackground.hidden = NO;
  });
}

-(void)setHintText:(NSString *)hintText{
  _hintText = hintText;
  _hintLabel.text = hintText;
}

-(void)layoutSubviews{
  [super layoutSubviews];
  if (self.textLabel.text.length > 0){
    _initialTextOffset = self.textLabel.frame.origin.x;
  }
  CGPoint center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
  CGFloat xCenter = center.x;
  _hintBackground.frame = self.contentView.bounds;
  _hintBackground.center = CGPointMake(xCenter * 3, _hintBackground.center.y);
  _hintLabel.frame = self.textLabel.frame;
  [self layoutCheckView];
  
  _whiteOverlay.center = center;
  _snapshot.center = center;
  _handle.center = CGPointMake(CGRectGetMaxX(self.contentView.bounds) - CGRectGetWidth(_handle.bounds)/2, center.y);
}

-(void)layoutCheckView{
  CGFloat offset = self.textLabel.frame.origin.x;
  CGFloat width = offset - _initialTextOffset;
  if (width < 0){
    width = 0;
  }
  _checkBackground.frame = CGRectMake(0, 0, width, CGRectGetHeight(self.contentView.bounds));
  _checkView.center = CGPointMake(CGRectGetMidX(_checkBackground.bounds), CGRectGetMidY(_checkBackground.bounds));
  CGRect frame = _checkView.frame;
  frame.origin = CGPointMake(roundf(frame.origin.x), roundf(frame.origin.y));
  _checkView.frame = frame;
}

-(void)slide:(UIPanGestureRecognizer*)pan{
  CGPoint translation = [pan translationInView:self.contentView];

  CGFloat offset = translation.x;
  CGPoint center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
  
  self.textLabel.center = CGPointMake(self.textLabel.center.x + offset, center.y);
  [self layoutCheckView];
  self.hintBackground.center = CGPointMake(self.hintBackground.center.x + offset, center.y);
  
  if (self.textLabel.center.x > CGRectGetWidth(self.contentView.bounds) / 4 * 3){
    self.checked = YES;
          _checkBackground.backgroundColor = _greenColor;
//    [UIView animateWithDuration:0.3 animations:^{
//      self.contentView.backgroundColor = _greenColor;
//      self.textLabel.textColor = [UIColor whiteColor];
//    }];
  }
  else{
    self.checked = NO;
    [UIView animateWithDuration:0.3 animations:^{
//      self.contentView.backgroundColor = [UIColor whiteColor];
//      self.textLabel.textColor = [UIColor blackColor];
      _checkBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];;
    }];
  }
  
  [pan setTranslation:CGPointZero inView:self.contentView];
  
  if (pan.state == UIGestureRecognizerStateEnded){
    
    if (self.checked){
      if (self.rememberBlock){
        self.rememberBlock();
      }
      self.checked = NO;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
//                       self.contentView.backgroundColor = [UIColor whiteColor];
//                       self.textLabel.textColor = [UIColor blackColor];
                       _checkBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];;
                       self.textLabel.center = center;
                       [self layoutCheckView];
                       self.hintBackground.center = CGPointMake(CGRectGetMidX(self.contentView.bounds) * 3, _hintBackground.center.y);
                     }];
  }
}

-(CGSize)sizeThatFits:(CGSize)size{
  CGSize newSize = [super sizeThatFits:size];
  if (newSize.height < 64){
    newSize.height = 64;
  }
  return newSize;
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

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end




