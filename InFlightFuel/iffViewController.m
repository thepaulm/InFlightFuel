//
//  iffViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffViewController.h"
#import "FuelTank.h"

@interface iffViewController ()

@end

@implementation iffViewController
@synthesize stepperRightTank;
@synthesize leftTankDiff;
@synthesize rightTankDiff;
@synthesize stepperLeftTank;
@synthesize stepperBothTanks;
@synthesize textUsedFuel;

@synthesize textRightTank;
@synthesize sliderRightTank;

@synthesize textLeftTank;
@synthesize sliderLeftTank;

@synthesize textBothTanks;

@synthesize sliderBothTanks;
@synthesize leftRightTank;

@synthesize managedObjectContext;


float leftTankFuel = 30;
float rightTankFuel = 30;
BOOL ison = FALSE;
float startedFuel = 0;

- (void)updateTankDiffs
{
    leftTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals", leftTankFuel - rightTankFuel];
    rightTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals", rightTankFuel - leftTankFuel];
}

- (void)setTankDefaults
{
    // Defaults for non-loaded
    sliderLeftTank.value = leftTankFuel;
    sliderRightTank.value = rightTankFuel;
    textLeftTank.text = [self getTankString:sliderLeftTank];
    textRightTank.text = [self getTankString:sliderRightTank];
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    sliderBothTanks.value = leftTankFuel + rightTankFuel;
    stepperBothTanks.value = leftTankFuel + rightTankFuel;
    stepperLeftTank.value = leftTankFuel;
    stepperRightTank.value = rightTankFuel;
}

- (NSMutableArray*)loadLastTankValues
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FuelTank" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tankNo" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error != nil)
        mutableFetchResults = nil;
    if ([mutableFetchResults count] == 0)
        mutableFetchResults = nil;
    return mutableFetchResults;
}

- (void)saveLastTankValues
{
    
    FuelTank *ftl = (FuelTank*)[NSEntityDescription insertNewObjectForEntityForName:@"FuelTank" inManagedObjectContext:managedObjectContext];
    FuelTank *ftr = (FuelTank*)[NSEntityDescription insertNewObjectForEntityForName:@"FuelTank" inManagedObjectContext:managedObjectContext];
    
    [ftl setTankNo:[NSNumber numberWithInt:0]];
    [ftl setLevel: [NSNumber numberWithFloat:leftTankFuel]];
    [ftr setTankNo:[NSNumber numberWithInt:1]];
    [ftr setLevel: [NSNumber numberWithFloat:rightTankFuel]];
    
    NSError *error = nil;
    [managedObjectContext save:&error];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *mutableFetchResults = [self loadLastTankValues];
    if (mutableFetchResults != nil) {
        for (FuelTank *ftv in mutableFetchResults) {
            if ([ftv.tankNo intValue] == 0) {
                leftTankFuel = [ftv.level floatValue];
            } else if ([ftv.tankNo intValue] == 1) {
                rightTankFuel = [ftv.level floatValue];
            }
        }
    }
    [self setTankDefaults];    
    [self updateTankDiffs];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTextLeftTank:nil];
    [self setTextRightTank:nil];
    [self setSliderLeftTank:nil];
    [self setSliderRightTank:nil];
    [self setTextBothTanks:nil];
    [self setLeftRightTank:nil];
    [self setSliderBothTanks:nil];
    [self setTextUsedFuel:nil];
    [self setStepperBothTanks:nil];
    [self setStepperLeftTank:nil];
    [self setStepperRightTank:nil];
    [self setLeftTankDiff:nil];
    [self setRightTankDiff:nil];
    // XXXPAM how do we free up the managedObjectContext?
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (NSString*)getValueString:(float) v
{
    return [[NSString alloc]initWithFormat:@"%.1f", v];
}

- (float)getTankValue:(UISlider *)s
{
    return s.value;
}

