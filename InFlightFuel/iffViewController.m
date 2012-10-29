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

@synthesize switchOverPoints;

- (id)init
{
    self = [super init];
    self->leftTankLevel = self->rightTankLevel = 0;
    self->activeTank = 0;
    self->valueStartedFuel = 0;
    self->isOn = 0;
    self->startedTank = 0;
    self->switchOverPoints = nil;
    return self;
}

#define LEFT_TANK_LEVEL @"LeftTankLevel"
#define RIGHT_TANK_LEVEL @"RightTankLevel"
#define ACTIVE_TANK @"ActiveTank"
#define STARTED_FUEL @"StartedFuel"
#define IS_IN_FLIGHT @"IsInFlight"
#define START_TANK @"StartTank"
#define SWITCH_OVER_POINTS @"SwitchOverPoints"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    @try {
        self->leftTankLevel = [aDecoder decodeIntForKey:LEFT_TANK_LEVEL];
        self->rightTankLevel = [aDecoder decodeIntForKey:RIGHT_TANK_LEVEL];
        self->activeTank = [aDecoder decodeIntForKey:ACTIVE_TANK];
        self->valueStartedFuel = [aDecoder decodeIntForKey:STARTED_FUEL];
        self->isOn = [aDecoder decodeIntForKey:IS_IN_FLIGHT];
        self->startedTank = [aDecoder decodeIntForKey:START_TANK];
        self.switchOverPoints = [aDecoder decodeObjectForKey:SWITCH_OVER_POINTS];
    }
    @catch (NSException *e) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self->leftTankLevel forKey:LEFT_TANK_LEVEL];
    [aCoder encodeInt:self->rightTankLevel forKey:RIGHT_TANK_LEVEL];
    [aCoder encodeInt:self->activeTank forKey:ACTIVE_TANK];
    [aCoder encodeInt:self->valueStartedFuel forKey:STARTED_FUEL];
    [aCoder encodeInt:self->isOn forKey:IS_IN_FLIGHT];
    [aCoder encodeInt:self->startedTank forKey:START_TANK];
    [aCoder encodeObject:self.switchOverPoints forKey:SWITCH_OVER_POINTS];
}
@end

@implementation iffSaveSettings

- (id)init
{
    self = [super init];
    self->valueTabs = self->valueFull = self->targetDiff = 0;
    return self;
}

#define TABS_TANK_LEVEL @"TabsTankLevel"
#define FULL_TANK_LEVEL @"FullTankLevel"
#define TARGET_TANK_DIFF @"TargetTankDiff"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    @try {
        self->valueTabs = [aDecoder decodeIntForKey:TABS_TANK_LEVEL];
        self->valueFull = [aDecoder decodeIntForKey:FULL_TANK_LEVEL];
        self->targetDiff = [aDecoder decodeIntForKey:TARGET_TANK_DIFF];
    }
    @catch (NSException *e) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self->valueTabs forKey:TABS_TANK_LEVEL];
    [aCoder encodeInt:self->valueFull forKey:FULL_TANK_LEVEL];
    [aCoder encodeInt:self->targetDiff forKey:TARGET_TANK_DIFF];
}

@end


#pragma mark -
#pragma mark iffViewController

@implementation iffViewController
@synthesize sliderBackground;
@synthesize rightFuelTank;
@synthesize leftFuelTank;

@synthesize stepperBothTanks;
@synthesize textUsedFuel;

@synthesize textBothTanks;

@synthesize sliderBothTanks;
@synthesize fuelRuler;
@synthesize inFlightSwitch;
@synthesize leftRightTank;

@synthesize optionsButton;
@synthesize tabsValue;
@synthesize fullValue;
@synthesize textDiff;
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
    textDiff.text = [self->targetDiff toString];
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

#define SLIDER_HEIGHT_PCT 0.95

- (void)setSliderHeightFromBackground
{
    CGRect src = self.sliderBackground.frame;
    CGRect frame = self.sliderBothTanks.frame;
    frame.size.height = SLIDER_HEIGHT_PCT * (src.size.height - 120);
    self.sliderBothTanks.frame = frame;
}

- (void)layoutRulerFromSlider
{
    [self.fuelRuler layoutFromSliderRect:self->sliderBothTanks];
}

