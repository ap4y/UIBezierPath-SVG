//
//  UIBezierPath+SVG.m
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBezierPath+SVG.h"

#define PRINT_DRAWING_INSTRUCTIONS 1

#pragma mark ----------Common----------
typedef enum : NSInteger {
    Absolute,
    Relative
} CommandType;

@protocol SVGCommand <NSObject>
- (void)processCommandString:(NSString *)commandString
             withPrevCommand:(NSString *)prevCommand
                     forPath:(UIBezierPath *)path;
@end

#pragma mark ----------SVGCommandImpl----------
@interface SVGCommandImpl : NSObject <SVGCommand>
@property (retain, nonatomic) NSString *prevCommand;

- (void)performWithParams:(CGFloat *)params
              commandType:(CommandType)type
                  forPath:(UIBezierPath *)path;
@end

@implementation SVGCommandImpl

+ (NSRegularExpression *)paramRegex {
    static NSRegularExpression *_paramRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paramRegex = [[NSRegularExpression alloc] initWithPattern:@"[-+]?[0-9]*\\.?[0-9]+"
                                                           options:0
                                                             error:nil];
    });
    return _paramRegex;
}

- (CGFloat *)getCommandParameters:(NSString *)commandString {
    NSRegularExpression *regex  = [SVGCommandImpl paramRegex];
    NSArray *matches            = [regex matchesInString:commandString
                                                 options:0
                                                   range:NSMakeRange(0, [commandString length])];
    CGFloat *result             = (CGFloat *)malloc(matches.count * sizeof(CGFloat));
    
    for (int i = 0; i < matches.count; i++) {
        NSTextCheckingResult *match = [matches objectAtIndex:i];
        NSString *paramString       = [commandString substringWithRange:match.range];
        CGFloat param               = (CGFloat)[paramString floatValue];
        result[i]                   = param;
    }
    
    return result;
}

- (BOOL)isAbsoluteCommand:(NSString *)commandLetter {
    return [commandLetter isEqualToString:[commandLetter uppercaseString]];
}

- (void)processCommandString:(NSString *)commandString
             withPrevCommand:(NSString *)prevCommand
                     forPath:(UIBezierPath *)path {
    self.prevCommand        = prevCommand;
    NSString *commandLetter = [commandString substringToIndex:1];
    CGFloat *params         = [self getCommandParameters:commandString];
    [self performWithParams:params
                commandType:[self isAbsoluteCommand:commandLetter] ? Absolute : Relative
                    forPath:path];
    free(params);
}

- (void)performWithParams:(CGFloat *)params
              commandType:(CommandType)type
                  forPath:(UIBezierPath *)path {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end

#pragma mark ----------SVGMoveCommand----------
@interface SVGMoveCommand : SVGCommandImpl @end

@implementation SVGMoveCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path moveToPoint:CGPointMake(params[0], params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path moveToPoint:CGPointMake(%f, %f)];\n", params[0], params[1]);
        }
    } else {
        [path moveToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                      path.currentPoint.y + params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path moveToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f)];\n", params[0], params[1]);
        }
    }
}

@end

#pragma mark ----------SVGLineToCommand----------
@interface SVGLineToCommand : SVGCommandImpl @end

@implementation SVGLineToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(params[0], params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(%f, %f)];\n", params[0], params[1]);
        }
    } else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                         path.currentPoint.y + params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f)];\n", params[0], params[1]);
        }
    }
}

@end

#pragma mark ----------SVGHorizontalLineToCommand----------
@interface SVGHorizontalLineToCommand : SVGCommandImpl @end

@implementation SVGHorizontalLineToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(params[0], path.currentPoint.y)];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(%f, path.currentPoint.y)];\n", params[0]);
        }
    } else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x + params[0], 
                                         path.currentPoint.y)];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y)];\n", params[0]);
        }
    }
}

@end

#pragma mark ----------SVGVerticalLineToCommand----------
@interface SVGVerticalLineToCommand : SVGCommandImpl @end

