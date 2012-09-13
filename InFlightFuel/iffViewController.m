    //
//  iffViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffViewController.h"
#import "FuelTank.h"

#pragma mark -
#pragma mark IffSaveData

@implementation iffSaveData

- (id)init
{
    self = [super init];
    self->leftTankLevel = self->rightTankLevel = 0.0;
    return self;
}

#define LEFT_TANK_LEVEL @"LeftTankLevel"
#define RIGHT_TANK_LEVEL @"RightTankLevel"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    self->leftTankLevel = [aDecoder decodeFloatForKey:LEFT_TANK_LEVEL];
    self->rightTankLevel = [aDecoder decodeFloatForKey:RIGHT_TANK_LEVEL];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:self->leftTankLevel forKey:LEFT_TANK_LEVEL];
    [aCoder encodeFloat:self->rightTankLevel forKey:RIGHT_TANK_LEVEL];
}
@end


#pragma mark -
#pragma mark iffViewController

@implementation iffViewController

@synthesize leftFuelTank;
@synthesize rightFuelTank;

@synthesize leftTankDiff;
@synthesize rightTankDiff;
@synthesize stepperBothTanks;
@synthesize textUsedFuel;

@synthesize textRightTank;
@synthesize sliderRightTank;

@synthesize textLeftTank;
@synthesize sliderLeftTank;

@synthesize textBothTanks;

@synthesize sliderBothTanks;
@synthesize leftRightTank;

@synthesize tabsValue;
@synthesize fullValue;

- (float)getLeftTankValue
{
    return self.leftFuelTank->level;
}

- (float)getRightTankValue
{
    return self.rightFuelTank->level;
}

- (void)updateTankDiffs
{
    leftTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals",
                         [self getLeftTankValue] - [self getRightTankValue]];
    rightTankDiff.text = [[NSString alloc]initWithFormat:@"%.1f gals",
                          [self getRightTankValue] - [self getLeftTankValue]];
}

- (void)setValuesDefaults
{
    tabsValue.text = [self getValueString:self->valueTabs];
    fullValue.text = [self getValueString:self->valueFull];
    self->maxEachTank = self->valueFull / 2;
    sliderLeftTank.maximumValue = self->maxEachTank;
    sliderRightTank.maximumValue = self->maxEachTank;
    sliderBothTanks.maximumValue = self->valueFull;
}

