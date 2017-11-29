//
//  Notebook.h
//  Words
//
//  Created by Егор Иванов on 15/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

@interface Notebook : NSObject

@property NSArray *words;
@property NSString *name;
@property (nonatomic) BOOL showWords;

-(void)addWord:(Word *)word forIndex:(NSInteger)index;
-(void)removeWordAtIndex:(NSInteger)index;
-(void)postponeWordFromIndex:(NSInteger)index;
-(void)moveWordAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