- (void)viewWillLayoutSubviews
{
    [self setSliderHeightFromBackground];
    [self layoutRulerFromSlider];
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
    self->maxEachTank = nil;
    self->targetDiff = [[FuelValue alloc]initFromValue:85];
    
    iffSaveData *sd = [self loadSaveData];
    iffSaveSettings *ss = [self loadSaveSettings];

    if (sd == nil)
        sd = [[iffSaveData alloc]init];
    if (ss == nil)
        ss = [[iffSaveSettings alloc]init];
    
    if (ss->valueTabs == 0)
        ss->valueTabs = [self->valueTabs toValue];
    if (ss->valueFull == 0)
        ss->valueFull = [self->valueFull toValue];
    if (ss->targetDiff == 0)
        ss->targetDiff = [self->targetDiff toValue];
    
    self->startTank = sd->startedTank;
    if (sd.switchOverPoints != nil) {
        for (FuelValue *x in sd.switchOverPoints) {
            [self->switchOverPoints addObject:[x copy]];
        }
    }
    
    [self.leftFuelTank setName:[[NSString alloc]initWithFormat:@"Left Tank"]];
    [self.rightFuelTank setName:[[NSString alloc]initWithFormat:@"Right Tank"]];
    
    [self.leftFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->leftTankLevel]];
    [self.rightFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->rightTankLevel]];
    
    self.valueTabs = [[FuelValue alloc]initFromValue:ss->valueTabs];
    self.valueFull = [[FuelValue alloc]initFromValue:ss->valueFull];
    self.targetDiff = [[FuelValue alloc]initFromValue:ss->targetDiff];
    self.leftRightTank.selectedSegmentIndex = sd->activeTank;
    self.startedFuel = [[FuelValue alloc]initFromValue:sd->valueStartedFuel];

    /* The minimum movement is 0.1 gals */
    stepperBothTanks.stepValue = 0.1;
    [self setTankDefaults];
    
    [self.sliderBothTanks setTransform:CGAffineTransformRotate(self.sliderBothTanks.transform,270.0/180*M_PI)];

    [self setFuelRuler:[[FuelRulerView alloc]init]];
     
    [self.view addSubview:self.fuelRuler];
   
    [self updateTankDiffs];

    FuelValue *both = [self.leftFuelTank.level plus:self.rightFuelTank.level];
    textUsedFuel.text = [[self.startedFuel minus:both] toString];
    [self->fuelRuler setStartedFuel:self->startedFuel];
    [self->fuelRuler setMaxFuel:self->valueFull];
    [self->fuelRuler setStartedTank:self->startTank];
    
    self->ison = sd->isOn;
    if (self->ison) {
        self.inFlightSwitch.on = TRUE;
        [self isInFlight];
    }
}

- (void)viewWillUnload
{
    [self saveLastTankValues];
}

- (void)viewDidUnload
{
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
    [self setTextDiff:nil];
    [self setOptionsButton:nil];
    [self setInFlightSwitch:nil];
    [self setRightFuelTank:nil];
    [self setLeftFuelTank:nil];
    [self setSliderBackground:nil];
    [self setStartedFuel:nil];
    [self setValueTabs:nil];
    [self setValueFull:nil];
    [self setMaxEachTank:nil];
    [self setTargetDiff:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }*/
    return YES;
}

- (void)sliderDoneSliding
{
    [self saveLastTankValues];
}

- (IBAction)sliderTouchUpInside:(id)sender {
    [self sliderDoneSliding];
}

- (IBAction)sliderTouchUpOutside:(id)sender {
    [self sliderDoneSliding];
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
}

