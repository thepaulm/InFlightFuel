//
//  iffViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iffOptionsViewController.h"

@interface iffViewController : UIViewController <iffOptionsViewControllerDelegate>
{
    float leftTankFuel;
    float rightTankFuel;
    BOOL ison;
    float startedFuel;
    float valueTabs;
    float valueFull;
    float maxEachTank;
}
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
@property (weak, nonatomic) IBOutlet UITextField *leftTankDiff;
@property (weak, nonatomic) IBOutlet UITextField *rightTankDiff;
- (IBAction)fuelTabs:(id)sender;
- (IBAction)fuelFull:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *tabsValue;
@property (weak, nonatomic) IBOutlet UITextField *fullValue;

@end
