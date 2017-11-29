

#import "Button.h"

@implementation Button

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBorderColor:self.tintColor];
    [self setTitleColor:self.tintColor];
  }
  return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
}

-(void)setTitleColor:(UIColor*)color{
    [self setTitleColor:color forState:UIControlStateNormal];
}

-(void)setTitleColorWithHexString:(NSString *)hexString{
    [self setTitleColor:[self colorWithHexString:hexString]];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)setBorderColorWithHexString:(NSString*)hexString{
    UIColor *color = [self colorWithHexString:hexString];
    [self setBorderColor:color];
}

-(void)setButtonColorWithHexString:(NSString*)hexString{
    UIColor *color = [self colorWithHexString:hexString];
    [self setButtonColor:color];
}

-(void)setBorderColor:(UIColor*)color{
    [self.layer setBorderColor:[color CGColor]];
    BOOL retina = [[UIScreen mainScreen] scale] == 2.0;
    [self.layer setBorderWidth: retina ? 1.0 : 2.0];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
}

-(void)setButtonColor:(UIColor *)color{
    
    // because UIButton with background color set instead of an image won't adjust its color on highlight
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
}


@end
