//
//  FuelTank.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "FuelTank.h"


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

- (id)initWithLabel:(NSString *)l
{
    self = [super init];
    [self setLevel: [[FuelValue alloc]initFromInt:0]];
    [self setMin: [[FuelValue alloc]initFromInt:0]];
    [self setMax: [[FuelValue alloc]initFromInt:0]];
    [self setDiff: [[FuelValue alloc]initFromInt:0]];
    self.text = nil;
    self.tdiff = nil;
    self.name = l;
    return self;
}

#define TWIDTH 97
#define THEIGHT 31
/*
 CGRect.origin.{x, y}
 CGRect.size.{width, height}
 
 We are going to rotate this thing 90 degrees to the left.  We need to calculate what the
 new x,y,width,height will be translated.
  
 */
- (void)drawRelativeFrame:(UIView*)parent :(CGRect)pct
{
    CGRect src = [parent frame];
    CGRect res = src;
    
    /* Set up the slider */
    res.size.width = pct.size.height * src.size.height;
    res.size.height = 1;
    res.origin.x = pct.origin.x * src.size.width - res.size.width / 2;
    res.origin.y = pct.origin.y * src.size.height - res.size.height / 2 - res.size.width / 2;
    
    [self setSlider:[[UISlider alloc]initWithFrame:res]];
    [parent addSubview:[self slider]];
    [self.slider setTransform:CGAffineTransformRotate(self.slider.transform,270.0/180*M_PI)];
    [self.slider setUserInteractionEnabled:FALSE];
    
    /* Set up the label */
    CGRect tr = CGRectMake(res.origin.x + res.size.width / 2 - TWIDTH - 20,
                           res.origin.y + res.size.width / 2 - THEIGHT - 4 * THEIGHT,
                           TWIDTH, THEIGHT);
    
    [self setLabel:[[UITextField alloc]initWithFrame:tr]];
    self.label.borderStyle = UITextBorderStyleRoundedRect;
    self.label.enabled = FALSE;
    self.label.text = self.name;
    self.label.font = [UIFont systemFontOfSize:14.0];
    self.label.textAlignment = UITextAlignmentLeft;
    [parent addSubview:self.label];
    
    /* Set up the total avail text */
    tr.origin.y += 2 * THEIGHT;
    [self setText:[[UITextField alloc]initWithFrame:tr]];
    self.text.borderStyle = UITextBorderStyleRoundedRect;
    self.text.adjustsFontSizeToFitWidth = TRUE;
    self.text.enabled = FALSE;
    self.text.font = [UIFont systemFontOfSize:14.0];
    self.text.textAlignment = UITextAlignmentLeft;
    [parent addSubview:self.text];
    
    /* Set up the total diff text */
    tr.origin.y += 2 * THEIGHT;
    [self setTdiff:[[UITextField alloc]initWithFrame:tr]];
    self.tdiff.borderStyle = UITextBorderStyleRoundedRect;
    self.tdiff.adjustsFontSizeToFitWidth = TRUE;
    self.tdiff.enabled = FALSE;
    self.tdiff.font = [UIFont systemFontOfSize:14.0];
    self.tdiff.textAlignment = UITextAlignmentLeft;
    [parent addSubview:self.tdiff];
    
    [self setMin:self.min];
    [self setMax:self.max];
    [self setLevel:self.level];
    [self setDiff:self.diff];
}

- (void)setLevel:(FuelValue *)l
{
    self->level = l;
    self.slider.value = [l toFloat];
    self.text.text = [l toString];
}

- (void)setMin:(FuelValue *)l
{
    self->min = l;
    self.slider.minimumValue = [l toFloat];
}

- (void)setMax:(FuelValue *)l
{
    self->max = l;
    self.slider.maximumValue = [l toFloat];
}

- (void)setDiff:(FuelValue *)l
{
    self->diff = l;
    if ([l lt:[[FuelValue alloc]initFromInt:0]]) {
        self.tdiff.text = [[NSString alloc]initWithFormat:@"%@ gl", [self.diff toString]];
    } else {
        self.tdiff.text = [[NSString alloc]initWithFormat:@"+%@ gl", [self.diff toString]];
    }
}
@end
