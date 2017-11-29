//
//  Folder.h
//  Words
//
//  Created by Егор on 28/03/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notebook.h"

@interface Folder : NSObject
@property NSArray *notebooks;
@property NSString *name;

-(void)addNotebook:(Notebook *)notebook forIndex:(NSInteger)index;
-(void)removeNotebookAtIndex:(NSInteger)index;
-(void)moveNotebookAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end
