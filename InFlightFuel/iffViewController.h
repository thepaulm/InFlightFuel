//
//  iffViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iffOptionsViewController.h"
#import "FuelTank.h"
#import "FuelValue.h"
#import "FuelRulerView.h"

#pragma mark -
#pragma mark iffSaveData

@interface iffSaveData : NSObject <NSCoding>
{
    @public
    int leftTankLevel;
    int rightTankLevel;
}

- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

#pragma mark -
#pragma mark iffViewController

@interface iffViewController : UIViewController <iffOptionsViewControllerDelegate>
{
    BOOL ison;
    NSMutableArray *switchOverPoints;
    NSMutableArray *projectedSwitchOverPoints;
    int startTank;
}

/* Value Elements */
@property (copy, nonatomic) FuelValue *startedFuel;
@property (copy, nonatomic) FuelValue *valueTabs;
@property (copy, nonatomic) FuelValue *valueFull;
@property (copy, nonatomic) FuelValue *maxEachTank;
@property (copy, nonatomic) FuelValue *targetDiff;

/* Save Data */
- (void)saveLastTankValues;
- (iffSaveData*)loadSaveData;

/* Fuel Tanks */
@property (strong, nonatomic) FuelTank *leftFuelTank;
@property (strong, nonatomic) FuelTank *rightFuelTank;

/* UI Elements */
@property (weak, nonatomic) IBOutlet UITextField *textBothTanks;
- (IBAction)sliderBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderBothTanks;
@property (weak, nonatomic) IBOutlet FuelRulerView *fuelRuler;
- (IBAction)switchedTank:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *leftRightTank;
- (IBAction)switchOn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textUsedFuel;
- (IBAction)stepperBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepperBothTanks;
- (IBAction)fuelTabs:(id)sender;
- (IBAction)fuelFull:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *tabsValue;
@property (weak, nonatomic) IBOutlet UITextField *fullValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonTabs;
@property (weak, nonatomic) IBOutlet UIButton *buttonFull;

@end
