//
//  Word.h
//  Words
//
//  Created by Егор Иванов on 14/02/15.
//  Copyright (c) 2015 hey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

@property NSString *wordText;
@property NSString *hintText;
@property (nonatomic) BOOL learned;

@end
