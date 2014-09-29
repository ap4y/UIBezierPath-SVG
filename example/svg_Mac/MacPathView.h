//
//  MacPathView.h
//  svg_test
//
//  Created by Michael Redig on 9/29/14.
//
//

#import <Cocoa/Cocoa.h>

@interface MacPathView : NSView {
	NSString* _svgString;
	CGFloat _scale;
	NSColor* _color;
}
- (id)initWithFrame:(CGRect)frame
	   andSVGString:(NSString*)svgString
			  scale:(CGFloat)scale
		  fillColor:(NSColor*)color;

@end
