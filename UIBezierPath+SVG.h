//
//  UIBezierPath+SVG.h
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#if TARGET_OS_IPHONE
#define SKUBezierPath UIBezierPath
#define addLineToPointSKU addLineToPoint
#define addCurveToPointSKU addCurveToPoint
#else
#define SKUBezierPath NSBezierPath
#define addLineToPointSKU lineToPoint
#define addCurveToPointSKU curveToPoint
#endif


@interface SKUBezierPath (SVG)

- (void)addPathFromSVGString:(NSString *)svgString;
+ (SKUBezierPath *)bezierPathWithSVGString:(NSString *)svgString;

@end


#if TARGET_OS_IPHONE
#else
@interface NSBezierPath (AddQuads)

-(void)addQuadCurveToPoint:(CGPoint)point controlPoint:(CGPoint)controlPoint;

@end

#endif