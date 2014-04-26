//
//  FuelRulerView.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 10/9/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FuelValue.h"

@interface FuelRulerView : UIView
{
    CGFloat font_size;
    NSInteger text_used_offset;
    NSInteger text_remaining_offset;
    NSInteger center_x;
    NSInteger draw_width;
    NSInteger triangle_height;
    NSInteger triangle_width;
    NSInteger triangle_vertical_offset;
    NSInteger text_label_height;
};

@property (copy, nonatomic) FuelValue *maxFuel;
@property (copy, nonatomic) FuelValue *startedFuel;
@property (copy, nonatomic) NSArray *switchOverPoints;
@property (copy, nonatomic) NSArray *projectedSwitchOverPoints;
@property int startedTank;

- (id)init;
- (void)layoutFromSliderRect:(UISlider*)slider :(CGRect)backgroundFrame;
- (void)drawRect:(CGRect)rect;
- (void)drawLeftTankTriangle:(int)y :(BOOL)fill;
- (void)drawRightTankTriangle:(int)y :(BOOL)fill;
- (void)drawConnectingLines:(int)x1 :(int)y1 :(int)x2 :(int)y2;

- (void)drawSwitchOverPoints;
- (void)drawProjectedSwitchOverPoints;

- (void)dealloc;

@end
