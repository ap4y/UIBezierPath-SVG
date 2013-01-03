//
//  UIBezierPath_SVGTests.m
//  UIBezierPath_SVGTests
//
//  Created by ap4y on 1/3/13.
//
//

#import "UIBezierPath_SVGTests.h"
#import "UIBezierPath+SVG.h"
#import "OCMock.h"

@interface UIBezierPath_SVGTests ()
@property (retain, nonatomic) UIBezierPath *aPath;
@property (retain, nonatomic) id aPathMock;
@end

@implementation UIBezierPath_SVGTests

- (void)setUp {
    [super setUp];
    self.aPath = [UIBezierPath bezierPath];
    self.aPathMock = [OCMockObject partialMockForObject:_aPath];
}

- (void)tearDown {
    [_aPathMock verify];
    [super tearDown];
}

- (void)testMoveToCommand {
    [[[_aPathMock expect] andForwardToRealObject] moveToPoint:CGPointMake(10.0f, 10.0f)];
    [[_aPathMock expect] moveToPoint:CGPointMake(20.0f, 20.0f)];
    [_aPathMock addPathsFromSVGString:@"M10,10 m10,10"];
}

- (void)testCloseCommand {
    [[_aPathMock expect] closePath];
    [_aPathMock addPathsFromSVGString:@"M10,10 m10,10 z"];
}

- (void)testLineToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addLineToPoint:CGPointMake(10.0f, 10.0f)];
    [[_aPathMock expect] addLineToPoint:CGPointMake(20.0f, 20.0f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 L10, 10 l10, 10"];
}

- (void)testHorizontalLineToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addLineToPoint:CGPointMake(10.0f, 0.0f)];
    [[_aPathMock expect] addLineToPoint:CGPointMake(20.0f, 0.0f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 H10 h10"];
}

- (void)testVerticalLineToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addLineToPoint:CGPointMake(0.0f, 10.0f)];
    [[_aPathMock expect] addLineToPoint:CGPointMake(0.0f, 20.0f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 V10 v10"];
}

- (void)testCurveToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addCurveToPoint:CGPointMake(30.0f, 30.0f)
                                                    controlPoint1:CGPointMake(10.0f, 10.0f)
                                                    controlPoint2:CGPointMake(20.0f, 20.f)];
    [[_aPathMock expect] addCurveToPoint:CGPointMake(40.0f, 40.0f)
                           controlPoint1:CGPointMake(20.0f, 20.0f)
                           controlPoint2:CGPointMake(30.0f, 30.f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 C10,10,20,20,30,30"];
    [_aPathMock addPathsFromSVGString:@"M10,10 c10,10,20,20,30,30"];
}

- (void)testSmoothCurveToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addCurveToPoint:CGPointMake(20.0f, 20.0f)
                                                    controlPoint1:CGPointMake(0.0f, 0.0f)
                                                    controlPoint2:CGPointMake(10.0f, 10.f)];
    [[_aPathMock expect] addCurveToPoint:CGPointMake(30.0f, 30.0f)
                           controlPoint1:CGPointMake(10.0f, 10.0f)
                           controlPoint2:CGPointMake(20.0f, 20.f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 S10,10,20,20"];
    [_aPathMock addPathsFromSVGString:@"M10,10 s10,10,20,20"];
}

- (void)testQuadraticCurveToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addQuadCurveToPoint:CGPointMake(20.0f, 20.0f)
                                                         controlPoint:CGPointMake(10.0f, 10.0f)];
    [[_aPathMock expect] addQuadCurveToPoint:CGPointMake(30.0f, 30.0f)
                                controlPoint:CGPointMake(20.0f, 20.0f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 Q10,10,20,20"];
    [_aPathMock addPathsFromSVGString:@"M10,10 q10,10,20,20"];
}

- (void)testSmoothQuadraticCurveToCommand {
    [[[_aPathMock expect] andForwardToRealObject] addQuadCurveToPoint:CGPointMake(10.0f, 10.0f)
                                                         controlPoint:CGPointMake(0.0f, 0.0f)];
    [[_aPathMock expect] addQuadCurveToPoint:CGPointMake(20.0f, 20.0f)
                                controlPoint:CGPointMake(10.0f, 10.0f)];
    [_aPathMock addPathsFromSVGString:@"M0,0 T10,10"];
    [_aPathMock addPathsFromSVGString:@"M10,10 t10,10"];
}

@end
