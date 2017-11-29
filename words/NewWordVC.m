//
//  NewWordVC.m
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "NewWordVC.h"
#import "Word.h"
#import "SAMTextView.h"
#import "ComposerTVC.h"

@interface NewWordVC ()

@property UIView *whiteView;
@property UINavigationBar *toolbar;
@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *cancelButton;
@property SAMTextView *wordTextView;
@property SAMTextView *hintTextView;
@property UIScrollView *scroll;
@property UIView *separator;
@property CGFloat keyboardHeight;
@property ComposerTVC *tvc;

@end

@implementation NewWordVC

-(void)awakeFromNib{
  [super awakeFromNib];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                               name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange)
                                               name:UITextViewTextDidChangeNotification object:nil];

  self.view.backgroundColor = [UIColor clearColor];
  CGRect frame = self.view.bounds;
  CGFloat originY = CGRectGetHeight(self.view.bounds) * 0.05 + 10;
  NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"composerYOffset"];
  if (num){
    originY = [num floatValue];
  }
  frame.origin.y = originY;
  frame.size.height -= originY;
  _whiteView = [[UIView alloc] initWithFrame:frame];
  _whiteView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_whiteView];
  frame.origin = CGPointZero;
  frame.size.height = 44;
  _toolbar = [[UINavigationBar alloc] initWithFrame:frame];
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertically:)];
  [_toolbar addGestureRecognizer:pan];
  [_whiteView addSubview:_toolbar];
  
  _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                              target:self action:@selector(done)];
  NSString *cancelTitle = NSLocalizedString(@"cancelTitle", nil);
  _cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(delete)];
  [_toolbar pushNavigationItem:self.navigationItem animated:NO];
  self.navigationItem.leftBarButtonItem = _cancelButton;
  self.navigationItem.rightBarButtonItem = _doneButton;
  _doneButton.enabled = NO;
  NSString *title = NSLocalizedString(@"newWord", nil);
  self.navigationItem.title = title;
  [self setup];
}

-(void)setWord:(Word *)word forIndex:(NSInteger)index{
  _word = word;
  _wordIndex = index;
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete)];
  self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
  _doneButton.enabled = YES;
  [_tvc setHintText:word.hintText];
  [_tvc setWordText:word.wordText];
}

-(void)setup{
  CGRect frame = _whiteView.bounds;
  
  _tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ComposerTVC"];
  _tvc.tableView.frame = frame;
  [_whiteView insertSubview:_tvc.tableView belowSubview:_toolbar];
}

-(void)keyboardDidShow:(NSNotification*)notification{
  _keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
  CGFloat max = CGRectGetHeight(self.view.bounds) - _keyboardHeight - 100;
  if (self.whiteView.frame.origin.y > max){
    CGRect frame = self.whiteView.frame;
    frame.origin.y = max;
    [UIView animateWithDuration:0.3 animations:^{
      _whiteView.frame = frame;
    }];
  }
}

-(void)moveVertically:(UIPanGestureRecognizer*)pan{
  CGFloat offset = [pan translationInView:self.view].y;
  CGRect frame = _whiteView.frame;
  frame.origin = CGPointMake(frame.origin.x, frame.origin.y + offset);
  frame.size.height = frame.size.height - offset;
  
  CGFloat max = CGRectGetHeight(self.view.bounds) - _keyboardHeight - 100;
  if (frame.origin.y  < (CGRectGetHeight(self.view.bounds) * 0.05 + 10) || frame.origin.y > max){
    return;
  }
  self.whiteView.frame = frame;
  [[NSUserDefaults standardUserDefaults] setFloat:self.whiteView.frame.origin.y forKey:@"composerYOffset"];
  [pan setTranslation:CGPointZero inView:self.view];
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  if (!self.word){
    [_tvc openKeyboard];
  }
}

-(void)textViewDidChange{
  BOOL enabled = [_tvc wordText].length > 0;
  
  _doneButton.enabled = enabled;
  if (_word){
    return;
  }
}

-(void)done{
  
  [_tvc closeKeyboard];

  Word *word = [[Word alloc] init];
  word.wordText = [_tvc wordText];
  word.hintText = [_tvc hintText];
  if (_word){
    word.learned = _word.learned;
  }

  if (self.save){
    self.save(word, _wordIndex);
  }
}

-(void)delete{
  
  [_tvc closeKeyboard];

  if (self.cancel){
    self.cancel();
  }
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
