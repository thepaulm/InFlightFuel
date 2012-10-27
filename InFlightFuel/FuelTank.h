//
//  FuelTank.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//
#import "FuelValue.h"

@interface FuelTank : UIImageView //<NSCoding>

@property (copy, nonatomic) FuelValue *level;
@property (copy, nonatomic) FuelValue *min;
@property (copy, nonatomic) FuelValue *max;
@property (copy, nonatomic) FuelValue *diff;

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UITextField *text;
@property (strong, nonatomic) UITextField *tdiff;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UITextField *label;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)setLevel:(FuelValue *)level;
- (void)setMin:(FuelValue *)min;
- (void)setMax:(FuelValue *)max;
- (void)setDiff:(FuelValue *)diff;

@end
