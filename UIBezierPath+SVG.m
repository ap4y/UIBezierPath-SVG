//
//  UIBezierPath+SVG.m
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBezierPath+SVG.h"

@implementation SVGCommandImpl

+ (NSRegularExpression*)paramRegex {
    static NSRegularExpression* _paramRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paramRegex = [[NSRegularExpression alloc] initWithPattern:@"[-+]?[0-9]*\\.?[0-9]+"
                                                           options:0
                                                             error:nil];
    });
    return _paramRegex;
}

- (CGFloat*)getCommandParameters:(NSString*)commandString {
    NSRegularExpression* regex = [SVGCommandImpl paramRegex];    
    NSArray* matches = [regex matchesInString:commandString
                                      options:0
                                        range:NSMakeRange(0, [commandString length])];
    CGFloat *result = (CGFloat*)malloc(matches.count * sizeof(CGFloat));
    for (int i = 0; i < matches.count; i++) {
        NSTextCheckingResult* match = [matches objectAtIndex:i];
        NSString* paramString = [commandString substringWithRange:match.range];
        CGFloat param = (CGFloat)[paramString floatValue];
        result[i] = param;
    }
    
    return result;
}

- (BOOL)isAbsoluteCommand:(NSString*)commandLetter {
    return [commandLetter isEqualToString:[commandLetter uppercaseString]];
}

- (void)processCommand:(NSString *)commandString
       withPrevCommand:(NSString *)prevCommand
               forPath:(UIBezierPath *)path {
    _prevCommand = prevCommand;
    NSString* commandLetter = [commandString substringToIndex:1];
    CGFloat* params = [self getCommandParameters:commandString];
    [self performCommand:params
                withType:[self isAbsoluteCommand:commandLetter] ? Absolute : Relative  
                 forPath:path];
    free(params);
}

- (void)performCommand:(CGFloat *)params
              withType:(CommandType)type
               forPath:(UIBezierPath *)path {
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

    CGPoint firstControlPoint = CGPointMake(path.currentPoint.x, path.currentPoint.y);
    
    if (_prevCommand && _prevCommand.length > 0) {
        NSString* prevCommandType = [_prevCommand substringToIndex:1];
        NSString* prevCommandTypeLowercase = [prevCommandType lowercaseString];
        BOOL isAbsolute = ![prevCommandType isEqualToString:prevCommandTypeLowercase];
        
        if ([prevCommandTypeLowercase isEqualToString:@"c"] ||
            [prevCommandTypeLowercase isEqualToString:@"s"]) {
                                            
            CGFloat* prevParams = [self getCommandParameters:_prevCommand];
            if ([prevCommandTypeLowercase isEqualToString:@"c"]) {
                
                if (isAbsolute) {
                    firstControlPoint = CGPointMake(-1*prevParams[2] + 2*path.currentPoint.x, 
                                                    -1*prevParams[3] + 2*path.currentPoint.y);
                }
                else {
                    CGPoint oldCurrentPoint = CGPointMake(path.currentPoint.x - prevParams[4], 
                                                          path.currentPoint.y - prevParams[5]);
                    firstControlPoint = CGPointMake(-1*(prevParams[2] + oldCurrentPoint.x) + 2*path.currentPoint.x, 
                                                    -1*(prevParams[3] + oldCurrentPoint.y) + 2*path.currentPoint.y);                    
                }                
            }
            else {
                if (isAbsolute) {
                    firstControlPoint = CGPointMake(-1*prevParams[0] + 2*path.currentPoint.x, 
                                                    -1*prevParams[1] + 2*path.currentPoint.y);
                }
                else {
                    CGPoint oldCurrentPoint = CGPointMake(path.currentPoint.x - prevParams[2], 
                                                          path.currentPoint.y - prevParams[3]);
                    firstControlPoint = CGPointMake(-1*(prevParams[0] + oldCurrentPoint.x) + 2*path.currentPoint.x, 
                                                    -1*(prevParams[1] + oldCurrentPoint.y) + 2*path.currentPoint.y);                    
                }
            }
            free(prevParams);
        }
    }
    
    if (type == Absolute) {
        [path addCurveToPoint:CGPointMake(params[2], params[3]) 
                controlPoint1:CGPointMake(firstControlPoint.x, firstControlPoint.y) 
                controlPoint2:CGPointMake(params[0], params[1])];
    }
    else {
        [path addCurveToPoint:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3]) 
                controlPoint1:CGPointMake(firstControlPoint.x, firstControlPoint.y) 
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
    CGPoint firstControlPoint = CGPointMake(path.currentPoint.x, path.currentPoint.y);
    
    if (_prevCommand && _prevCommand.length > 0) {
        NSString* prevCommandType = [_prevCommand substringToIndex:1];
        NSString* prevCommandTypeLowercase = [prevCommandType lowercaseString];
        BOOL isAbsolute = ![prevCommandType isEqualToString:prevCommandTypeLowercase];

        if ([prevCommandTypeLowercase isEqualToString:@"q"]) {
            
            CGFloat* prevParams = [self getCommandParameters:_prevCommand];
                        
            if (isAbsolute) {
                firstControlPoint = CGPointMake(-1*prevParams[0] + 2*path.currentPoint.x, 
                                                -1*prevParams[1] + 2*path.currentPoint.y);
            }
            else {
                CGPoint oldCurrentPoint = CGPointMake(path.currentPoint.x - prevParams[2], 
                                                      path.currentPoint.y - prevParams[3]);
                firstControlPoint = CGPointMake(-1*(prevParams[0] + oldCurrentPoint.x) + 2*path.currentPoint.x, 
                                                -1*(prevParams[1] + oldCurrentPoint.y) + 2*path.currentPoint.y);                    
            }       
            free(prevParams);
        }
    }
    
    if (type == Absolute) {
        [path addQuadCurveToPoint:CGPointMake(params[0], params[1]) 
                     controlPoint:CGPointMake(firstControlPoint.x, firstControlPoint.y)];
    }
    else {
        [path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1]) 
                     controlPoint:CGPointMake(firstControlPoint.x, firstControlPoint.y)];
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
        SVGMoveCommand* move = [[[SVGMoveCommand alloc] init] autorelease];
        SVGLineToCommand* lineTo = [[[SVGLineToCommand alloc] init] autorelease];        
        SVGHorizontalLineToCommand* horizontalLineTo = [[[SVGHorizontalLineToCommand alloc] init] autorelease];        
        SVGVerticalLineToCommand* verticalLineTo = [[[SVGVerticalLineToCommand alloc] init] autorelease];        
        SVGCurveToCommand* curveTo = [[[SVGCurveToCommand alloc] init] autorelease];        
        SVGSmoothCurveToCommand* smoothCurveTo = [[[SVGSmoothCurveToCommand alloc] init] autorelease];        
        SVGQuadraticCurveToCommand* quadraticCurveTo = [[[SVGQuadraticCurveToCommand alloc] init] autorelease];        
        SVGSmootQuadratichCurveToCommand* smoothQuadraticCurveTo = [[[SVGSmootQuadratichCurveToCommand alloc] init] autorelease];        
        SVGClosePathCommand* closePath = [[[SVGClosePathCommand alloc] init] autorelease];        
        commands = [[NSDictionary alloc] initWithObjectsAndKeys:
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
    return [commands objectForKey:[commandLetter lowercaseString]];
}

