//
//  FuelTank.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "FuelTank.h"

/*
 - (void)drawRect:(CGRect)rect
 CGContextRef context    = UIGraphicsGetCurrentContext();
 
 CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
 
 // Draw them with a 2.0 stroke width so they are a bit more visible.
 CGContextSetLineWidth(context, 2.0);
 
 
 CGContextMoveToPoint(context, 0,0); //start at this point
 
 CGContextAddLineToPoint(context, 20, 20); //draw to this point
 
 // and now draw the Path!
 CGContextStrokePath(context);
 }
 */

#define TWIDTH 97
#define THEIGHT 24
#define SLIDER_HORIZ_PCT 0.88
#define SLIDER_VERT_PCT 0.50
#define SLIDER_LENGTH_PCT 0.95

@implementation FuelTank

@synthesize slider;
@synthesize text;
@synthesize tdiff;
@synthesize label;
@synthesize name;

@synthesize level;
@synthesize min;
@synthesize max;
@synthesize diff;

- (void)layoutSubviews
{    
    CGRect src = [self frame];
    CGRect res = [self transformedSliderFrameFromFrame:src];
    self.slider.frame = res;
    
    res = [self labelFrameFromSliderFrame:res];
    self.label.frame = res;
    
    res.origin.y += 2 * THEIGHT;
    self.text.frame = res;
    
    res.origin.y += 2 * THEIGHT;
    self.tdiff.frame = res;
}

- (void)allinit
{
    /* Use -> here = don't want to copy these initializers */
    self->level = [[FuelValue alloc]initFromInt:0];
    self->min = [[FuelValue alloc]initFromInt:0];
    self->max = [[FuelValue alloc]initFromInt:0];
    self->diff = [[FuelValue alloc]initFromInt:0];
    [self drawRelativeFrame];
}

- (id)init
{
    self = [self init];
    [self allinit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self allinit];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self allinit];
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    [self allinit];
    return self;
}

- (void)setName:(NSString *)n
{
    self->name = n;
    self.label.text = self->name;
}

- (CGRect)transformedSliderFrameFromFrame:(CGRect)src
{
    CGRect res = src;
    res.size.height = SLIDER_LENGTH_PCT * src.size.height;
    res.size.width = 1;
    res.origin.x = SLIDER_HORIZ_PCT * src.size.width - res.size.width / 2;
    res.origin.y = SLIDER_VERT_PCT * src.size.height - res.size.height / 2;
    return res;   
}

- (CGRect)labelFrameFromSliderFrame:(CGRect)src
{
    return CGRectMake(src.origin.x + src.size.width / 2 - TWIDTH - 15,
                      src.origin.y + src.size.height - THEIGHT - 4 * THEIGHT,
                      TWIDTH, THEIGHT);    
}

/*
 CGRect.origin.{x, y}
 CGRect.size.{width, height}
 
 We are going to rotate this thing 90 degrees to the left.  We need to calculate what the
 new x,y,width,height will be translated.
  
 */
- (void)drawRelativeFrame
{    
    /* Set up the slider */
    [self setSlider:[[UISlider alloc]init]];
    [self addSubview:[self slider]];
    [self.slider setTransform:CGAffineTransformRotate(self.slider.transform,270.0/180*M_PI)];
    [self.slider setUserInteractionEnabled:FALSE];
    /*
     enum {
     UIControlStateNormal               = 0,
     UIControlStateHighlighted          = 1 << 0,
     UIControlStateDisabled             = 1 << 1,
     UIControlStateSelected             = 1 << 2,
     UIControlStateApplication          = 0x00FF0000,
     UIControlStateReserved             = 0xFF000000
     };*/
    UIImage *sliderThumb = [UIImage imageNamed:@"FuelSliderLevel.png"];
    
    [self.slider setThumbImage:sliderThumb forState:UIControlStateNormal];
    [self.slider setThumbImage:sliderThumb forState:UIControlStateHighlighted];
    [self.slider setThumbImage:sliderThumb forState:UIControlStateDisabled];
    [self.slider setThumbImage:sliderThumb forState:UIControlStateSelected];
    
    /* Set up the label */    
    [self setLabel:[[UITextField alloc]init]];
    self.label.borderStyle = UITextBorderStyleRoundedRect;
    self.label.enabled = FALSE;
    self.label.text = self.name;
    self.label.font = [UIFont systemFontOfSize:14.0];
    self.label.textAlignment = UITextAlignmentLeft;
    [self addSubview:self.label];
    
    /* Set up the total avail text */
    [self setText:[[UITextField alloc]init]];
    self.text.borderStyle = UITextBorderStyleRoundedRect;
    self.text.adjustsFontSizeToFitWidth = TRUE;
    self.text.enabled = FALSE;
    self.text.font = [UIFont systemFontOfSize:14.0];
    self.text.textAlignment = UITextAlignmentLeft;
    [self addSubview:self.text];
    
    /* Set up the total diff text */
    [self setTdiff:[[UITextField alloc]init]];
    self.tdiff.borderStyle = UITextBorderStyleRoundedRect;
    self.tdiff.adjustsFontSizeToFitWidth = TRUE;
    self.tdiff.enabled = FALSE;
    self.tdiff.font = [UIFont systemFontOfSize:14.0];
    self.tdiff.textAlignment = UITextAlignmentLeft;
    [self addSubview:self.tdiff];
    
    [self setMin:self.min];
    [self setMax:self.max];
    [self setLevel:self.level];
    [self setDiff:self.diff];
}

- (void)setLevel:(FuelValue *)l
{
    if (self->level != l) {
        self->level = [l copy];
    }
    self.slider.value = [l toFloat];
    self.text.text = [l toString];
}

- (void)setMin:(FuelValue *)l
{
    if (self->min != l) {
        self->min = [l copy];
    }
    self.slider.minimumValue = [l toFloat];
}

- (void)setMax:(FuelValue *)l
{
    if (self->max != l) {
        self->max = [l copy];
    }
    self.slider.maximumValue = [l toFloat];
    self.slider.value = [self.level toFloat];
}

- (void)setDiff:(FuelValue *)l
{
    if (self->diff != l) {
        self->diff = [l copy];
    }
    if ([l lt:[[FuelValue alloc]initFromInt:0]]) {
        self.tdiff.text = [[NSString alloc]initWithFormat:@"%@ gl", [self.diff toString]];
    } else {
        self.tdiff.text = [[NSString alloc]initWithFormat:@"+%@ gl", [self.diff toString]];
    }
}
@end
