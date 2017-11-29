//
//  ComposerTVC.m
//  Words
//
//  Created by Егор Иванов on 16/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "ComposerTVC.h"
#import "ComposerCell.h"

@interface ComposerTVC ()
@property NSString *word;
@property NSString *hint;
@end

@implementation ComposerTVC

#pragma mark - Table view data source

-(void)awakeFromNib{
  [super awakeFromNib];
  self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
  self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 64.0;
}

-(void)openKeyboard{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [cell.textView becomeFirstResponder];
}

-(void)closeKeyboard{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [cell.textView resignFirstResponder];
  cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
  [cell.textView resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(void)setWordText:(NSString *)text{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  cell.textView.text = text;
  if (!cell){
    _word = text;
  }
}

-(void)setHintText:(NSString *)text{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
  cell.textView.text = text;
  if (!cell){
    NSLog(@"Settint hint property because cell is nil");
    _hint = text;
  }
  
}

-(NSString *)wordText{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  return cell.textView.text;
}

-(NSString *)hintText{
  ComposerCell *cell = (ComposerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
  return cell.textView.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ComposerCell *cell = (ComposerCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];

  NSString *word = NSLocalizedString(@"wordTitle", nil);
  NSString *hint = NSLocalizedString(@"hintTitle", nil);
  
  switch (indexPath.row) {
    case 0:
      cell.placeholder = word;
      if (_word){
        NSLog(@"Setting word %@", _word);
        cell.textView.text = _word;
      }
      break;
    case 1:
      cell.placeholder = hint;
      if (_hint){
        NSLog(@"Setting hint %@", _hint);
        cell.textView.text = _hint;
      }
    default:
      break;
  }
  cell.tableView = tableView;
  [cell sizeToFit];
    
  return cell;
}



@end
