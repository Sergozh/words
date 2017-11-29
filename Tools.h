//
//  Tools.h
//  Weather
//
//  Created by Егор Иванов on 15/01/15.
//  Copyright (c) 2015 organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tools : NSObject

// Threads

+(void)runInBackground:(void(^)(void))block;
+(void)runLater:(NSTimeInterval)delay block:(void(^)(void))block;
+(void)runOnMainThread:(void(^)(void))block;


// Networking

+(void)jsonRequest:(NSString*)request withCompletion:(void (^)(NSDictionary *json))completion;


// iOS 8 alerts

+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message actions:(NSArray*)actions;
+(UIAlertAction *)alertActionWithTitle:(NSString*)title block:(void (^)(UIAlertAction *action))handler;


// Core graphics

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize);
CGSize CGSizeAspectFill(CGSize aspectRatio, CGSize minimumSize);


// Collections

+(void)findObjectForKey:(NSString*)desiredKey inDict:(NSDictionary*)dict withResultBlock:(void (^)(id result))resultBlock;

@end


// Categories

@interface UIView (Metrics)

-(CGPoint)centerForSubviews;
-(CGFloat)width;
-(CGFloat)height;
-(void)roundToNearestPixelEdges;
-(CGFloat)minX;
-(CGFloat)maxX;
-(CGFloat)minY;
-(CGFloat)maxY;

@end







