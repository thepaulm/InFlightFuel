//
//  iffViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iffOptionsViewController.h"
#import "iffInfoViewController.h"
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
    int activeTank;
    int valueStartedFuel;
    int isOn;
    int startedTank;
    int runningTimer;
}

@property (copy, nonatomic) NSMutableArray *switchOverPoints;
@property (copy, nonatomic) NSDate *timerStart;

- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

@interface iffSaveSettings : NSObject <NSCoding>
{
    @public
    int valueTabs;
    int valueFull;
    int targetDiff;
    int initialTimer;
    int subsequentTimer;
}

- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

#pragma mark -
#pragma mark iffViewController

@interface iffViewController : UIViewController
    <iffOptionsViewControllerDelegate, iffInfoViewControllerDelegate>
{
    BOOL ison;
    NSMutableArray *switchOverPoints;
    NSMutableArray *projectedSwitchOverPoints;
    int startTank;
    int runningTimer; // 0 is off, 1 is initial, 2 is subsequent
}

/* Value Elements */
@property (copy, nonatomic) FuelValue *startedFuel;
@property (copy, nonatomic) FuelValue *valueTabs;
@property (copy, nonatomic) FuelValue *valueFull;
@property (copy, nonatomic) FuelValue *maxEachTank;
@property (copy, nonatomic) FuelValue *targetDiff;
@property (copy, nonatomic) NSValue *valueInitialTimer;
@property (copy, nonatomic) NSValue *valueSubsequentTimer;

@property (copy, nonatomic) NSDate *timerStart;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UILocalNotification *notification;

/* Save Data */
- (void)saveLastTankValues;
- (iffSaveData*)loadSaveData;

/* Fuel Tanks */
@property (weak, nonatomic) IBOutlet FuelTank *rightFuelTank;
@property (weak, nonatomic) IBOutlet FuelTank *leftFuelTank;

/* UI Elements */
@property (weak, nonatomic) IBOutlet UITextField *textBothTanks;
- (IBAction)sliderBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *sliderBothTanks;
@property (strong, nonatomic) IBOutlet FuelRulerView *fuelRuler;
- (IBAction)switchedTank:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *inFlightSwitch;
@property (weak, nonatomic) IBOutlet UITextField *timerText;

@property (weak, nonatomic) IBOutlet UISegmentedControl *leftRightTank;
- (IBAction)switchOn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textUsedFuel;
- (IBAction)stepperBothTanks:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *stepperBothTanks;
- (IBAction)fuelTabs:(id)sender;
- (IBAction)fuelFull:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;

@property (weak, nonatomic) IBOutlet UITextField *tabsValue;
@property (weak, nonatomic) IBOutlet UITextField *fullValue;
@property (weak, nonatomic) IBOutlet UITextField *textDiff;
@property (weak, nonatomic) IBOutlet UIButton *buttonTabs;
@property (weak, nonatomic) IBOutlet UIButton *buttonFull;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)sliderTouchUpOutside:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *sliderBackground;

@end
