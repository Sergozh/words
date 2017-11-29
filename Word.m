//
//  Word.m
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import "Word.h"

@implementation Word

-(void)setLearned:(BOOL)learned{
  _learned = learned;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"saveFolders" object:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:_wordText forKey:@"wordText"];
  [encoder encodeObject:_hintText forKey:@"hintText"];
  [encoder encodeObject:@(_learned) forKey:@"learned"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    self.hintText = [decoder decodeObjectForKey:@"hintText"];
    self.wordText = [decoder decodeObjectForKey:@"wordText"];
    self.learned = [[decoder decodeObjectForKey:@"learned"] boolValue];
  }
  return self;
}

@end
