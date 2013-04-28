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
@property (copy, nonatomic) NSValue* valueInitialTimer;
@property (copy, nonatomic) NSValue* valueSubsequentTimer;

@property (weak, nonatomic) id <iffOptionsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textTabs;
@property (weak, nonatomic) IBOutlet UITextField *textFull;
@property (weak, nonatomic) IBOutlet UITextField *textDiff;
@property (weak, nonatomic) IBOutlet UIStepper *stepperTabs;
@property (weak, nonatomic) IBOutlet UIStepper *stepperFull;
@property (weak, nonatomic) IBOutlet UIStepper *stepperDiff;

- (void)initializeValues:(FuelValue*)vt valueFull:(FuelValue*)vf valueDiff:(FuelValue*)vd
       valueInitialTimer:(NSValue*)vit valueSubsequenTimer:(NSValue*)vst;

- (IBAction)clickDone:(id)sender;
- (IBAction)onStepperTabs:(id)sender;
- (IBAction)onStepperFull:(id)sender;
- (IBAction)onStepperDiff:(id)sender;
- (IBAction)onTabsText:(id)sender;
- (IBAction)onFullText:(id)sender;
- (IBAction)onDiffText:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *timersText;
@property (weak, nonatomic) IBOutlet UITextField *textInitialTimer;
@property (weak, nonatomic) IBOutlet UITextField *textSubsequentTimer;
@property (weak, nonatomic) IBOutlet UIStepper *stepperInitialTimer;
@property (weak, nonatomic) IBOutlet UIStepper *stepperSubsequentTimer;
- (IBAction)onStepperInitialTimer:(id)sender;
- (IBAction)onStepperSubsequentTimer:(id)sender;
- (IBAction)onInitialTimerText:(id)sender;
- (IBAction)onSubsequentTimerText:(id)sender;

@end
