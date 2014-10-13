//
//  TigerView.m
//  svg_test
//
//  Created by ap4y on 8/7/12.
//
//

#import "TigerView.h"
#import "SKUBezierPath+SVG.h"
#import <QuartzCore/QuartzCore.h>

@interface TigerView () {
    NSString *_tigerPathes;
}
@end

@implementation TigerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tiger" ofType:@"js"];
        _tigerPathes = [NSString stringWithContentsOfFile:filePath
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


/* snippet from http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string */
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            [NSException raise:@"Invalid color value"
                        format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = (length == 2 ?
                         substring :
                         [NSString stringWithFormat: @"%@%@", substring, substring]);
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}
/* end of snippet */

- (void)drawRect:(CGRect)rect {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
        CGContextRef aRef = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(aRef, 1.0f, 1.0f);
        CGContextTranslateCTM(aRef, 190.0f, 150.0f);
        
        NSRegularExpression *pathObjectsRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}"
                                                                                          options:0
                                                                                            error:nil];
        NSArray *matches = [pathObjectsRegex matchesInString:_tigerPathes
                                                     options:0
                                                       range:NSMakeRange(0, _tigerPathes.length)];
        
        for (NSTextCheckingResult *checkingResult in matches) {
            NSString *pathObject = [_tigerPathes substringWithRange:checkingResult.range];
            UIBezierPath *aPath = [self pathFromPathObject:pathObject];
            
            aPath.lineWidth = [self strokeWidthFromPathObject:pathObject];
            
            [[self strokeColorFromPathObject:pathObject] setStroke];
            [aPath stroke];
            
            [[self fillColorFromPathObject:pathObject] setFill];
            [aPath fill];
            
            UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                self.layer.contents = (id)[resultImage CGImage];
            });
        }
        
        UIGraphicsEndImageContext();
    });
}

- (UIBezierPath *)pathFromPathObject:(NSString *)pathObject {
    NSString *path = [pathObject substringWithRange:[pathObject rangeOfString:@"path:\".*?\""
                                                                      options:NSRegularExpressionSearch]];
    path = [path stringByReplacingOccurrencesOfString:@"path:\"" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [UIBezierPath bezierPathWithSVGString:path];
}

- (CGFloat)strokeWidthFromPathObject:(NSString *)pathObject {
    
    NSRange stroke_range = [pathObject rangeOfString:@"\"stroke-width\":\".*?\""
                                             options:NSRegularExpressionSearch];
    
    if (stroke_range.location != NSNotFound) {
        NSString *stroke_width = [pathObject substringWithRange:stroke_range];
        stroke_width = [stroke_width stringByReplacingOccurrencesOfString:@"\"stroke-width\":\"" withString:@""];
        stroke_width = [stroke_width stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        return [stroke_width floatValue];
    }
    
    return 1.0f;
}

- (UIColor *)strokeColorFromPathObject:(NSString *)pathObject {
    NSString *stroke = [pathObject substringWithRange:[pathObject rangeOfString:@"stroke:\".*?\""
                                                                        options:NSRegularExpressionSearch]];
    stroke = [stroke stringByReplacingOccurrencesOfString:@"stroke:\"" withString:@""];
    stroke = [stroke stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if (![stroke isEqualToString:@"none"]) {
        return [TigerView colorWithHexString:stroke];
    }
    
    return [UIColor whiteColor];
}

- (UIColor *)fillColorFromPathObject:(NSString *)pathObject {
    NSString *fill = [pathObject substringWithRange:[pathObject rangeOfString:@"fill:\".*?\""
                                                                      options:NSRegularExpressionSearch]];
    fill = [fill stringByReplacingOccurrencesOfString:@"fill:\"" withString:@""];
    fill = [fill stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if (![fill isEqualToString:@"none"]) {
        return [TigerView colorWithHexString:fill];
    }
    
    return [UIColor whiteColor];
}

@end
