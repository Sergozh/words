//
//  WordsTVC.h
//  Words
//
//  Created by Егор Иванов on 13/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordsTVC.h"
#import "Word.h"
#import "Notebook.h"

@interface WordsTVC : UITableViewController

@property Notebook *notebook;
-(void)addWord:(Word *)word forIndex:(NSInteger)index;

@end
