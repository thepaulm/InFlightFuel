//
//  FuelTank.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//
#import "FuelValue.h"

@interface FuelTank : NSObject //<NSCoding>

@property (copy, nonatomic) FuelValue *level;
@property (copy, nonatomic) FuelValue *min;
@property (copy, nonatomic) FuelValue *max;
@property (copy, nonatomic) FuelValue *diff;

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UITextField *text;
@property (strong, nonatomic) UITextField *tdiff;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UITextField *label;

- (id)initWithLabel:(NSString*)l;
- (void)drawRelativeFrame:(UIView*)parent :(CGRect)pct;

@end
