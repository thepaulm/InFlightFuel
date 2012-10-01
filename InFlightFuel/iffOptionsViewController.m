//
//  iffOptionsViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 8/28/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffOptionsViewController.h"

@interface iffOptionsViewController ()

@end

@implementation iffOptionsViewController
@synthesize textTabs;
@synthesize textFull;
@synthesize stepperTabs;
@synthesize stepperFull;

@synthesize valueTabs;
@synthesize valueFull;

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = NULL;
    }
    return self;
}

- (void)updateTextTabs
{
    textTabs.text = [self.valueTabs toString];
}

- (void)updateTextFull
{
    textFull.text = [self.valueFull toString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTextTabs];
    [self updateTextFull];
    stepperTabs.value = [self.valueTabs toFloat];
    stepperFull.value = [self.valueFull toFloat];
}

- (void)initializeValues:(FuelValue*)vt valueFull:(FuelValue*)vf
{
    self.valueTabs = vt;
    self.valueFull = vf;
}

- (IBAction)clickDone:(id)sender {
    [self.delegate iffOptionsViewControllerDidFinish:self];
}

- (void)viewDidUnload
{
    [self setTextTabs:nil];
    [self setTextFull:nil];
    [self setStepperTabs:nil];
    [self setStepperFull:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)onStepperTabs:(id)sender {
    self.valueTabs = [[FuelValue alloc]initFromFloat:((UIStepper*)sender).value];
    [self updateTextTabs];
}

- (IBAction)onStepperFull:(id)sender {
    self.valueFull = [[FuelValue alloc]initFromFloat:((UIStepper*)sender).value];
    [self updateTextFull];
}

- (IBAction)onTabsText:(id)sender {
    self.valueTabs = [[FuelValue alloc]initFromFloat:[((UITextField*)sender).text floatValue]];
    stepperTabs.value = [self.valueTabs toFloat];
}

- (IBAction)onFullText:(id)sender {
    self.valueFull = [[FuelValue alloc]initFromFloat:[((UITextField*)sender).text floatValue]];
    stepperFull.value = [self.valueFull toFloat];
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    if (sender == self.textFull || sender == self.textTabs) {
        [sender resignFirstResponder];
    }
    return TRUE;
}
@end
