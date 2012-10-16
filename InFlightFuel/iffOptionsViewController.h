//
//  iffOptionsViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 8/28/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FuelValue.h"

@class iffOptionsViewController;

@protocol iffOptionsViewControllerDelegate
- (void)iffOptionsViewControllerDidFinish:(iffOptionsViewController*)controller;
@end

@interface iffOptionsViewController : UIViewController <UITextFieldDelegate>

@property (copy, nonatomic) FuelValue *valueTabs;
@property (copy, nonatomic) FuelValue *valueFull;
@property (copy, nonatomic) FuelValue *valueDiff;

@property (weak, nonatomic) id <iffOptionsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textTabs;
@property (weak, nonatomic) IBOutlet UITextField *textFull;
@property (weak, nonatomic) IBOutlet UITextField *textDiff;
@property (weak, nonatomic) IBOutlet UIStepper *stepperTabs;
@property (weak, nonatomic) IBOutlet UIStepper *stepperFull;
@property (weak, nonatomic) IBOutlet UIStepper *stepperDiff;

- (void)initializeValues:(FuelValue*)vt valueFull:(FuelValue*)vf valueDiff:(FuelValue*)vd;

- (IBAction)clickDone:(id)sender;
- (IBAction)onStepperTabs:(id)sender;
- (IBAction)onStepperFull:(id)sender;
- (IBAction)onStepperDiff:(id)sender;
- (IBAction)onTabsText:(id)sender;
- (IBAction)onFullText:(id)sender;
- (IBAction)onDiffText:(id)sender;

@end
