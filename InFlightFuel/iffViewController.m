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
@synthesize stepperBothTanks;
@synthesize textUsedFuel;

@synthesize textBothTanks;

@synthesize sliderBothTanks;
@synthesize leftRightTank;

@synthesize tabsValue;
@synthesize fullValue;
@synthesize buttonTabs;
@synthesize buttonFull;

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
    [self.leftFuelTank setDiff:[self getLeftTankValue] - [self getRightTankValue]];
    [self.rightFuelTank setDiff:[self getRightTankValue] - [self getLeftTankValue]];
}

- (void)setValuesDefaults
{
    tabsValue.text = [self getValueString:self->valueTabs];
    fullValue.text = [self getValueString:self->valueFull];
    self->maxEachTank = self->valueFull / 2;

    sliderBothTanks.maximumValue = self->valueFull;
    
    [self.leftFuelTank setMax:self->maxEachTank];
    [self.rightFuelTank setMax:self->maxEachTank];
}

- (void)setTankDefaults
{
    // Defaults for non-loaded
    [self setValuesDefaults];
    
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
    [self setLeftFuelTank:[[FuelTank alloc]initWithLabel:[[NSString alloc]initWithFormat:@"Left Tank"]]];
    [self setRightFuelTank:[[FuelTank alloc]initWithLabel:[[NSString alloc]initWithFormat:@"Right Tank"]]];
    
    [self.leftFuelTank setLevel:sd->leftTankLevel];
    [self.rightFuelTank setLevel:sd->rightTankLevel];

    [self setTankDefaults];

    CGRect r = CGRectMake(0.27, 0.9, 0, 0.7);
    [self.leftFuelTank drawRelativeFrame:self.view :r];
    
    r.origin.x = 0.47;
    [self.rightFuelTank drawRelativeFrame:self.view :r];
    
    [self.sliderBothTanks setTransform:CGAffineTransformRotate(self.sliderBothTanks.transform,270.0/180*M_PI)];
   
    [self updateTankDiffs];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLeftFuelTank:nil];
    [self setRightFuelTank:nil];
    [self setTextBothTanks:nil];
    [self setSliderBothTanks:nil];
    [self setLeftRightTank:nil];
    [self setTextUsedFuel:nil];
    [self setStepperBothTanks:nil];
    [self setTabsValue:nil];
    [self setFullValue:nil];
    [self setButtonTabs:nil];
    [self setButtonFull:nil];

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

- (IBAction)sliderBothTanks:(id)sender
{
    float v = [self getTankValue:(UISlider *)sender];
    float oldv = [self getLeftTankValue] + [self getRightTankValue];
    float diff = oldv - v;
    FuelTank *ft = nil;
    if (leftRightTank.selectedSegmentIndex == 0) {
        ft = self.leftFuelTank;
    } else {
        ft = self.rightFuelTank;
    }
    
    // underflow
    if (ft->level < diff) {
        [ft setLevel:0.0];
    // overflow
    } else if (ft->level - diff > self->maxEachTank) {
        [ft setLevel:self->maxEachTank];
    // normal
    } else {
        [ft setLevel:ft->level - diff];
    }

    float both = [self getLeftTankValue] + [self getRightTankValue];
    textUsedFuel.text = [self getValueString:self->startedFuel - (both)];
    [self resetSlider];
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (IBAction)switchOn:(id)sender {
    if (self->ison) {
        self->ison = FALSE;
        self.buttonFull.enabled = TRUE;
        self.buttonTabs.enabled = TRUE;
    } else {
        self->ison = TRUE;
        self.buttonFull.enabled = FALSE;
        self.buttonTabs.enabled = FALSE;
        self->startedFuel = [self getLeftTankValue] + [self getRightTankValue];
        textUsedFuel.text = [self getValueString:0];
    }
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
}

- (void)resetSlider
{
    float both = [self getLeftTankValue] + [self getRightTankValue];
    self.sliderBothTanks.value = both;
    self.stepperBothTanks.value = both;
    self.textBothTanks.text = [self getValueString:both];
}

- (IBAction)fuelTabs:(id)sender {
    if (self->ison)
        return;
    [self.leftFuelTank setLevel:self->valueTabs / 2];
    [self.rightFuelTank setLevel:self->valueTabs / 2];
    [self resetSlider];
    [self saveLastTankValues];
}

- (IBAction)fuelFull:(id)sender {
    if (self->ison)
        return;
    [self.leftFuelTank setLevel:self->valueFull / 2];
    [self.rightFuelTank setLevel:self->valueFull / 2];
    [self resetSlider];
    [self saveLastTankValues];
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
