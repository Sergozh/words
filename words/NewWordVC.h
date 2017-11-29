//
//  NewWordVC.h
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;

@interface NewWordVC : UIViewController

@property (nonatomic) Word *word;
@property NSInteger wordIndex;
-(void)setWord:(Word *)word forIndex:(NSInteger)index;

@property (nonatomic, copy) void (^cancel)(void);
@property (nonatomic, copy) void (^save)(Word *word, NSInteger index);

@end