@implementation SVGVerticalLineToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addLineToPoint:CGPointMake(path.currentPoint.x, params[0])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(path.currentPoint.x, %f)];\n", params[0]);
        }
    } else {
        [path addLineToPoint:CGPointMake(path.currentPoint.x, 
                                         path.currentPoint.y + params[0])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addLineToPoint:CGPointMake(path.currentPoint.x, path.currentPoint.y + %f)];\n", params[0]);
        }
    }
}

@end

#pragma mark ----------SVGCurveToCommand----------
@interface SVGCurveToCommand : SVGCommandImpl @end

@implementation SVGCurveToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addCurveToPoint:CGPointMake(params[4], params[5]) 
                controlPoint1:CGPointMake(params[0], params[1]) 
                controlPoint2:CGPointMake(params[2], params[3])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addCurveToPoint:CGPointMake(%f, %f) controlPoint1:CGPointMake(%f, %f) controlPoint2:CGPointMake(%f, %f)];\n", params[4], params[5], params[0], params[1], params[2], params[3]);
        }
    } else {
        [path addCurveToPoint:CGPointMake(path.currentPoint.x + params[4], path.currentPoint.y + params[5]) 
                controlPoint1:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1]) 
                controlPoint2:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addCurveToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f) controlPoint1:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f) controlPoint2:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f)];\n", params[4], params[5], params[0], params[1], params[2], params[3]);
        }
    }
}

@end

#pragma mark ----------SVGSmoothCurveToCommand----------
@interface SVGSmoothCurveToCommand : SVGCommandImpl @end

@implementation SVGSmoothCurveToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {

    CGPoint firstControlPoint = CGPointMake(path.currentPoint.x, path.currentPoint.y);
    
    if (self.prevCommand && self.prevCommand.length > 0) {
        NSString *prevCommandType           = [self.prevCommand substringToIndex:1];
        NSString *prevCommandTypeLowercase  = [prevCommandType lowercaseString];
        BOOL isAbsolute                     = ![prevCommandType isEqualToString:prevCommandTypeLowercase];
        
        if ([prevCommandTypeLowercase isEqualToString:@"c"] ||
            [prevCommandTypeLowercase isEqualToString:@"s"]) {
                                            
            CGFloat *prevParams = [self getCommandParameters:self.prevCommand];
            if ([prevCommandTypeLowercase isEqualToString:@"c"]) {
                
                if (isAbsolute) {
                    firstControlPoint = CGPointMake(-1*prevParams[2] + 2*path.currentPoint.x, 
                                                    -1*prevParams[3] + 2*path.currentPoint.y);
                } else {
                    CGPoint oldCurrentPoint = CGPointMake(path.currentPoint.x - prevParams[4], 
                                                          path.currentPoint.y - prevParams[5]);
                    firstControlPoint = CGPointMake(-1*(prevParams[2] + oldCurrentPoint.x) + 2*path.currentPoint.x, 
                                                    -1*(prevParams[3] + oldCurrentPoint.y) + 2*path.currentPoint.y);                    
                }                
            } else {
                if (isAbsolute) {
                    firstControlPoint = CGPointMake(-1*prevParams[0] + 2*path.currentPoint.x, 
                                                    -1*prevParams[1] + 2*path.currentPoint.y);
                } else {
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
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addCurveToPoint:CGPointMake(%f, %f) controlPoint1:CGPointMake(%f, %f) controlPoint2:CGPointMake(%f, %f)];\n", params[2], params[3], firstControlPoint.x, firstControlPoint.y, params[0], params[1]);
        }
    } else {
        [path addCurveToPoint:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3]) 
                controlPoint1:CGPointMake(firstControlPoint.x, firstControlPoint.y) 
                controlPoint2:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addCurveToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f) controlPoint1:CGPointMake(%f, %f) controlPoint2:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f)];\n", params[2], params[3], firstControlPoint.x, firstControlPoint.y, params[0], params[1]);
        }
    }
}

@end

