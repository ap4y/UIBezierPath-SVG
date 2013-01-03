//
//  UIBezierPath+SVG.h
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum CType : NSInteger {
    Absolute, 
    Relative
} CommandType;

//Commands protocol
@protocol SVGCommand <NSObject>
- (void)processCommand:(NSString *)commandString
       withPrevCommand:(NSString *)prevCommand
               forPath:(UIBezierPath *)path;
@end

//Commands abstract class
@interface SVGCommandImpl : NSObject <SVGCommand> {
    NSString *_prevCommand;
}

- (void)performCommand:(CGFloat *)params
              withType:(CommandType)type
               forPath:(UIBezierPath *)path;
@end

//Commands concrete implementation
@interface SVGMoveCommand : SVGCommandImpl
@end

@interface SVGLineToCommand : SVGCommandImpl
@end

@interface SVGHorizontalLineToCommand : SVGCommandImpl
@end

@interface SVGVerticalLineToCommand : SVGCommandImpl
@end

@interface SVGCurveToCommand : SVGCommandImpl
@end

@interface SVGSmoothCurveToCommand : SVGCommandImpl
@end

@interface SVGQuadraticCurveToCommand : SVGCommandImpl
@end

@interface SVGSmootQuadratichCurveToCommand : SVGCommandImpl
@end

@interface SVGClosePathCommand : SVGCommandImpl
@end

//Commands factory
@interface SVGCommandFactory : NSObject {
    NSDictionary *commands;
}
+ (SVGCommandFactory *)defaultFactory;
- (id<SVGCommand>)getCommand:(NSString *)commandLetter;
@end

@interface UIBezierPath (SVG)

- (UIBezierPath *)addPathsFromSVGString:(NSString *)svgString;
+ (UIBezierPath *)bezierPathWithSVGString:(NSString *)svgString;

@end
