//
//  FuelRulerView.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 10/9/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "FuelRulerView.h"

@implementation FuelRulerView

@synthesize maxFuel;
@synthesize switchOverPoints;
@synthesize projectedSwitchOverPoints;
@synthesize startedTank;

#define TRIANGLE_HEIGHT 10
#define TRIANGLE_WIDTH 20
#define TOTAL_WIDTH 94
#define LEFT_TANK_X 13
#define RIGHT_TANK_X 80
#define TRIANGLE_VERTICAL_OFFSET 11
#define LINE_HORIZ_OFFSET 5

- (void)commonInitialize
{
    if (self)
        self->startedTank = 0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInitialize];
    return self;
}

- (id)initFromSliderRect:(UISlider*)slider
{
    CGRect frame = slider.frame;
    /*
    frame.origin.y -= TRIANGLE_VERTICAL_OFFSET;
    frame.size.height += 2 * TRIANGLE_VERTICAL_OFFSET;
     */
    float center = frame.origin.x + frame.size.width / 2.0;
    frame.origin.x = center - TOTAL_WIDTH / 2;
    frame.size.width = TOTAL_WIDTH;
    self = [super initWithFrame:frame];
    self.backgroundColor = [[UIColor alloc]initWithWhite:1.0 alpha:0.0];
    self.userInteractionEnabled = FALSE;
    [self commonInitialize];
    return self;
}

- (void)dealloc
{
    [self setMaxFuel:nil];
    [self setSwitchOverPoints:nil];
    [self setProjectedSwitchOverPoints:nil];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);

    
    /* Make the frame - remove this later */
    CGContextMoveToPoint(context, 0,0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    
    /* Update the points */
    [self drawSwitchOverPoints];
    [self drawProjectedSwitchOverPoints];
}

-(void)drawLeftTankTriangle:(int)y :(BOOL)fill
{
    int x = LEFT_TANK_X;
    CGPathDrawingMode mode = fill ? kCGPathFillStroke : kCGPathStroke;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x, y - TRIANGLE_HEIGHT / 2);
    CGContextAddLineToPoint(context, x + TRIANGLE_WIDTH, y);
    CGContextAddLineToPoint(context, x, y + TRIANGLE_HEIGHT / 2);
    CGContextAddLineToPoint(context, x, y - TRIANGLE_HEIGHT / 2);
    
    CGContextDrawPath(context, mode);
}

-(void)drawRightTankTriangle:(int)y :(BOOL)fill
{
    int x = RIGHT_TANK_X;
    CGPathDrawingMode mode = fill ? kCGPathFillStroke : kCGPathStroke;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x, y - TRIANGLE_HEIGHT / 2);
    CGContextAddLineToPoint(context, x - TRIANGLE_WIDTH, y);
    CGContextAddLineToPoint(context, x, y + TRIANGLE_HEIGHT / 2);
    CGContextAddLineToPoint(context, x, y - TRIANGLE_HEIGHT / 2);
    
    CGContextDrawPath(context, mode);
}

-(void)drawConnectingLines:(int)x1 :(int)y1 :(int)x2 :(int)y2
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x1, y1);
    if (x1 < x2) {
        CGContextAddLineToPoint(context, x1 - LINE_HORIZ_OFFSET, y1);
        CGContextAddLineToPoint(context, x1 - LINE_HORIZ_OFFSET, y2);
    } else {
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y1);
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y2);
    }
    CGContextAddLineToPoint(context, x2, y2);
    CGContextStrokePath(context);
}

-(void)drawSwitchOverPoints
{
    int current = self->startedTank;
    int lasty = -1;

    NSArray *v = self.switchOverPoints;
    for (FuelValue *x in v) {
        NSLog(@"Drawing: %@", [x toString]);
        /* Figure out at what percentage down the view to draw */
        float pct = [x toFloat] / [self->maxFuel toFloat];
        pct = 1.0 - pct;
        CGRect r = self.frame;
        /* Now find the absolute y location */
        int locy = pct * (r.size.height - TRIANGLE_VERTICAL_OFFSET * 2) + TRIANGLE_VERTICAL_OFFSET;
        /* Draw based on which tank */
        if (current == 0) {
            [self drawLeftTankTriangle:locy :TRUE];
            current = 1;
        } else {
            [self drawRightTankTriangle:locy :TRUE];
            current = 0;
        }
        /* Draw connecting lines */
        if (lasty != -1) {
            if (current == 0) {
                [self drawConnectingLines:LEFT_TANK_X :lasty :RIGHT_TANK_X :locy];
            } else {
                [self drawConnectingLines:RIGHT_TANK_X :lasty :LEFT_TANK_X :locy];
            }
        }
        lasty = locy;
    }
}

-(void)drawProjectedSwitchOverPoints
{
    int current = self->startedTank;

    if ([self->switchOverPoints count] % 2 != 0) {
        if (current == 0) {
            current = 1;
        } else {
            current = 0;
        }
    }

    NSArray *v = self.projectedSwitchOverPoints;
    for (FuelValue *x in v) {
        NSLog(@"Hollow Drawing: %@", [x toString]);
        float pct = [x toFloat] / [self->maxFuel toFloat];
        pct = 1.0 - pct;
        CGRect r = self.frame;
        int locy = pct * (r.size.height - TRIANGLE_VERTICAL_OFFSET * 2) + TRIANGLE_VERTICAL_OFFSET;
        if (current == 0) {
            [self drawLeftTankTriangle:locy :FALSE];
            current = 1;
        } else {
            [self drawRightTankTriangle:locy :FALSE];
            current = 0;
        }
    }
}

@end
