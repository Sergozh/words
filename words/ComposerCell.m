//
//  ComposerCell.m
//  Words
//
//  Created by Егор Иванов on 16/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "ComposerCell.h"

@interface ComposerCell()

@property CGFloat textHeight;

@end

@implementation ComposerCell

- (void)awakeFromNib {
  [super awakeFromNib];
  _textView.delegate = self;
  _textView.font = [UIFont systemFontOfSize:17];
  _textView.textContainerInset = UIEdgeInsetsMake(20, 15, 20, 15);
  _textView.scrollEnabled = NO;
  [self.contentView addSubview:_textView];
  [self textViewDidChange:_textView];
}

-(void)setPlaceholder:(NSString *)placeholder{
  _placeholder = placeholder;
  _textView.placeholder = placeholder;
}
-(void)textViewDidChange:(UITextView *)textView{
  
  CGSize size = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.contentView.bounds), CGFLOAT_MAX)];
  
  if (_textHeight != size.height){
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
  }
  
  _textHeight = size.height;
}


@end
