//
//  TigerView.m
//  svg_test
//
//  Created by ap4y on 8/7/12.
//
//

#import "TigerView.h"
#import "UIBezierPath+SVG.h"

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
        [_tigerPathes retain];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc {
    [_tigerPathes release];
    [super dealloc];
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
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(aRef, 1.0, 1.0);
    CGContextTranslateCTM(aRef, 190.0, 150.0);

    NSRegularExpression *pathesRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}"
                                                                                 options:0
                                                                                   error:nil];
    NSArray *matches = [pathesRegex matchesInString:_tigerPathes
                                            options:0
                                              range:NSMakeRange(0, _tigerPathes.length)];
    
    for (NSTextCheckingResult *result in matches) {
        NSString *pathObject = [_tigerPathes substringWithRange:result.range];
        NSString *path = [pathObject substringWithRange:[pathObject rangeOfString:@"path:\".*?\""
                                                                          options:NSRegularExpressionSearch]];
        path = [path stringByReplacingOccurrencesOfString:@"path:\"" withString:@""];
        path = [path stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        UIBezierPath *aPath = [UIBezierPath bezierPathWithSVGString:path];
                
        NSRange stroke_range = [pathObject rangeOfString:@"\"stroke-width\":\".*?\""
                                                 options:NSRegularExpressionSearch];
        
        if (stroke_range.location != NSNotFound) {
            NSString *stroke_width = [pathObject substringWithRange:stroke_range];
            stroke_width = [stroke_width stringByReplacingOccurrencesOfString:@"\"stroke-width\":\"" withString:@""];
            stroke_width = [stroke_width stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            aPath.lineWidth = [stroke_width floatValue];
        }
        
        NSString *stroke = [pathObject substringWithRange:[pathObject rangeOfString:@"stroke:\".*?\""
                                                                            options:NSRegularExpressionSearch]];
        stroke = [stroke stringByReplacingOccurrencesOfString:@"stroke:\"" withString:@""];
        stroke = [stroke stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if (![stroke isEqualToString:@"none"]) {
            UIColor *strokeColor = [TigerView colorWithHexString:stroke];
            [strokeColor setStroke];
            [aPath stroke];
        }
        
        NSString *fill = [pathObject substringWithRange:[pathObject rangeOfString:@"fill:\".*?\""
                                                                          options:NSRegularExpressionSearch]];
        fill = [fill stringByReplacingOccurrencesOfString:@"fill:\"" withString:@""];
        fill = [fill stringByReplacingOccurrencesOfString:@"\"" withString:@""];

        if (![fill isEqualToString:@"none"]) {
            UIColor *fillColor = [TigerView colorWithHexString:fill];
            [fillColor setFill];
            [aPath fill];
        }        
    }
}

@end
