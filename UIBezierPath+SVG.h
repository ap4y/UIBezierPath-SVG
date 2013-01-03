//
//  UIBezierPath+SVG.h
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface UIBezierPath (SVG)

- (UIBezierPath *)addPathsFromSVGString:(NSString *)svgString;
+ (UIBezierPath *)bezierPathWithSVGString:(NSString *)svgString;

@end
