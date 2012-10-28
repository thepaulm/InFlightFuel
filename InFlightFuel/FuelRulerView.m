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
@synthesize startedFuel;
@synthesize switchOverPoints;
@synthesize projectedSwitchOverPoints;
@synthesize startedTank;


#define TEXT_AREA_WIDTH 80
#define TEXT_LABEL_HEIGHT 10

#define TRIANGLE_HEIGHT 10
#define TRIANGLE_WIDTH 20
#define TOTAL_WIDTH 94

#define LEFT_TANK_X (TEXT_AREA_WIDTH + 13)
#define RIGHT_TANK_X (TEXT_AREA_WIDTH + 80)
#define TRIANGLE_VERTICAL_OFFSET 11
#define LINE_HORIZ_OFFSET 5

#define TEXT_USED_OFFSET 2
#define TEXT_REMAINING_OFFSET 40

- (void)commonInitialize
{
    self->startedTank = 0;
    self.backgroundColor = [[UIColor alloc]initWithWhite:1.0 alpha:0.0];
    self.userInteractionEnabled = FALSE;
}

- (id)init
{
    self = [super init];
    [self commonInitialize];
    return self;
}

- (void)layoutFromSliderRect:(UISlider*)slider
{
    CGRect src = slider.frame;
    float center = src.origin.x + src.size.width / 2.0;
    src.origin.x = center - TOTAL_WIDTH / 2;
    src.size.width = TOTAL_WIDTH;
    src.origin.x -= TEXT_AREA_WIDTH;
    src.size.width += TEXT_AREA_WIDTH;
    src.origin.y -= TEXT_LABEL_HEIGHT;
    src.size.height += TEXT_LABEL_HEIGHT;
    self.frame = src;
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [self setMaxFuel:nil];
    [self setStartedFuel:nil];
    [self setSwitchOverPoints:nil];
    [self setProjectedSwitchOverPoints:nil];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);

    CGContextSelectFont(context, "Arial", 12.0, kCGEncodingMacRoman);
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    CGContextShowTextAtPoint(context, TEXT_USED_OFFSET, TEXT_LABEL_HEIGHT, "Used", 4);
    CGContextShowTextAtPoint(context, TEXT_REMAINING_OFFSET, TEXT_LABEL_HEIGHT, "Remaining", 9);
    
    /* Make the frame - remove this later */
#ifdef DO_BORDER
    CGContextMoveToPoint(context, 0,0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
#endif
    
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
        CGContextAddLineToPoint(context, x2 - TRIANGLE_WIDTH, y2);
    } else {
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y1);
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y2);
        CGContextAddLineToPoint(context, x2 + TRIANGLE_WIDTH, y2);
    }
    CGContextStrokePath(context);
}

-(int)getLocyForFuelValue:(FuelValue*)v
{
    /* Figure out at what percentage down the view to draw */
    float pct = [v toFloat] / [self->maxFuel toFloat];
    pct = 1.0 - pct;
    CGRect r = self.frame;
    /* Now find the absolute y location */
    int locy = pct * (r.size.height - TEXT_LABEL_HEIGHT - TRIANGLE_VERTICAL_OFFSET * 2) + TRIANGLE_VERTICAL_OFFSET + TEXT_LABEL_HEIGHT;
    return locy;
}

-(NSString *)getUsedFuelString:(FuelValue *)v
{
    FuelValue *n = [self->startedFuel minus:v];
    NSString *nss = [n toString];
    return nss;
}

-(const char *)getCString:(NSString *)nss
{
    const char *s = [nss cStringUsingEncoding: [NSString defaultCStringEncoding]];
    return s;
}

-(void)drawSwitchOverPoints
{
    int current = self->startedTank;
    int lasty = -1;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSelectFont(context, "Arial", 12.0, kCGEncodingMacRoman);

    NSArray *v = self.switchOverPoints;
    for (FuelValue *x in v) {
        int locy = [self getLocyForFuelValue:x];
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
        /* Keep the NSString around for calls to getCString.  This is how we guarantee
           it to be valid */
        NSString *nss = [x toString];
        const char *s = [self getCString:nss];
        CGContextShowTextAtPoint(context, TEXT_REMAINING_OFFSET, locy + 4, s, strlen(s));
        nss = [self getUsedFuelString:x];
        s = [self getCString:nss];
        CGContextShowTextAtPoint(context, TEXT_USED_OFFSET, locy + 4, s, strlen(s));
        lasty = locy;
    }
}

-(void)drawProjectedSwitchOverPoints
{
    int current = self->startedTank;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [[UIColor alloc]initWithRed:0.8 green:0.0 blue:0.8 alpha:1.0].CGColor);
    CGContextSetFillColorWithColor(context, [[UIColor alloc]initWithRed:0.0 green:1 blue:1 alpha:1.0].CGColor);
    CGContextSelectFont(context, "Arial", 16.0, kCGEncodingMacRoman);
    
    if ([self->switchOverPoints count] % 2 != 0) {
        if (current == 0) {
            current = 1;
        } else {
            current = 0;
        }
    }
    int lasty = -1;
    if ([self->switchOverPoints count]) {
        FuelValue *v = [self->switchOverPoints lastObject];
        lasty = [self getLocyForFuelValue:v];
    }

    NSArray *v = self.projectedSwitchOverPoints;
    for (FuelValue *x in v) {
        int locy = [self getLocyForFuelValue:x];
        if (current == 0) {
            [self drawLeftTankTriangle:locy :FALSE];
            current = 1;
        } else {
            [self drawRightTankTriangle:locy :FALSE];
            current = 0;
        }
        
        if (current == 0) {
            [self drawConnectingLines:LEFT_TANK_X :lasty :RIGHT_TANK_X :locy];
        } else {
            [self drawConnectingLines:RIGHT_TANK_X :lasty :LEFT_TANK_X :locy];
        }
        NSString *nss = [x toString];
        const char *s = [self getCString:nss];
        CGContextShowTextAtPoint(context, TEXT_REMAINING_OFFSET, locy + 4, s, strlen(s));
        nss = [self getUsedFuelString:x];
        s = [self getCString:nss];
        CGContextShowTextAtPoint(context, TEXT_USED_OFFSET, locy + 4, s, strlen(s));
    }
}

@end
