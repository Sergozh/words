//
//  Tools.m
//  Weather
//
//  Created by Егор Иванов on 15/01/15.
//  Copyright (c) 2015 organization. All rights reserved.
//

#import "Tools.h"

@implementation Tools

#pragma mark - Threads

+(void)runInBackground:(void (^)(void))block{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

+(void)runLater:(NSTimeInterval)delay block:(void (^)(void))block{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

+(void)runOnMainThread:(void (^)(void))block{
  dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - Networking

+(void)jsonRequest:(NSString*)request withCompletion:(void (^)(NSDictionary *json))completion{
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithURL:[NSURL URLWithString:request]
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       
       if (error){
         NSLog(@"JSON request failed: %@", error);
         return;
       }
       
       if (response){
       }
       
       if (data){
         NSError *jsonError = nil;
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments error:&jsonError];
         if (jsonError){
           NSLog(@"Invalid JSON: %@", jsonError);
           return;
         }
         
         completion(json);
       }
     }] resume];
}


#pragma mark - Alerts

+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message actions:(NSArray*)actions{
  
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
    message:message preferredStyle:UIAlertControllerStyleAlert];
  
  for (UIAlertAction *action in actions) {
    if (![action isKindOfClass:[UIAlertAction class]]){
      return;
    }
    [alert addAction:action];
  }
  
  UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  [vc presentViewController:alert animated:YES completion:nil];
}

+(UIAlertAction *)alertActionWithTitle:(NSString*)title block:(void (^)(UIAlertAction *action))handler{
  UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
  return alertAction;
}


#pragma mark - Core Graphics

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize){
  
  CGFloat mW = boundingSize.width / aspectRatio.width;
  CGFloat mH = boundingSize.height / aspectRatio.height;
  
  if( mH < mW ){
    boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
  }
  else if( mW < mH ){
    boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
  }
  
  return boundingSize;
}

CGSize CGSizeAspectFill(CGSize aspectRatio, CGSize minimumSize){
  
  CGFloat mW = minimumSize.width / aspectRatio.width;
  CGFloat mH = minimumSize.height / aspectRatio.height;
  
  if( mH > mW ){
    minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
  }
  else if( mW > mH ){
    minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
  }
  
  return minimumSize;
}


#pragma mark Collections

+(void)findObjectForKey:(NSString*)desiredKey inDict:(NSDictionary*)dict withResultBlock:(void (^)(id result))resultBlock{
  [self enumerateJSONToFindKeys:dict forKeyNamed:nil desiredKey:desiredKey resultBlock:resultBlock];
}

+(void)enumerateJSONToFindKeys:(id)object forKeyNamed:(NSString *)keyName desiredKey:(NSString*)desiredKey resultBlock:(void (^)(id result))resultBlock{
  if ([object isKindOfClass:[NSDictionary class]]) {
    [object enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
      [self enumerateJSONToFindKeys:value forKeyNamed:key desiredKey:desiredKey resultBlock:resultBlock];
    }];
  }
  else if ([object isKindOfClass:[NSArray class]]) {
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [self enumerateJSONToFindKeys:obj forKeyNamed:nil desiredKey:desiredKey resultBlock:resultBlock];
    }];
  }
  else {
    if ([keyName isEqualToString:desiredKey]){
      if (resultBlock){
        resultBlock(object);
      }
    }
  }
}

@end


@implementation UIView (Metrics)

-(CGPoint)centerForSubviews{
  return CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

-(CGFloat)width{
  return CGRectGetWidth(self.bounds);
}

-(CGFloat)height{
  return CGRectGetHeight(self.bounds);
}

-(void)roundToNearestPixelEdges{
  CGRect frame = self.frame;
  frame.origin = CGPointMake(roundf(frame.origin.x), roundf(frame.origin.y));
  self.frame = frame;
}

-(CGFloat)minX{
  return CGRectGetMinX(self.frame);
}

-(CGFloat)maxX{
  return CGRectGetMaxX(self.frame);
}

-(CGFloat)minY{
  return CGRectGetMinY(self.frame);
}

-(CGFloat)maxY{
  return CGRectGetMaxY(self.frame);
}


@end










