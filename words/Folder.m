//
//  Folder.m
//  Words
//
//  Created by Егор on 28/03/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "Folder.h"

@implementation Folder

-(void)removeNotebookAtIndex:(NSInteger)index{
  NSMutableArray *temp = [_notebooks mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp removeObjectAtIndex:index];
  _notebooks = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)moveNotebookAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
  NSMutableArray *temp = [_notebooks mutableCopy];
  Word *word = temp[fromIndex];
  [temp removeObjectAtIndex:fromIndex];
  [temp insertObject:word atIndex:toIndex];
  _notebooks = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)addNotebook:(Notebook *)notebook forIndex:(NSInteger)index{
  NSMutableArray *temp = [_notebooks mutableCopy];
  if (!temp){
    temp = [NSMutableArray new];
  }
  [temp insertObject:notebook atIndex:index];
  _notebooks = [NSArray arrayWithArray:temp];
  [self askToSave];
}

-(void)askToSave{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"saveFolders" object:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:_name forKey:@"name"];
  [encoder encodeObject:_notebooks forKey:@"notebooks"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    _name = [decoder decodeObjectForKey:@"name"];
    _notebooks = [decoder decodeObjectForKey:@"notebooks"];
  }
  return self;
}


@end
