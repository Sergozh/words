//
//  Notebook.m
//  Words
//
//  Created by Егор Иванов on 15/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "Notebook.h"

@interface Notebook()

@end

@implementation Notebook

-(void)removeWordAtIndex:(NSInteger)index{
  NSMutableArray *temp = [_words mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp removeObjectAtIndex:index];
  _words = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)postponeWordFromIndex:(NSInteger)index{
  NSMutableArray *temp = [_words mutableCopy];
  Word *word = temp[index];
  [temp removeObjectAtIndex:index];
  [temp addObject:word];
  _words = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)moveWordAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
  NSMutableArray *temp = [_words mutableCopy];
  Word *word = temp[fromIndex];
  [temp removeObjectAtIndex:fromIndex];
  [temp insertObject:word atIndex:toIndex];
  _words = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)addWord:(Word *)word forIndex:(NSInteger)index{
  NSMutableArray *temp = [_words mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp insertObject:word atIndex:index];
  _words = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)setShowWords:(BOOL)showWords{
  _showWords = showWords;
  [self askToSave];
}

-(void)askToSave{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"saveFolders" object:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:_name forKey:@"name"];
  [encoder encodeObject:_words forKey:@"words"];
  [encoder encodeObject:@(_showWords) forKey:@"showWords"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    _name = [decoder decodeObjectForKey:@"name"];
    _words = [decoder decodeObjectForKey:@"words"];
    _showWords = [[decoder decodeObjectForKey:@"showWords"] boolValue];
  }
  return self;
}

@end





