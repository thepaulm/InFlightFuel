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
    self->leftTankLevel = self->rightTankLevel = 0;
    return self;
}

#define LEFT_TANK_LEVEL @"LeftTankLevel"
#define RIGHT_TANK_LEVEL @"RightTankLevel"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    @try {
        self->leftTankLevel = [aDecoder decodeIntForKey:LEFT_TANK_LEVEL];
        self->rightTankLevel = [aDecoder decodeIntForKey:RIGHT_TANK_LEVEL];
    }
    @catch (NSException *e) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self->leftTankLevel forKey:LEFT_TANK_LEVEL];
    [aCoder encodeInt:self->rightTankLevel forKey:RIGHT_TANK_LEVEL];
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
@synthesize fuelRuler;
@synthesize leftRightTank;

@synthesize tabsValue;
@synthesize fullValue;
@synthesize buttonTabs;
@synthesize buttonFull;

@synthesize startedFuel;
@synthesize valueTabs;
@synthesize valueFull;
@synthesize maxEachTank;
@synthesize targetDiff;

- (void)updateTankDiffs
{
    [self.leftFuelTank setDiff:[self.leftFuelTank.level minus:self.rightFuelTank.level]];
    [self.rightFuelTank setDiff:[self.rightFuelTank.level minus:self.leftFuelTank.level]];
}

- (void)setValuesDefaults
{
    tabsValue.text = [self->valueTabs toString];
    fullValue.text = [self->valueFull toString];
    self->maxEachTank = [self->valueFull slashInt:2];

    sliderBothTanks.maximumValue = [self->valueFull toFloat];

    /* FuelTank will store these with property type "copy" */
    [self.leftFuelTank setMax:self->maxEachTank];
    [self.rightFuelTank setMax:self->maxEachTank];
    
    [self.fuelRuler setMaxFuel:self->valueFull];
}

- (void)setTankDefaults
{
    // Defaults for non-loaded
    [self setValuesDefaults];

    FuelValue *both = [leftFuelTank.level plus:rightFuelTank.level];
    textBothTanks.text = [both toString];
    sliderBothTanks.value = [both toFloat];
    stepperBothTanks.value = [both toFloat];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->startTank = 0;
    self->switchOverPoints = [[NSMutableArray alloc]initWithCapacity:10];
    self->projectedSwitchOverPoints = [[NSMutableArray alloc]initWithCapacity:1];
    
    self->ison = FALSE;
    /* Use -> here = don't want to copy these initializers */
    self->startedFuel = [[FuelValue alloc]initFromInt:0];
    self->valueTabs = [[FuelValue alloc]initFromInt:60];
    self->valueFull = [[FuelValue alloc]initFromInt:92];
    self->maxEachTank = [self->valueFull slashInt:2];
    self->targetDiff = [[FuelValue alloc]initFromValue:85];
    
    iffSaveData *sd = [self loadSaveData];
    if (sd == nil) {				
        sd = [[iffSaveData alloc]init];
        sd->leftTankLevel = 30.0;
        sd->rightTankLevel = 30.0;
    }
    [self setLeftFuelTank:[[FuelTank alloc]initWithLabel:[[NSString alloc]initWithFormat:@"Left Tank"]]];
    [self setRightFuelTank:[[FuelTank alloc]initWithLabel:[[NSString alloc]initWithFormat:@"Right Tank"]]];
    
    [self.leftFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->leftTankLevel]];
    [self.rightFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->rightTankLevel]];

    /* The minimum movement is 0.1 gals */
    stepperBothTanks.stepValue = 0.1;
    [self setTankDefaults];

    CGRect r = CGRectMake(0.27, 0.9, 0, 0.7);
    [self.leftFuelTank drawRelativeFrame:self.view :r];
    
    r.origin.x = 0.47;
    [self.rightFuelTank drawRelativeFrame:self.view :r];
    
    [self.sliderBothTanks setTransform:CGAffineTransformRotate(self.sliderBothTanks.transform,270.0/180*M_PI)];
    
    [self setFuelRuler:[[FuelRulerView alloc]initFromSliderRect:self->sliderBothTanks]];
    [self.view addSubview:self.fuelRuler];
   
    [self updateTankDiffs];

    [self->fuelRuler setMaxFuel:self->valueFull];
    [self->fuelRuler setStartedTank:self->startTank];
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
    self->switchOverPoints = nil;
    self->projectedSwitchOverPoints = nil;

    [self setFuelRuler:nil];
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

- (IBAction)sliderBothTanks:(id)sender
{
    UISlider *s = (UISlider *)sender;
    FuelValue *v = [[FuelValue alloc]initFromFloat:s.value];
    FuelValue *oldv = [self.leftFuelTank.level plus:self.rightFuelTank.level];
    FuelValue *diff = [oldv minus:v];
    FuelTank *ft = nil;
    if (leftRightTank.selectedSegmentIndex == 0) {
        ft = self.leftFuelTank;
    } else {
        ft = self.rightFuelTank;
    }
    
    // underflow
    if ([ft.level lt:diff]) {
        [ft setLevel:[[FuelValue alloc]initFromInt:0]];
    // overflow
    } else if ([[ft.level minus:diff] gt:self.maxEachTank]) {
        [ft setLevel:[self->maxEachTank copy]];
    // normal
    } else {
        [ft setLevel:[ft.level minus:diff]];
    }

    FuelValue *both = [self.leftFuelTank.level plus:self.rightFuelTank.level];
    textUsedFuel.text = [[self.startedFuel minus:both] toString];
    [self resetSlider];
    [self updateTankDiffs];
    [self saveLastTankValues];
}