#pragma mark ----------SVGQuadraticCurveToCommand----------
@interface SVGQuadraticCurveToCommand : SVGCommandImpl @end

@implementation SVGQuadraticCurveToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    if (type == Absolute) {
        [path addQuadCurveToPoint:CGPointMake(params[2], params[3])
                     controlPoint:CGPointMake(params[0], params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addQuadCurveToPoint:CGPointMake(%f, %f) controlPoint:CGPointMake(%f, %f)];\n", params[2], params[3], params[0], params[1]);
        }
    } else {
        [path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + params[2], path.currentPoint.y + params[3]) 
                     controlPoint:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1])];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f) controlPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f)];\n", params[2], params[3], params[0], params[1]);
        }
    }
}

@end

#pragma mark ----------SVGSmoothQuadraticCurveToCommand----------
@interface SVGSmoothQuadraticCurveToCommand : SVGCommandImpl @end

@implementation SVGSmoothQuadraticCurveToCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    CGPoint firstControlPoint = CGPointMake(path.currentPoint.x, path.currentPoint.y);
    
    if (self.prevCommand && self.prevCommand.length > 0) {
        NSString *prevCommandType           = [self.prevCommand substringToIndex:1];
        NSString *prevCommandTypeLowercase  = [prevCommandType lowercaseString];
        BOOL isAbsolute                     = ![prevCommandType isEqualToString:prevCommandTypeLowercase];

        if ([prevCommandTypeLowercase isEqualToString:@"q"]) {
            
            CGFloat *prevParams = [self getCommandParameters:self.prevCommand];
                        
            if (isAbsolute) {
                firstControlPoint = CGPointMake(-1*prevParams[0] + 2*path.currentPoint.x, 
                                                -1*prevParams[1] + 2*path.currentPoint.y);
            } else {
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
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addQuadCurveToPoint:CGPointMake(%f, %f) controlPoint:CGPointMake(%f, %f)];\n", params[0], params[1], firstControlPoint.x, firstControlPoint.y);
        }
    } else {
        [path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + params[0], path.currentPoint.y + params[1]) 
                     controlPoint:CGPointMake(firstControlPoint.x, firstControlPoint.y)];
        if (PRINT_DRAWING_INSTRUCTIONS) {
            printf("[path addQuadCurveToPoint:CGPointMake(path.currentPoint.x + %f, path.currentPoint.y + %f) controlPoint:CGPointMake(%f, %f)];\n", params[0], params[1], firstControlPoint.x, firstControlPoint.y);
        }
    }
}

@end

#pragma mark ----------SVGClosePathCommand----------
@interface SVGClosePathCommand : SVGCommandImpl @end

@implementation SVGClosePathCommand

- (void)performWithParams:(CGFloat *)params commandType:(CommandType)type forPath:(UIBezierPath *)path {
    [path closePath];
    if (PRINT_DRAWING_INSTRUCTIONS) {
        printf("[path closePath];\n");
    }
}

@end

#pragma mark ----------SVGCommandFactory----------

@interface SVGCommandFactory : NSObject {
    NSDictionary *commands;
}
+ (SVGCommandFactory *)defaultFactory;
- (id<SVGCommand>)commandForCommandLetter:(NSString *)commandLetter;
@end

@implementation SVGCommandFactory

