//
//  PathView.m
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathView.h"
#import "UIBezierPath+SVG.h"

@implementation PathView

- (id)initWithFrame:(CGRect)frame 
       andSVGString:(NSString*)svgString 
              scale:(CGFloat)scale 
          fillColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _svgString = svgString;
        _scale = scale;
        _color = color;
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{        
    UIBezierPath* aPath = [UIBezierPath bezierPathWithSVGString:_svgString];    
    [_color setFill];
    
    CGContextRef aRef = UIGraphicsGetCurrentContext();    
    CGContextScaleCTM(aRef, _scale, _scale);
    
    [aPath fill];
}

@end
