//
//  WordsTVC.m
//  Words
//
//  Created by Егор Иванов on 13/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "WordsTVC.h"
#import "NavigationContoller.h"
#import "WordCell.h"
#import "Notebook.h"
#import "NewWordVC.h"
#import "FlipButton.h"
#import "Button.h"

@interface WordsTVC () <UIGestureRecognizerDelegate>
@property UIBarButtonItem *plusButton;
@property UIBarButtonItem *swapButton;
@property UILongPressGestureRecognizer *tap;
@property FlipButton *flipButtonView;
@property BOOL actionSheetIsOnscreen;

@property Button *zeroStateButton;

@end

@implementation WordsTVC

-(void)awakeFromNib{
  [super awakeFromNib];
  _plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
    target:self action:@selector(openComposer)];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorder) name:@"reorderPlease" object:nil];

  self.tableView.estimatedRowHeight = 64;
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [self setFlipButtonAnimated:NO];
}

-(void)setFlipButtonAnimated:(BOOL)animated{
  UIImage *flipFace = [[UIImage imageNamed:@"flipFace"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  UIImage *flipBack = [[UIImage imageNamed:@"flipBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  UIImage *flipIcon = _notebook.showWords ? flipFace : flipBack;
  NSLog(@"Notebook %@", _notebook);
  
  if (!_swapButton){
    _flipButtonView = [[FlipButton alloc] initWithFrame:CGRectMake(0, 0, flipIcon.size.width, flipIcon.size.height)];
    [_flipButtonView setImage:flipIcon forState:UIControlStateNormal];
    [_flipButtonView addTarget:self action:@selector(swap) forControlEvents:UIControlEventTouchUpInside];
    _swapButton = [[UIBarButtonItem alloc] initWithCustomView:_flipButtonView];
    self.navigationItem.rightBarButtonItems = @[_plusButton, _swapButton];
  }
  
  if (animated){
    UIViewAnimationOptions options = _notebook.showWords ?
      UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft;
    
    [UIView transitionWithView:_flipButtonView
                      duration:0.3
                       options:options
                    animations:^{
                      [_flipButtonView setImage:flipIcon forState:UIControlStateNormal];
                    } completion:nil];
  }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
  if (motion == UIEventSubtypeMotionShake){
    [self askHowToSort];
  }
}

-(void)askHowToSort{
  if (_notebook.words.count < 3){
    return;
  }
  if (_actionSheetIsOnscreen){
    return;
  }
  _actionSheetIsOnscreen = YES;
  
  NSString *title = NSLocalizedString(@"sortAlertTitle", nil);
  NSString *message = NSLocalizedString(@"sortAlertMessage", nil);
  NSString *alphabeticallyButton = NSLocalizedString(@"sortAlphabetically", nil);
  NSString *randomlyButton = NSLocalizedString(@"sortRandomly", nil);
  NSString *cancelButton = NSLocalizedString(@"sortCancel", nil);
  
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
  
  UIAlertAction *alphabetically = [UIAlertAction actionWithTitle:alphabeticallyButton style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                           [self sortRandomly:NO];
                                                         }];
  
  UIAlertAction *randomly = [UIAlertAction actionWithTitle:randomlyButton style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                           [self sortRandomly:YES];
                                                         }];
  
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                           _actionSheetIsOnscreen = NO;
                                                         }];
  [alert addAction:alphabetically];
  [alert addAction:randomly];
  [alert addAction:cancel];
  [self presentViewController:alert animated:YES completion:nil];
}

-(void)sortRandomly:(BOOL)randomly{
  _actionSheetIsOnscreen = NO;
  NSMutableArray *temp = [_notebook.words mutableCopy];
  if (randomly){
    NSUInteger count = _notebook.words.count;
    for (NSUInteger i = 0; i < count; i++) {
      NSInteger remainingCount = count - i;
      NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
      [temp exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
      NSLog(@"Rand %@", @(i));
    }
    _notebook.words = [NSArray arrayWithArray:temp];
  }
  else{
    
    NSMutableArray *learned = [NSMutableArray new];
    NSMutableArray *notLearned = [NSMutableArray new];
    
    for (Word *word in _notebook.words) {
      if (word.learned){
        [learned addObject:word];
        continue;
      }
      [notLearned addObject:word];
    }
    
    learned = [[learned sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      NSString *first = _notebook.showWords ? [(Word*)obj1 hintText] : [(Word*)obj1 wordText];
      NSString *second = _notebook.showWords ? [(Word*)obj2 hintText] : [(Word*)obj2 wordText];
      return [first compare:second];
    }] mutableCopy];
    
    notLearned = [[notLearned sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      NSString *first = _notebook.showWords ? [(Word*)obj1 hintText] : [(Word*)obj1 wordText];
      NSString *second = _notebook.showWords ? [(Word*)obj2 hintText] : [(Word*)obj2 wordText];
      return [first compare:second];
    }] mutableCopy];
    
    _notebook.words = [notLearned arrayByAddingObjectsFromArray:learned];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"saveFolders" object:nil];
  [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  return CGFLOAT_MIN;
}

