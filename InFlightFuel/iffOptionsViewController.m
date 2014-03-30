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
@synthesize timersText;
@synthesize textInitialTimer;
@synthesize textSubsequentTimer;
@synthesize stepperInitialTimer;
@synthesize stepperSubsequentTimer;
@synthesize textTabs;
@synthesize textFull;
@synthesize textDiff;
@synthesize stepperTabs;
@synthesize stepperFull;
@synthesize stepperDiff;

@synthesize valueTabs;
@synthesize valueFull;
@synthesize valueDiff;
@synthesize valueInitialTimer;
@synthesize valueSubsequentTimer;

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

- (void)updateTextDiff
{
    textDiff.text = [self.valueDiff toString];
}

- (void)updateTextIT
{
    self.textInitialTimer.text = [[NSString alloc]initWithFormat:@"%d", (int)[self initialTimerInt]];
}

- (void)updateTextST
{
    self.textSubsequentTimer.text = [[NSString alloc]initWithFormat:@"%d", (int)[self subsequentTimerInt]];
}

- (NSInteger)initialTimerInt
{
    NSInteger i;
    [self.valueInitialTimer getValue:&i];
    return i;
}

- (NSInteger)subsequentTimerInt
{
    NSInteger i;
    [self.valueSubsequentTimer getValue:&i];
    return i;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTextTabs];
    [self updateTextFull];
    [self updateTextDiff];
    [self updateTextIT];
    [self updateTextST];
    stepperTabs.value = [self.valueTabs toFloat];
    stepperFull.value = [self.valueFull toFloat];
    stepperDiff.value = [self.valueDiff toFloat];
    
    stepperInitialTimer.value = [self initialTimerInt];
    stepperSubsequentTimer.value = [self subsequentTimerInt];
    
    [self.timersText setNumberOfLines:0];
    [self.timersText setText:
@"Set the timer minutes values for initial and subsequent timers.\n\n"
"Some pilots like to have an initial timer value different from "
"those for the rest of the flight (for example: 30m, 1hr, 1hr, 1hr ...). "
"You may however set intial timer to 0 and only the subsequent timer will be active. "
"The active timer will auto-reset on fuel tank switch. Leaving these values at 0 "
"will disable the timers."];

}

- (void)initializeValues:(FuelValue*)vt valueFull:(FuelValue*)vf valueDiff:(FuelValue*)vd
       valueInitialTimer:(NSValue *)vit valueSubsequenTimer:(NSValue *)vst
{
    /* These have property value "copy" */
    [self setValueTabs: vt];
    [self setValueFull: vf];
    [self setValueDiff: vd];
    
    NSInteger zero = 0;
    if (vit == nil)
        vit = [NSValue valueWithBytes:&zero objCType:@encode(NSInteger)];
    [self setValueInitialTimer:vit];
    if (vst == nil)
        vst = [NSValue valueWithBytes:&zero objCType:@encode(NSInteger)];
    [self setValueSubsequentTimer:vst];
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
    [self setTextDiff:nil];
    [self setStepperDiff:nil];
    [self setTimersText:nil];
    [self setTextInitialTimer:nil];
    [self setTextSubsequentTimer:nil];
    [self setStepperInitialTimer:nil];
    [self setStepperSubsequentTimer:nil];
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

- (IBAction)onStepperDiff:(id)sender {
    self.valueDiff = [[FuelValue alloc]initFromFloat:((UIStepper*)sender).value];
    [self updateTextDiff];
}

- (IBAction)onTabsText:(id)sender {
    self.valueTabs = [[FuelValue alloc]initFromFloat:[((UITextField*)sender).text floatValue]];
    stepperTabs.value = [self.valueTabs toFloat];
    [self updateTextTabs];
}

- (IBAction)onFullText:(id)sender {
    self.valueFull = [[FuelValue alloc]initFromFloat:[((UITextField*)sender).text floatValue]];
    stepperFull.value = [self.valueFull toFloat];
    [self updateTextFull];
}

- (IBAction)onDiffText:(id)sender {
    self.valueDiff = [[FuelValue alloc]initFromFloat:[((UITextField*)sender).text floatValue]];
    stepperDiff.value = [self.valueDiff toFloat];
    [self updateTextDiff];
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    if (sender == self.textFull || sender == self.textTabs || sender == self.textDiff ||
        sender == self.textInitialTimer || sender == self.textSubsequentTimer) {
        [sender resignFirstResponder];
    }
    return TRUE;
}
- (IBAction)onStepperInitialTimer:(id)sender {
    NSInteger i = self.stepperInitialTimer.value;
    self.valueInitialTimer = [NSValue valueWithBytes:&i objCType:@encode(NSInteger)];
    [self updateTextIT];
}

- (IBAction)onStepperSubsequentTimer:(id)sender {
    NSInteger i = self.stepperSubsequentTimer.value;
    self.valueSubsequentTimer = [NSValue valueWithBytes:&i objCType:@encode(NSInteger)];
    [self updateTextST];
}

- (IBAction)onInitialTimerText:(id)sender {
    NSInteger i = [((UITextField *)sender).text integerValue];
    self.valueInitialTimer = [NSValue valueWithBytes:&i objCType:@encode(NSInteger)];
    [self.stepperInitialTimer setValue:i];
    [self updateTextIT];
}

- (IBAction)onSubsequentTimerText:(id)sender {
    NSInteger i = [((UITextField *)sender).text integerValue];
    self.valueSubsequentTimer = [NSValue valueWithBytes:&i objCType:@encode(NSInteger)];
    [self.stepperSubsequentTimer setValue:i];
    [self updateTextST];
}
@end
