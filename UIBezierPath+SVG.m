//
//  UIBezierPath+SVG.m
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBezierPath+SVG.h"

@implementation SVGCommandImpl

- (CGFloat*)getCommandParameters:(NSString*)commnadString {
    NSError  *error  = NULL;    
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:@"[-+]?[0-9]*\\.?[0-9]+"
                                  options:0
                                  error:&error];
    
    NSArray* matches = [regex matchesInString:commnadString
                                      options:0
                                        range:NSMakeRange(0, [commnadString length])];
    
    CGFloat *result = (CGFloat*)malloc(matches.count * sizeof(CGFloat));
    for (int i = 0; i < matches.count; i++) {
        NSTextCheckingResult* match = [matches objectAtIndex:i];
        NSString* paramString = [commnadString substringWithRange:match.range];
        CGFloat param = (CGFloat)[paramString floatValue];
        result[i] = param;
    }
    
    return result;
}

- (BOOL)isAbsoluteCommand:(NSString*)commandLetter {
    return [commandLetter isEqualToString:[commandLetter uppercaseString]];
}

- (void)processCommand:(NSString *)commandString forPath:(UIBezierPath *)path {
    NSString* commandLetter = [commandString substringToIndex:1];
    CGFloat* params = [self getCommandParameters:commandString];
    [self performCommand:params
                withType:[self isAbsoluteCommand:commandLetter] ? Absolute : Relative  
                 forPath:path];
    free(params);
}

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end

@implementation SVGMoveCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {        
    if (type == Absolute) {
        [path moveToPoint:CGPointMake(params[0], params[1])];
    }
    else {
        [path moveToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                      path.currentPoint.y + params[1])];
    }  
}

@end

@implementation SVGLineToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(params[0], params[1])];
    }
    else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                         path.currentPoint.y + params[1])];
    }  
}

@end

@implementation SVGHorizontalLineToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(params[0], path.currentPoint.y)];
    }
    else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                         path.currentPoint.y)];
    }  
}

@end

@implementation SVGVerticalLineToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(path.currentPoint.x, params[0])];
    }
    else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x, 
                                         path.currentPoint.y + params[0])];
    }  
}

@end

@implementation SVGCurveToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addCurveToPoint:CGPointMake(params[4], params[5]) 
                controlPoint1:CGPointMake(params[0], params[1]) 
                controlPoint2:CGPointMake(params[2], params[3])];
    }
    else {
        [path addCurveToPoint:CGPointMake(path.currentPoint.x + params[4], path.currentPoint.y + params[5]) 
                controlPoint1:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1]) 
                controlPoint2:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3])];
    }  
}

@end

@implementation SVGSmoothCurveToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addCurveToPoint:CGPointMake(params[2], params[3]) 
                controlPoint1:CGPointMake(path.currentPoint.x, path.currentPoint.y) 
                controlPoint2:CGPointMake(params[0], params[1])];
    }
    else {
        [path addCurveToPoint:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3]) 
                controlPoint1:CGPointMake(path.currentPoint.x, path.currentPoint.y) 
                controlPoint2:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1])];
    }
}

@end

@implementation SVGQuadraticCurveToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addQuadCurveToPoint:CGPointMake(params[2], params[3]) 
                  controlPoint:CGPointMake(params[0], params[1])];
    }
    else {
        [path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3]) 
                     controlPoint:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1])];
    }
}

@end

@implementation SVGSmootQuadratichCurveToCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addQuadCurveToPoint:CGPointMake(params[0], params[1]) 
                     controlPoint:CGPointMake(path.currentPoint.x, path.currentPoint.y)];
    }
    else {
        [path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1]) 
                     controlPoint:CGPointMake(path.currentPoint.x, path.currentPoint.y)];
    }
}

@end

@implementation SVGClosePathCommand

- (void)performCommand:(CGFloat *)params withType:(CommandType)type forPath:(UIBezierPath *)path {
    [path closePath];
}

@end

@implementation SVGCommandFactory

+ (SVGCommandFactory*)defaultFactory {
    static SVGCommandFactory* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SVGCommandFactory alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        SVGMoveCommand* move = [[SVGMoveCommand alloc] init];
        SVGLineToCommand* lineTo = [[SVGLineToCommand alloc] init];        
        SVGHorizontalLineToCommand* horizontalLineTo = [[SVGHorizontalLineToCommand alloc] init];        
        SVGVerticalLineToCommand* verticalLineTo = [[SVGVerticalLineToCommand alloc] init];        
        SVGCurveToCommand* curveTo = [[SVGCurveToCommand alloc] init];        
        SVGSmoothCurveToCommand* smoothCurveTo = [[SVGSmoothCurveToCommand alloc] init];        
        SVGQuadraticCurveToCommand* quadraticCurveTo = [[SVGQuadraticCurveToCommand alloc] init];        
        SVGSmootQuadratichCurveToCommand* smoothQuadraticCurveTo = [[SVGSmootQuadratichCurveToCommand alloc] init];        
        SVGClosePathCommand* closePath = [[SVGClosePathCommand alloc] init];        
        commands = [NSDictionary dictionaryWithObjectsAndKeys:
                    move, @"m", 
                    lineTo, @"l",
                    horizontalLineTo, @"h",
                    verticalLineTo, @"v",
                    curveTo, @"c",
                    smoothCurveTo, @"s",
                    quadraticCurveTo, @"q",
                    smoothQuadraticCurveTo, @"t",   
                    closePath, @"z",
                    nil];
    }
    return self;
}

- (id<SVGCommand>)getCommand:(NSString*)commandLetter {
    id<SVGCommand> command = [commands objectForKey:[commandLetter lowercaseString]];
    
    return command;
}

@end

@implementation UIBezierPath (SVG)

+ (void)processCommand:(NSString*)commandString forPath:(UIBezierPath*)path {    
    NSString* commandLetter = [commandString substringToIndex:1];

    id<SVGCommand> command = [[SVGCommandFactory defaultFactory] getCommand:commandLetter];
    if (command) {        
        [command processCommand:commandString forPath:path];
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"Unknown command %@", commandLetter]
                                     userInfo:nil];
    }
}

+ (UIBezierPath *)bezierPathWithSVGString:(NSString*)svgString {
    UIBezierPath* aPath = [UIBezierPath bezierPath];    
    
    NSError  *error  = NULL;    
    NSRegularExpression* regex = [NSRegularExpression 
                                  regularExpressionWithPattern:@"[A-Za-z]"
                                  options:0
                                  error:&error];
    
    NSArray* matches = [regex matchesInString:svgString
                                      options:0
                                        range:NSMakeRange(0, [svgString length])];
    
    NSTextCheckingResult* prevMatch = nil;
    for (int i = 0; i < matches.count; i++) {
        NSTextCheckingResult* match = [matches objectAtIndex:i];
        
        if (prevMatch) {
            NSString* result = [svgString substringWithRange:NSMakeRange(prevMatch.range.location, 
                                                                         match.range.location - prevMatch.range.location)];
            [self processCommand:result forPath:aPath];
        }
        prevMatch = match;
    }    
    
    NSString *result = [svgString substringWithRange:NSMakeRange(prevMatch.range.location, 
                                                                 svgString.length - prevMatch.range.location)];
    [self processCommand:result forPath:aPath];
    
    return aPath;
}

@end