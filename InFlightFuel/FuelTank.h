//
//  FuelTank.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

@interface FuelTank : NSObject //<NSCoding>
{
    @public
    float level;
    float min;
    float max;
    float diff;
}

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UITextField *text;
@property (strong, nonatomic) UITextField *tdiff;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UITextField *label;

- (id)initWithLabel:(NSString*)l;
- (void)drawRelativeFrame:(UIView*)parent :(CGRect)pct;
- (void)setLevel:(float)l;
- (void)setMin:(float)l;
- (void)setMax:(float)l;
- (void)setDiff:(float)l;
- (NSString*)getValueString;

@end
