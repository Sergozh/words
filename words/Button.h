

#import <UIKit/UIKit.h>

@interface Button : UIButton

-(void)setButtonColor:(UIColor*)color;
-(void)setBorderColor:(UIColor*)color;
-(void)setTitleColor:(UIColor*)color;

-(void)setButtonColorWithHexString:(NSString*)hexString;
-(void)setBorderColorWithHexString:(NSString*)hexString;
-(void)setTitleColorWithHexString:(NSString*)hexString;


@end