- (void)resetUsedFuel
{
    [self setStartedFuel:[self.leftFuelTank.level plus:self.rightFuelTank.level]];
    [self->fuelRuler setStartedFuel:self->startedFuel];
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

- (void)isInFlight
{
    [self->fuelRuler setStartedTank:self->startTank];
    self->ison = TRUE;
    self.buttonFull.enabled = FALSE;
    self.buttonTabs.enabled = FALSE;
    self.optionsButton.enabled = FALSE;

    if ([self->switchOverPoints count] == 0)
        [self sampleSwitchOverPoint];

    [self->fuelRuler setSwitchOverPoints:self->switchOverPoints];
    [self recalcProjected];
    [self->fuelRuler setNeedsDisplay];
}

- (IBAction)switchOn:(id)sender {
    if (self->ison) {
        self->ison = FALSE;
        self.buttonFull.enabled = TRUE;
        self.buttonTabs.enabled = TRUE;
        self.optionsButton.enabled = TRUE;
        self->switchOverPoints = nil;
        self->projectedSwitchOverPoints = nil;
        [self->fuelRuler setSwitchOverPoints:nil];
        [self->fuelRuler setProjectedSwitchOverPoints:nil];
        [self->fuelRuler setNeedsDisplay];
    } else {
        [self resetUsedFuel];
        if (leftRightTank.selectedSegmentIndex == 0) {
            self->startTank = 0;
        } else {
            self->startTank = 1;
        }
        self->switchOverPoints = [[NSMutableArray alloc]initWithCapacity:10];
        [self isInFlight];
    }
    [self saveLastTankValues];
}

- (IBAction)stepperBothTanks:(id)sender {
    sliderBothTanks.value = ((UIStepper*)sender).value;
    [self sliderBothTanks:sliderBothTanks];
    [self sliderDoneSliding];
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
    
    if (!self->ison) {
        /* Short exit save */
        [self saveLastTankValues];
        return;
    }
    
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
    /* Save the new list of points */
    [self saveLastTankValues];

    [self->fuelRuler setNeedsDisplay];
}

#pragma mark -
#pragma mark Saving and Loading

#define DATA_FILE @"IffData"
#define SETTINGS_FILE @"IffSettings"

- (NSString *)pathForDataFile
{
    NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    
    if (documentDir)
        path = [documentDir objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/%@", path, DATA_FILE];
}

- (NSString *)pathForSettingsFile
{
    NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    
    if (documentDir)
        path = [documentDir objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/%@", path, SETTINGS_FILE];
}

- (void)saveLastTankValues
{
    iffSaveData *sd = [[iffSaveData alloc]init];
    
    sd->leftTankLevel = [self.leftFuelTank.level toValue];
    sd->rightTankLevel = [self.rightFuelTank.level toValue];
    sd->activeTank = self.leftRightTank.selectedSegmentIndex;
    sd->valueStartedFuel = [self.startedFuel toValue];
    sd->isOn = self->ison;
    sd->startedTank = self->startTank;
    sd.switchOverPoints = self->switchOverPoints;
    
    NSString *archivePath = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject:sd toFile:archivePath];
}

- (void)saveLastSettings
{
    iffSaveSettings *ss = [[iffSaveSettings alloc]init];
    ss->valueTabs = [self.valueTabs toValue];
    ss->valueFull = [self.valueFull toValue];
    ss->targetDiff = [self.targetDiff toValue];
    
    NSString *archivePath = [self pathForSettingsFile];
    [NSKeyedArchiver archiveRootObject:ss toFile:archivePath];
}

- (iffSaveData*)loadSaveData
{
    NSString *archivePath = [self pathForDataFile];
    iffSaveData *sd = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    return sd;
}

- (iffSaveSettings*)loadSaveSettings
{
    NSString *archivePath = [self pathForSettingsFile];
    iffSaveSettings *ss = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    return ss;
}

#pragma mark -
#pragma mark SettingOptions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowIffOptions"]) {
        iffOptionsViewController* pOther = [segue destinationViewController];
        [pOther setDelegate:self];
        /* The pOther stores these as type "copy" */
        [pOther initializeValues:self.valueTabs valueFull:self.valueFull valueDiff:self.targetDiff];
    } else if ([[segue identifier] isEqualToString:@"ShowIffInfo"]) {
        iffInfoViewController* pOther = [segue destinationViewController];
        [pOther setDelegate:self];
    }
}

- (void)iffOptionsViewControllerDidFinish:(iffOptionsViewController *)controller
{
    /* These are of property type "copy" */
    [self setValueTabs: controller.valueTabs];
    [self setValueFull: controller.valueFull];
    [self setTargetDiff:controller.valueDiff];
    [self setValuesDefaults];
    [self saveLastSettings];
    [controller dismissModalViewControllerAnimated:TRUE];
}

- (void)iffInfoViewControllerDidFinish:(iffInfoViewController *)controller
{
    [controller dismissModalViewControllerAnimated:TRUE];
}

@end
