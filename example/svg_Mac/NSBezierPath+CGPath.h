//
//  NSBezierPath+SGG_NSBezierPath_CGPath.h
//  Tetrout
//
//  Created by Michael Redig on 9/24/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//
//#if TARGET_OS_IPHONE
//#else
#import <Cocoa/Cocoa.h>

@interface NSBezierPath (CGPath)

@property (readonly, getter=CGPathGen) CGPathRef CGPath ;

-(CGPathRef)CGPathGen;

@end
//#endif