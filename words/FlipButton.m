//
//  FlipButton.m
//  Words
//
//  Created by Егор Иванов on 20/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "FlipButton.h"

@implementation FlipButton

-(void)setHighlighted:(BOOL)highlighted{
  self.alpha = highlighted ? 0.2 : 1.0;
}

@end
