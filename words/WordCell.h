//
//  WordCell.h
//  Words
//
//  Created by Егор Иванов on 15/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordCell : UITableViewCell
@property (nonatomic) NSString *hintText;
@property NSIndexPath *indexPath;
@property (nonatomic, copy) void (^rememberBlock)(void);
@property UITableView *tableView;

@property (readonly) BOOL reordering;
-(void)setReordering:(BOOL)reordering animated:(BOOL)animated;

@end
