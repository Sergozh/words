//
//  NavigationContoller.h
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;
@interface NavigationContoller : UINavigationController
-(void)openComposerForWord:(Word*)word index:(NSInteger)index;

@end
