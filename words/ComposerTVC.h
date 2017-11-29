//
//  ComposerTVC.h
//  Words
//
//  Created by Егор Иванов on 16/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposerTVC : UITableViewController
-(NSString*)wordText;
-(NSString*)hintText;
-(void)setWordText:(NSString*)text;
-(void)setHintText:(NSString*)text;
-(void)openKeyboard;
-(void)closeKeyboard;

@end
