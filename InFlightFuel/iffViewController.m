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
@synthesize tabsValue;
@synthesize fullValue;

- (void)updateTankDiffs
{
    leftTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals", leftTankFuel - rightTankFuel];
    rightTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals", rightTankFuel - leftTankFuel];
}

- (void)setValuesDefaults
{
    tabsValue.text = [self getValueString:self->valueTabs];
    fullValue.text = [self getValueString:self->valueFull];    
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
    [self setValuesDefaults];
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
    
    self->leftTankFuel = 30;
    self->rightTankFuel = 30;
    self->ison = FALSE;
    self->startedFuel = 0;
    self->valueTabs = 60;
    self->valueFull = 92;

    NSMutableArray *mutableFetchResults = [self loadLastTankValues];
    if (mutableFetchResults != nil) {
        for (FuelTank *ftv in mutableFetchResults) {
            if ([ftv.tankNo intValue] == 0) {
                self->leftTankFuel = [ftv.level floatValue];
            } else if ([ftv.tankNo intValue] == 1) {
                self->rightTankFuel = [ftv.level floatValue];
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
    [self setTabsValue:nil];
    [self setFullValue:nil];
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
    if (self->ison) {
        sliderLeftTank.value = self->leftTankFuel;
        return;
    }
    self->leftTankFuel = [self getTankValue:(UISlider*)sender];
    textLeftTank.text = [self getTankString:(UISlider*)sender];
    textBothTanks.text = [self getValueString:self->leftTankFuel + self->rightTankFuel];
    sliderBothTanks.value = self->leftTankFuel + self->rightTankFuel;
    stepperBothTanks.value = self->leftTankFuel + self->rightTankFuel;
    stepperLeftTank.value = self->leftTankFuel;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderRightTank:(id)sender
{
    if (self->ison) {
        sliderRightTank.value = self->rightTankFuel;
        return;
    }
    self->rightTankFuel = [self getTankValue:(UISlider *)sender];
    textRightTank.text = [self getTankString:(UISlider*)sender];
    textBothTanks.text = [self getValueString:self->leftTankFuel + self->rightTankFuel];
    sliderBothTanks.value = self->leftTankFuel + self->rightTankFuel;
    stepperBothTanks.value = self->leftTankFuel + self->rightTankFuel;
    stepperRightTank.value = self->rightTankFuel;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderBothTanks:(id)sender
{
    float v = [self getTankValue:(UISlider *)sender];
    float oldv = self->leftTankFuel + self->rightTankFuel;
    float diff = oldv - v;
    if (leftRightTank.selectedSegmentIndex == 0) {
        // underflow
        if (self->leftTankFuel < diff) {
            self->leftTankFuel = 0.0;
            sliderBothTanks.value = v = self->leftTankFuel + self->rightTankFuel;
        // overflow
        } else if (self->leftTankFuel - diff > 46.0) {
            self->leftTankFuel = 46.0;
            sliderBothTanks.value = v = self->leftTankFuel + self->rightTankFuel;
        } else {
            self->leftTankFuel -= diff;
        }
        textLeftTank.text = [self getValueString:leftTankFuel];
        sliderLeftTank.value = self->leftTankFuel;
        stepperLeftTank.value = self->leftTankFuel;
    } else {
        // underflow
        if (self->rightTankFuel < diff) {
            self->rightTankFuel = 0.0;
            sliderBothTanks.value = v = self->leftTankFuel + self->rightTankFuel;
        // overflow
        } else if (self->rightTankFuel - diff > 46.0) {
            self->rightTankFuel = 46.0;
            sliderBothTanks.value = v = self->leftTankFuel + self->rightTankFuel;
        } else {
            self->rightTankFuel -= diff;
        }
        textRightTank.text = [self getValueString:rightTankFuel];
        sliderRightTank.value = self->rightTankFuel;
        stepperRightTank.value = self->rightTankFuel;
    }
    textBothTanks.text = [self getValueString:self->leftTankFuel + self->rightTankFuel];
    textUsedFuel.text = [self getValueString:self->startedFuel - (self->leftTankFuel + self->rightTankFuel)];
    stepperBothTanks.value = v;
    [self updateTankDiffs];
    [self saveLastTankValues];
}
- (IBAction)switchOn:(id)sender {
    if (self->ison) {
        self->ison = FALSE;
    } else {
        self->ison = TRUE;
        self->startedFuel = self->leftTankFuel + self->rightTankFuel;
        textUsedFuel.text = [self getValueString:0];
    }
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
}
- (IBAction)stepperLeftTank:(id)sender {
    if (self->ison) {
        stepperLeftTank.value = self->leftTankFuel;
        return;
    }
    sliderLeftTank.value = ((UIStepper*)sender).value;
    [self sliderLeftTank:sliderLeftTank];
}
- (IBAction)stepperRightTank:(id)sender {
    if (self->ison) {
        stepperRightTank.value = self->rightTankFuel;
        return;
    }
    sliderRightTank.value = ((UIStepper*)sender).value;
    [self sliderRightTank:sliderRightTank];
}
- (IBAction)fuelTabs:(id)sender {
    if (self->ison)
        return;
    sliderLeftTank.value = 30;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = 30;
    [self sliderRightTank:(id)sliderRightTank];
}

- (IBAction)fuelFull:(id)sender {
    if (self->ison)
        return;
    sliderLeftTank.value = 46;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = 46;
    [self sliderRightTank:(id)sliderRightTank];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowIffOptions"]) {
        iffOptionsViewController* pOther = [segue destinationViewController];
        [pOther setDelegate:self];
        [pOther initializeValues:self->valueTabs valueFull:self->valueFull];
    }
}

- (void)iffOptionsViewControllerDidFinish:(iffOptionsViewController *)controller
{
    self->valueTabs = controller->valueTabs;
    self->valueFull = controller->valueFull;
    [self setValuesDefaults];
    [controller dismissModalViewControllerAnimated:TRUE];
}
@end
