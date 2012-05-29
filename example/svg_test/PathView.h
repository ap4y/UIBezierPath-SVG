//
//  PathView.h
//  svg_test
//
//  Created by Arthur Evstifeev on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathView : UIView {
    NSString* _svgString;
    CGFloat _scale;
    UIColor* _color;
}
- (id)initWithFrame:(CGRect)frame 
       andSVGString:(NSString*)svgString  
              scale:(CGFloat)scale 
          fillColor:(UIColor*)color;
@end