@end

@implementation UIBezierPath (SVG)

+ (void)processCommand:(NSString*)commandString withPrevCommand:(NSString*)prevCommand andPath:(UIBezierPath*)path {
    if (!commandString || commandString.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"Invalid command %@", commandString]
                                     userInfo:nil];
    }

    NSString* commandLetter = [commandString substringToIndex:1];

    id<SVGCommand> command = [[SVGCommandFactory defaultFactory] getCommand:commandLetter];
    if (command) {        
        [command processCommand:commandString withPrevCommand:prevCommand forPath:path];
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"Unknown command %@", commandLetter]
                                     userInfo:nil];
    }
}

+ (NSRegularExpression*)commandRegex {
    static NSRegularExpression* _commandRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commandRegex = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z]"
                                                             options:0
                                                               error:nil];
    });
    return _commandRegex;
}

+ (UIBezierPath *)pathWithSVGString:(NSString*)svgString {
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    if (aPath) {
        NSError  *error  = NULL;    
        NSRegularExpression* regex = [NSRegularExpression 
                                      regularExpressionWithPattern:@"[A-Za-z]"
                                      options:0
                                      error:&error];
        
        NSArray* matches = [regex matchesInString:svgString
                                          options:0
                                            range:NSMakeRange(0, [svgString length])];
        
        NSTextCheckingResult* prevMatch = nil;
        NSString* prevCommand = @"";
        for (int i = 0; i < matches.count; i++) {
            NSTextCheckingResult* match = [matches objectAtIndex:i];
            
            if (prevMatch) {
                NSString* result = [svgString substringWithRange:NSMakeRange(prevMatch.range.location, 
                                                                             match.range.location - prevMatch.range.location)];
                [self processCommand:result withPrevCommane:prevCommand andPath:aPath];
                prevCommand = result;
            }
            prevMatch = match;
        }    
        
        NSString *result = [svgString substringWithRange:NSMakeRange(prevMatch.range.location, 
                                                                     svgString.length - prevMatch.range.location)];
        [self processCommand:result withPrevCommane:prevCommand andPath:aPath];        
    }
    return aPath;
}

+ (UIBezierPath *)bezierPathWithSVGString:(NSString*)svgString {
    if (!svgString || svgString.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"SVG string should be nonzero length"]
                                     userInfo:nil];
    }
    
    return [self pathWithSVGString:svgString];
}

@end