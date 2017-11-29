//
//  ComposerCell.h
//  Words
//
//  Created by Егор Иванов on 16/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"

@interface ComposerCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet SAMTextView *textView;
@property (nonatomic) NSString *placeholder;
@property UITableView *tableView;

@end


