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


/* Relative values */
#define TEXT_XOFF_RELATIVE 0.025
#define TEXT_REMAINING_XOFF_RELATIVE 0.18

#define SLIDER_X_PCT 0.57

#define DRAWING_WIDTH_PCT 0.3

#define TEXT_FONT_SIZE_RELATIVE 0.05

/* Absolute values */
#define TEXT_LABEL_HEIGHT_PCT 0.039

#define TRIANGLE_HEIGHT_PCT 0.039
#define TRIANGLE_WIDTH_PCT 0.08
#define TRIANGLE_VERTICAL_OFFSET_PCT 0.043

#define LINE_HORIZ_OFFSET 5

#define SLIDER_IMAGE_CHOP 16

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

- (void)layoutFromSliderRect:(UISlider*)slider :(CGRect)backgroundFrame
                            :(int)top :(int)bottom
{
    self->text_used_offset = backgroundFrame.size.width * TEXT_XOFF_RELATIVE;
    self->text_remaining_offset = backgroundFrame.size.width * TEXT_REMAINING_XOFF_RELATIVE;
    self->font_size = backgroundFrame.size.width * TEXT_FONT_SIZE_RELATIVE;
    self->triangle_height = backgroundFrame.size.width * TRIANGLE_HEIGHT_PCT;
    self->triangle_width = backgroundFrame.size.width * TRIANGLE_WIDTH_PCT;
    self->triangle_vertical_offset = backgroundFrame.size.width * TRIANGLE_VERTICAL_OFFSET_PCT;
    self->text_label_height = backgroundFrame.size.width * TEXT_LABEL_HEIGHT_PCT;
    
    /* Set up the frame for the slider */
    CGRect frame = {0, 0, 0, 0};
    
    frame.origin.x = backgroundFrame.origin.x + backgroundFrame.size.width * SLIDER_X_PCT;
    frame.origin.y = top + self->text_label_height * 2;
    frame.size.height = bottom - top;
    
    frame.size.width = slider.frame.size.width;
    slider.frame = frame;
    
    self->slider_image_chop = SLIDER_IMAGE_CHOP;
    
    /* set up our frame for the drawing */
    
    /* Total drawing width relative to our background frame */
    self->draw_width = backgroundFrame.size.width * DRAWING_WIDTH_PCT;

    self->center_x = frame.origin.x + frame.size.width / 2; // take our center from the sliders origin
    
    /* Figure out how wide just for the drawing */
    frame.origin.x = self->center_x - self->draw_width / 2;
    frame.size.width = self->draw_width;
    
    /* Make room for the text */
    frame.size.width += (frame.origin.x - backgroundFrame.origin.x + self->text_used_offset);
    /* Make some extra so we can draw on the right */
    frame.size.width  *= 1.15;
    frame.origin.x = backgroundFrame.origin.x + self->text_used_offset;
    frame.origin.y -= self->text_label_height;
    frame.size.height += self->text_label_height;
    
    /* We're about to reset out frame, make center relative */
    self->center_x -= frame.origin.x;
    self.frame = frame;
    
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
    
    CGContextSelectFont(context, "Arial", self->font_size, kCGEncodingMacRoman);
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    CGContextShowTextAtPoint(context, self->text_used_offset, self->text_label_height, "Used", 4);
    CGContextShowTextAtPoint(context, self->text_remaining_offset, self->text_label_height, "Remaining", 9);
    
    /* Make the frame - remove this later */
#ifdef DO_BORDER
    CGContextMoveToPoint(context, 0,0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
#endif
    
    /* Update the points */
    [self drawSwitchOverPoints];
    [self drawProjectedSwitchOverPoints];
}

-(void)drawLeftTankTriangle:(int)y :(BOOL)fill
{
    int x = (int)(self->center_x - self->draw_width / 2);
    CGPathDrawingMode mode = fill ? kCGPathFillStroke : kCGPathStroke;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x, y - self->triangle_height / 2);
    CGContextAddLineToPoint(context, x + self->triangle_width, y);
    CGContextAddLineToPoint(context, x, y + self->triangle_height / 2);
    CGContextAddLineToPoint(context, x, y - self->triangle_height / 2);
    
    CGContextDrawPath(context, mode);
}

