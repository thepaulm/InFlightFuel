//
//  iffViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iffViewController : UIViewController
- (IBAction)sliderLeftTank:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textLeftTank;
@property (weak, nonatomic) IBOutlet UISlider *sliderLeftTank;

- (IBAction)sliderRightTank:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textRightTank;
@property (weak, nonatomic) IBOutlet UISlider *sliderRightTank;

@property (weak, nonatomic) IBOutlet UITextField *textBothTanks;
- (IBAction)sliderBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderBothTanks;


@property (weak, nonatomic) IBOutlet UISegmentedControl *leftRightTank;
- (IBAction)switchOn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textUsedFuel;
- (IBAction)stepperBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepperBothTanks;
- (IBAction)stepperLeftTank:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepperLeftTank;
- (IBAction)stepperRightTank:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepperRightTank;
@property (weak, nonatomic) IBOutlet UITextField *leftTankDiff;
@property (weak, nonatomic) IBOutlet UITextField *rightTankDiff;

@end