-(void)reorder{
  self.tableView.delaysContentTouches = NO;
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    target:self action:@selector(doneReordering)];
  self.navigationItem.rightBarButtonItems = @[done];
  [self.tableView setEditing:YES animated:YES];
}

-(void)doneReordering{
  [self.tableView setEditing:NO animated:YES];
  UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  self.navigationItem.rightBarButtonItems = @[_plusButton, space, _swapButton, space, space, space];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"doneReordering" object:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
  [_notebook moveWordAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
  tableView.delaysContentTouches = NO;
}

-(void)swap{
  UIView *snap = [self.tableView snapshotViewAfterScreenUpdates:YES];
  [self.tableView addSubview:snap];
  
  self.notebook.showWords = !self.notebook.showWords;
  [self.tableView reloadData];
  
  UIViewAnimationOptions options = _notebook.showWords ?
    UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft;
  
  [self setFlipButtonAnimated:YES];
  [UIView transitionWithView:self.tableView
                    duration:0.3
                     options:options
                  animations:^{
                    [snap removeFromSuperview];
                  } completion:nil];
}

-(void)addWord:(Word *)word forIndex:(NSInteger)index{
  [_notebook addWord:word forIndex:index];
  [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

-(void)viewWillLayoutSubviews{
  [super viewWillLayoutSubviews];
  for (NSIndexPath *indexpath in self.tableView.indexPathsForVisibleRows) {
    WordCell *cell = (WordCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    cell.indexPath = indexpath;
  }
  _zeroStateButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
  CGRect rect = _zeroStateButton.frame;
  rect.origin.x = roundf(rect.origin.x);
  rect.origin.y = roundf(rect.origin.y);
  _zeroStateButton.frame = rect;
}

-(void)openComposer{
  NavigationContoller *nc = (NavigationContoller*)self.navigationController;
  [nc openComposerForWord:nil index:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)hideZeroStateButton{
  if (!_zeroStateButton){
    return;
  }
  [UIView animateWithDuration:0.5
                   animations:^{
                     self.zeroStateButton.alpha = 0.0;
                   }completion:^(BOOL finished) {
                     [self.zeroStateButton removeFromSuperview];
                     self.zeroStateButton = nil;
                   }];
}

-(void)showZeroStateButton{
  if (_zeroStateButton){
    return;
  }
  _zeroStateButton = [[Button alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 80, 64)];
  [_zeroStateButton setTitle:NSLocalizedString(@"zeroState", nil) forState:UIControlStateNormal];
  [_zeroStateButton addTarget:self action:@selector(openComposer) forControlEvents:UIControlEventTouchUpInside];
  _zeroStateButton.alpha = 0.0;
  [self.tableView addSubview:self.zeroStateButton];
  [UIView animateWithDuration:0.5
                   animations:^{
                     self.zeroStateButton.alpha = 1.0;
                   }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = _notebook.words.count;
  BOOL notEmpty = count > 0;
  
  tableView.separatorStyle = notEmpty ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
  UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  self.navigationItem.rightBarButtonItems = notEmpty ? @[_plusButton, space, _swapButton, space, space, space] : nil;

  if (notEmpty) {
    [self hideZeroStateButton];
  }
  else{
    [self showZeroStateButton];
  }
  
  return count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  Word *word = _notebook.words[indexPath.row];
  [self.notebook removeWordAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  NavigationContoller *nc = (NavigationContoller*)self.navigationController;
  [nc openComposerForWord:word index:indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  WordCell *cell = (WordCell*)[tableView dequeueReusableCellWithIdentifier:@"wordsCell" forIndexPath:indexPath];
  __weak WordCell *weakCell = cell;
  cell.rememberBlock = ^{
    Word *word = self.notebook.words[weakCell.indexPath.row];
    word.learned = !word.learned;
    weakCell.textLabel.textColor = word.learned ? [UIColor lightGrayColor] : [UIColor blackColor];
    if (word.learned){
      [self.notebook postponeWordFromIndex:weakCell.indexPath.row];
      [tableView moveRowAtIndexPath:weakCell.indexPath toIndexPath:[NSIndexPath indexPathForRow:_notebook.words.count - 1 inSection:0]];
    }
  };
  
  Word *word = _notebook.words[indexPath.row];
  
  cell.textLabel.text = _notebook.showWords ? word.hintText : word.wordText;
  cell.hintText = _notebook.showWords ? word.wordText : word.hintText;
  
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.textColor = word.learned ? [UIColor lightGrayColor] : [UIColor blackColor];
  CGRect frame = cell.textLabel.frame;
  frame.size = [cell.textLabel sizeThatFits:CGSizeMake(CGRectGetWidth(cell.textLabel.frame), MAXFLOAT)];
  cell.textLabel.frame = frame;
  [cell sizeToFit];
  
  return cell;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
  NSLog(@"Hey its %@", [gestureRecognizer class]);
  return YES;
}


-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