- (NSString*)getTankString:(UISlider *)s
{
    return [self getValueString:[self getTankValue:s]];
}

- (IBAction)sliderLeftTank:(id)sender
{
    if (ison) {
        sliderLeftTank.value = leftTankFuel;
        return;
    }
    leftTankFuel = [self getTankValue:(UISlider*)sender];
    textLeftTank.text = [self getTankString:(UISlider*)sender];
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    sliderBothTanks.value = leftTankFuel + rightTankFuel;
    stepperBothTanks.value = leftTankFuel + rightTankFuel;
    stepperLeftTank.value = leftTankFuel;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderRightTank:(id)sender
{
    if (ison) {
        sliderRightTank.value = rightTankFuel;
        return;
    }
    rightTankFuel = [self getTankValue:(UISlider *)sender];
    textRightTank.text = [self getTankString:(UISlider*)sender];
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    sliderBothTanks.value = leftTankFuel + rightTankFuel;
    stepperBothTanks.value = leftTankFuel + rightTankFuel;
    stepperRightTank.value = rightTankFuel;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderBothTanks:(id)sender
{
    float v = [self getTankValue:(UISlider *)sender];
    float oldv = leftTankFuel + rightTankFuel;
    float diff = oldv - v;
    if (leftRightTank.selectedSegmentIndex == 0) {
        // underflow
        if (leftTankFuel < diff) {
            leftTankFuel = 0.0;
            sliderBothTanks.value = v = leftTankFuel + rightTankFuel;
        // overflow
        } else if (leftTankFuel - diff > 46.0) {
            leftTankFuel = 46.0;
            sliderBothTanks.value = v = leftTankFuel + rightTankFuel;
        } else {
            leftTankFuel -= diff;
        }
        textLeftTank.text = [self getValueString:leftTankFuel];
        sliderLeftTank.value = leftTankFuel;
        stepperLeftTank.value = leftTankFuel;
    } else {
        // underflow
        if (rightTankFuel < diff) {
            rightTankFuel = 0.0;
            sliderBothTanks.value = v = leftTankFuel + rightTankFuel;
        // overflow
        } else if (rightTankFuel - diff > 46.0) {
            rightTankFuel = 46.0;
            sliderBothTanks.value = v = leftTankFuel + rightTankFuel;
        } else {
            rightTankFuel -= diff;
        }
        textRightTank.text = [self getValueString:rightTankFuel];
        sliderRightTank.value = rightTankFuel;
        stepperRightTank.value = rightTankFuel;
    }
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    textUsedFuel.text = [self getValueString:startedFuel - (leftTankFuel + rightTankFuel)];
    stepperBothTanks.value = v;
    [self updateTankDiffs];
    [self saveLastTankValues];
}
- (IBAction)switchOn:(id)sender {
    if (ison) {
        ison = FALSE;
    } else {
        ison = TRUE;
        startedFuel = leftTankFuel + rightTankFuel;
        textUsedFuel.text = [self getValueString:0];
    }
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
}
- (IBAction)stepperLeftTank:(id)sender {
    if (ison) {
        stepperLeftTank.value = leftTankFuel;
        return;
    }
    sliderLeftTank.value = ((UIStepper*)sender).value;
    [self sliderLeftTank:sliderLeftTank];
}
- (IBAction)stepperRightTank:(id)sender {
    if (ison) {
        stepperRightTank.value = rightTankFuel;
        return;
    }
    sliderRightTank.value = ((UIStepper*)sender).value;
    [self sliderRightTank:sliderRightTank];
}
- (IBAction)fuelTabs:(id)sender {
    if (ison)
        return;
    sliderLeftTank.value = 30;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = 30;
    [self sliderRightTank:(id)sliderRightTank];
}

- (IBAction)fuelFull:(id)sender {
    if (ison)
        return;
    sliderLeftTank.value = 46;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = 46;
    [self sliderRightTank:(id)sliderRightTank];
}
@end