+ (SVGCommandFactory *)defaultFactory {
    static SVGCommandFactory *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SVGCommandFactory alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        SVGMoveCommand *move                                        = [[SVGMoveCommand alloc] init];
        SVGLineToCommand *lineTo                                    = [[SVGLineToCommand alloc] init];
        SVGHorizontalLineToCommand *horizontalLineTo                = [[SVGHorizontalLineToCommand alloc] init];
        SVGVerticalLineToCommand *verticalLineTo                    = [[SVGVerticalLineToCommand alloc] init];
        SVGCurveToCommand *curveTo                                  = [[SVGCurveToCommand alloc] init];
        SVGSmoothCurveToCommand *smoothCurveTo                      = [[SVGSmoothCurveToCommand alloc] init];
        SVGQuadraticCurveToCommand *quadraticCurveTo                = [[SVGQuadraticCurveToCommand alloc] init];
        SVGSmoothQuadraticCurveToCommand *smoothQuadraticCurveTo    = [[SVGSmoothQuadraticCurveToCommand alloc] init];
        SVGClosePathCommand *closePath                              = [[SVGClosePathCommand alloc] init];

        commands = [[NSDictionary alloc] initWithObjectsAndKeys:
                    move,                   @"m",
                    lineTo,                 @"l",
                    horizontalLineTo,       @"h",
                    verticalLineTo,         @"v",
                    curveTo,                @"c",
                    smoothCurveTo,          @"s",
                    quadraticCurveTo,       @"q",
                    smoothQuadraticCurveTo, @"t",
                    closePath,              @"z",
                    nil];
        
        [move release];
        [lineTo release];
        [horizontalLineTo release];
        [verticalLineTo release];
        [curveTo release];
        [smoothCurveTo release];
        [quadraticCurveTo release];
        [smoothQuadraticCurveTo release];
        [closePath release];
    }
    return self;
}

- (id<SVGCommand>)commandForCommandLetter:(NSString *)commandLetter {
    return [commands objectForKey:[commandLetter lowercaseString]];
}

@end

#pragma mark ----------UIBezierPath (SVG)----------

@implementation UIBezierPath (SVG)

+ (void)processCommandString:(NSString *)commandString
       withPrevCommandString:(NSString *)prevCommand
                     forPath:(UIBezierPath*)path {
    
    if (!commandString || commandString.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"Invalid command %@", commandString]
                                     userInfo:nil];
    }

    NSString *commandLetter = [commandString substringToIndex:1];
    id<SVGCommand> command  = [[SVGCommandFactory defaultFactory] commandForCommandLetter:commandLetter];
    
    if (command) {        
        [command processCommandString:commandString withPrevCommand:prevCommand forPath:path];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:[NSString stringWithFormat:@"Unknown command %@", commandLetter]
                                     userInfo:nil];
    }
}

+ (NSRegularExpression *)commandRegex {
    static NSRegularExpression *_commandRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commandRegex = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z]"
                                                             options:0
                                                               error:nil];
    });
    return _commandRegex;
}

+ (UIBezierPath *)addPathWithSVGString:(NSString *)svgString toPath:(UIBezierPath *)aPath {
    if (PRINT_DRAWING_INSTRUCTIONS) {
        printf("// SVG shape\n");
    }
    if (aPath && svgString && svgString.length > 0) {
        NSRegularExpression *regex              = [self commandRegex];
        __block NSTextCheckingResult *prevMatch = nil;
        __block NSString *prevCommand           = @"";
        [regex enumerateMatchesInString:svgString
                                options:0
                                  range:NSMakeRange(0, [svgString length])
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
            @autoreleasepool {
                if (prevMatch) {
                    NSUInteger length       = match.range.location - prevMatch.range.location;
                    NSString *commandString = [svgString substringWithRange:NSMakeRange(prevMatch.range.location,
                                                                                        length)];
                    
                    [self processCommandString:commandString withPrevCommandString:prevCommand forPath:aPath];
                    [prevCommand release];
                    [prevMatch release];
                    prevCommand = [commandString retain];
                }
                prevMatch = [match retain];
            }
        }];
        
        NSString *result = [svgString substringWithRange:NSMakeRange(prevMatch.range.location, 
                                                                     svgString.length - prevMatch.range.location)];
        [self processCommandString:result withPrevCommandString:prevCommand forPath:aPath];
        [prevMatch release];
        [prevCommand release];
    }   
    return aPath;
}

- (void)addPathFromSVGString:(NSString *)svgString {
    [UIBezierPath addPathWithSVGString:svgString toPath:self];
}

+ (UIBezierPath *)bezierPathWithSVGString:(NSString *)svgString {
    return [self addPathWithSVGString:svgString toPath:[UIBezierPath bezierPath]];
}

@end