- (void)resetUsedFuel
{
    [self setStartedFuel:[self.leftFuelTank.level plus:self.rightFuelTank.level]];
    textUsedFuel.text = [[[FuelValue alloc]initFromInt:0] toString];
}

- (void)recalcProjected
{
    self->projectedSwitchOverPoints = [[NSMutableArray alloc]initWithCapacity:1];
    
    FuelTank *ft = nil;
    if (leftRightTank.selectedSegmentIndex == 0) {
        ft = self.rightFuelTank;
    } else {
        ft = self.leftFuelTank;
    }
    
    FuelValue *last = [ft.level plus:[ft.level minus:self->targetDiff]];
    [self->projectedSwitchOverPoints addObject:last];
    [self->fuelRuler setProjectedSwitchOverPoints:self->projectedSwitchOverPoints];
}

- (void)sampleSwitchOverPoint
{
    [self->switchOverPoints addObject:[self.leftFuelTank.level plus:self.rightFuelTank.level]];
}

- (IBAction)switchOn:(id)sender {
    if (self->ison) {
        self->ison = FALSE;
        self.buttonFull.enabled = TRUE;
        self.buttonTabs.enabled = TRUE;
        self->switchOverPoints = nil;
        self->projectedSwitchOverPoints = nil;
        [self->fuelRuler setSwitchOverPoints:nil];
        [self->fuelRuler setProjectedSwitchOverPoints:nil];
        [self->fuelRuler setNeedsDisplay];
    } else {
        if (leftRightTank.selectedSegmentIndex == 0) {
            self->startTank = 0;
        } else {
            self->startTank = 1;
        }
        [self->fuelRuler setStartedTank:self->startTank];
        self->ison = TRUE;
        self.buttonFull.enabled = FALSE;
        self.buttonTabs.enabled = FALSE;
        [self resetUsedFuel];
        self->switchOverPoints = [[NSMutableArray alloc]initWithCapacity:10];
        [self sampleSwitchOverPoint];
        [self->fuelRuler setSwitchOverPoints:self->switchOverPoints];
        [self recalcProjected];
        [self->fuelRuler setNeedsDisplay];
    }
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
}

- (void)resetSlider
{
    FuelValue *both = [self.leftFuelTank.level plus:self.rightFuelTank.level];
    self.sliderBothTanks.value = [both toFloat];
    self.stepperBothTanks.value = [both toFloat];
    self.textBothTanks.text = [both toString];
}

- (IBAction)fuelTabs:(id)sender {
    if (self->ison)
        return;
    [self.leftFuelTank setLevel:[self.valueTabs slashInt:2]];
    [self.rightFuelTank setLevel:[self.valueTabs slashInt:2]];
    [self resetSlider];
    [self updateTankDiffs];
    [self saveLastTankValues];
    [self resetUsedFuel];
}

- (IBAction)fuelFull:(id)sender {
    if (self->ison)
        return;
    [self.leftFuelTank setLevel:[self.valueFull slashInt:2]];
    [self.rightFuelTank setLevel:[self.valueFull slashInt:2]];
    [self resetSlider];
    [self updateTankDiffs];
    [self saveLastTankValues];
    [self resetUsedFuel];
}

- (IBAction)switchedTank:(id)sender {
    if (!self->ison)
        return;
    
    [self sampleSwitchOverPoint];
    int count = [self->switchOverPoints count];
    /* If we just switched back and forth without changing anything, just
       remove the last two samples, since we didn't actually switch */
    if (count > 1) {
        FuelValue *l1 = [self->switchOverPoints objectAtIndex:count - 1];
        FuelValue *l2 = [self->switchOverPoints objectAtIndex:count - 2];
        if ([l1 eq:l2]) {
            [self->switchOverPoints removeLastObject];
            [self->switchOverPoints removeLastObject];
        }
        /* However, if we've now nuked all of the data points, we need
           to switch started and resample */
        if ([self->switchOverPoints count] == 0) {
            if (self->startTank == 0) {
                self->startTank = 1;
            } else {
                self->startTank = 0;
            }
            [self->fuelRuler setStartedTank:self->startTank];
            [self sampleSwitchOverPoint];
        }
    }
    [self->fuelRuler setSwitchOverPoints:self->switchOverPoints];
    [self recalcProjected];
    [self->fuelRuler setNeedsDisplay];
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
    
    sd->leftTankLevel = [self.leftFuelTank.level toValue];
    sd->rightTankLevel = [self.rightFuelTank.level toValue];
    
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
        /* The pOther stores these as type "copy" */
        [pOther initializeValues:self.valueTabs valueFull:self.valueFull];
    }
}

- (void)iffOptionsViewControllerDidFinish:(iffOptionsViewController *)controller
{
    /* These are of property type "copy" */
    [self setValueTabs: controller.valueTabs];
    [self setValueFull: controller.valueFull];
    [self setValuesDefaults];
    [controller dismissModalViewControllerAnimated:TRUE];
}

@end