- (void)setTankDefaults
{
    // Defaults for non-loaded
    [self setValuesDefaults];
    sliderLeftTank.value = [self getLeftTankValue];
    sliderRightTank.value = [self getRightTankValue];
    textLeftTank.text = [self getTankString:sliderLeftTank];
    textRightTank.text = [self getTankString:sliderRightTank];
    
    float both = [self getLeftTankValue] + [self getRightTankValue];
    textBothTanks.text = [self getValueString:both];
    sliderBothTanks.value = both;
    stepperBothTanks.value = both;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->ison = FALSE;
    self->startedFuel = 0;
    self->valueTabs = 60;
    self->valueFull = 92;
    self->maxEachTank = self->valueFull / 2;
    
    iffSaveData *sd = [self loadSaveData];
    if (sd == nil) {				
        sd = [[iffSaveData alloc]init];
        sd->leftTankLevel = 30.0;
        sd->rightTankLevel = 30.0;
    }
    
    [self setLeftFuelTank:[[FuelTank alloc]initWithLevel:sd->leftTankLevel]];
    [self setRightFuelTank:[[FuelTank alloc]initWithLevel:sd->rightTankLevel]];
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
    [self setLeftTankDiff:nil];
    [self setRightTankDiff:nil];
    [self setTabsValue:nil];
    [self setFullValue:nil];
    [self setLeftFuelTank:nil];
    [self setRightFuelTank:nil];
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
        sliderLeftTank.value = self.leftFuelTank->level;
        return;
    }
    self.leftFuelTank->level = [self getTankValue:(UISlider*)sender];
    textLeftTank.text = [self getTankString:(UISlider*)sender];
    
    float both = [self getLeftTankValue] + [self getRightTankValue];
    textBothTanks.text = [self getValueString:both];
    sliderBothTanks.value = both;
    stepperBothTanks.value = both;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderRightTank:(id)sender
{
    if (self->ison) {
        sliderRightTank.value = self.rightFuelTank->level;
        return;
    }
    self.rightFuelTank->level = [self getTankValue:(UISlider *)sender];
    textRightTank.text = [self getTankString:(UISlider*)sender];
    
    float both = [self getLeftTankValue] + [self getRightTankValue];
    textBothTanks.text = [self getValueString:both];
    sliderBothTanks.value = both;
    stepperBothTanks.value = both;
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)sliderBothTanks:(id)sender
{
    float v = [self getTankValue:(UISlider *)sender];
    float oldv = [self getLeftTankValue] + [self getRightTankValue];
    float diff = oldv - v;
    if (leftRightTank.selectedSegmentIndex == 0) {
        // underflow
        if (self.leftFuelTank->level < diff) {
            self.leftFuelTank->level = 0.0;
            sliderBothTanks.value = v = [self getLeftTankValue] + [self getRightTankValue];
        // overflow
        } else if (self.leftFuelTank->level - diff > self->maxEachTank) {
            self.leftFuelTank->level = self->maxEachTank;
            sliderBothTanks.value = v = [self getLeftTankValue] + [self getRightTankValue];
        } else {
            self.leftFuelTank->level -= diff;
        }
        textLeftTank.text = [self getValueString:[self getLeftTankValue]];
        sliderLeftTank.value = [self getLeftTankValue];
    } else {
        // underflow
        if (self.rightFuelTank->level < diff) {
            self.rightFuelTank->level = 0.0;
            sliderBothTanks.value = v = [self getLeftTankValue] + [self getRightTankValue];
        // overflow
        } else if (self.rightFuelTank->level - diff > self->maxEachTank) {
            self.rightFuelTank->level = self->maxEachTank;
            sliderBothTanks.value = v = [self getLeftTankValue] + [self getRightTankValue];
        } else {
            self.rightFuelTank->level -= diff;
        }
        textRightTank.text = [self getValueString:[self getRightTankValue]];
        sliderRightTank.value = [self getRightTankValue];
    }
    float both = [self getLeftTankValue] + [self getRightTankValue];
    textBothTanks.text = [self getValueString:both];
    textUsedFuel.text = [self getValueString:self->startedFuel - (both)];
    stepperBothTanks.value = v;
    [self updateTankDiffs];
    [self saveLastTankValues];
}
- (IBAction)switchOn:(id)sender {
    if (self->ison) {
        self->ison = FALSE;
    } else {
        self->ison = TRUE;
        self->startedFuel = [self getLeftTankValue] + [self getRightTankValue];
        textUsedFuel.text = [self getValueString:0];
    }
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
}
- (IBAction)fuelTabs:(id)sender {
    if (self->ison)
        return;
    sliderLeftTank.value = self->valueTabs / 2;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = self->valueTabs / 2;
    [self sliderRightTank:(id)sliderRightTank];
}

- (IBAction)fuelFull:(id)sender {
    if (self->ison)
        return;
    sliderLeftTank.value = self->valueFull / 2;
    [self sliderLeftTank:(id)sliderLeftTank];
    sliderRightTank.value = self->valueFull / 2;
    [self sliderRightTank:(id)sliderRightTank];
}

#pragma mark -
#pragma mark Saving and Loading

#define ARCHIVE_FILE @"IffData"

- (NSString *)pathForDataFile
{
    NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    
    if (documentDir)
        path = [documentDir objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/%@", path, ARCHIVE_FILE];
}

- (void)saveLastTankValues
{
    iffSaveData *sd = [[iffSaveData alloc]init];
    
    sd->leftTankLevel = [self leftFuelTank]->level;
    sd->rightTankLevel = [self rightFuelTank]->level;
    
    NSString *archivePath = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject:sd toFile:archivePath];
}

- (iffSaveData*)loadSaveData
{
    NSString *archivePath = [self pathForDataFile];
    iffSaveData *sd = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    return sd;
}

#pragma mark -
#pragma mark SettingOptions

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