-(void)drawRightTankTriangle:(int)y :(BOOL)fill
{
    int x = (int)(self->center_x + self->draw_width / 2);
    CGPathDrawingMode mode = fill ? kCGPathFillStroke : kCGPathStroke;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x, y - self->triangle_height / 2);
    CGContextAddLineToPoint(context, x - self->triangle_width, y);
    CGContextAddLineToPoint(context, x, y + self->triangle_height / 2);
    CGContextAddLineToPoint(context, x, y - self->triangle_height / 2);
    
    CGContextDrawPath(context, mode);
}

-(void)drawConnectingLines:(int)x1 :(int)y1 :(int)x2 :(int)y2
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x1, y1);
    if (x1 < x2) {
        CGContextAddLineToPoint(context, x1 - LINE_HORIZ_OFFSET, y1);
        CGContextAddLineToPoint(context, x1 - LINE_HORIZ_OFFSET, y2);
        CGContextAddLineToPoint(context, x2 - self->triangle_width, y2);
    } else {
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y1);
        CGContextAddLineToPoint(context, x1 + LINE_HORIZ_OFFSET, y2);
        CGContextAddLineToPoint(context, x2 + self->triangle_width, y2);
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
                      // slider height
    int locy = pct * (r.size.height - self->text_label_height - self->slider_image_chop * 2) + self->text_label_height + self->slider_image_chop;
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
    CGContextSelectFont(context, "Arial", self->font_size, kCGEncodingMacRoman);

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
                [self drawConnectingLines:(int)(self->center_x - self->draw_width / 2)
                                         :lasty
                                         :(int)(self->center_x + self->draw_width / 2)
                                         :locy];
            } else {
                [self drawConnectingLines:(int)(self->center_x + self->draw_width / 2)
                                         :lasty
                                         :(int)(self->center_x - self->draw_width / 2)
                                         :locy];
            }
        }
        /* Keep the NSString around for calls to getCString.  This is how we guarantee
           it to be valid */
        NSString *nss = [x toString];
        const char *s = [self getCString:nss];
        CGContextShowTextAtPoint(context, self->text_remaining_offset, locy + 4, s, strlen(s));
        nss = [self getUsedFuelString:x];
        s = [self getCString:nss];
        CGContextShowTextAtPoint(context, self->text_used_offset, locy + 4, s, strlen(s));
        lasty = locy;
    }
}

-(void)drawProjectedSwitchOverPoints
{
    int current = self->startedTank;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [[UIColor alloc]initWithRed:0.8 green:0.0 blue:0.8 alpha:1.0].CGColor);
    CGContextSetFillColorWithColor(context, [[UIColor alloc]initWithRed:0.0 green:1 blue:1 alpha:1.0].CGColor);
    CGFloat big_font = (int)(self->font_size * 1.3);
    CGContextSelectFont(context, "Arial", big_font, kCGEncodingMacRoman);
    
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
            [self drawConnectingLines:(int)(self->center_x - self->draw_width / 2)
                                     :lasty
                                     :(int)(self->center_x + self->draw_width / 2)
                                     :locy];
        } else {
            [self drawConnectingLines:(int)(self->center_x + self->draw_width / 2)
                                     :lasty
                                     :(int)(self->center_x - self->draw_width / 2)
                                     :locy];
        }
        NSString *nss = [x toString];
        const char *s = [self getCString:nss];
        CGContextShowTextAtPoint(context, self->text_remaining_offset, locy + 4, s, strlen(s));
        nss = [self getUsedFuelString:x];
        s = [self getCString:nss];
        CGContextShowTextAtPoint(context, self->text_used_offset, locy + 4, s, strlen(s));
    }
}

@end
