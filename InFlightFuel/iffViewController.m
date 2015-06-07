//
//  iffViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffViewController.h"
#import "FuelTank.h"

NSValue *
valueFromInteger(NSInteger i)
{
    return [NSValue valueWithBytes:&i objCType:@encode(NSInteger)];
}

NSInteger
integerFromValue(NSValue *v)
{
    NSInteger i;
    [v getValue:&i];
    return i;
}

#pragma mark -
#pragma mark IffSaveData

@implementation iffSaveData

@synthesize switchOverPoints;
@synthesize timerStart;

- (id)init
{
    self = [super init];
    self->leftTankLevel = self->rightTankLevel = 0;
    self->activeTank = 0;
    self->valueStartedFuel = 0;
    self->isOn = 0;
    self->startedTank = 0;
    self->switchOverPoints = nil;
    self->runningTimer = 0;
    self->timerStart = nil;
    return self;
}

#define LEFT_TANK_LEVEL @"LeftTankLevel"
#define RIGHT_TANK_LEVEL @"RightTankLevel"
#define ACTIVE_TANK @"ActiveTank"
#define STARTED_FUEL @"StartedFuel"
#define IS_IN_FLIGHT @"IsInFlight"
#define START_TANK @"StartTank"
#define SWITCH_OVER_POINTS @"SwitchOverPoints"
#define RUNNING_TIMER @"RunningTimer"
#define TIMER_START @"TimerStart"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    /* Keep these in the order they were introduced. If we fail to load something
     it means the earlier ones will be good. We should be using reasonable
     defaults */
    @try {
        self->leftTankLevel = [aDecoder decodeIntForKey:LEFT_TANK_LEVEL];
        self->rightTankLevel = [aDecoder decodeIntForKey:RIGHT_TANK_LEVEL];
        self->activeTank = [aDecoder decodeIntForKey:ACTIVE_TANK];
        self->valueStartedFuel = [aDecoder decodeIntForKey:STARTED_FUEL];
        self->isOn = [aDecoder decodeIntForKey:IS_IN_FLIGHT];
        self->startedTank = [aDecoder decodeIntForKey:START_TANK];
        self.switchOverPoints = [aDecoder decodeObjectForKey:SWITCH_OVER_POINTS];
    }
    @catch (NSException *e) {}
    
    if ([aDecoder containsValueForKey:RUNNING_TIMER] &&
        [aDecoder containsValueForKey:TIMER_START]) {
        @try {
            self->runningTimer = [aDecoder decodeIntForKey:RUNNING_TIMER];
            self->timerStart = [aDecoder decodeObjectForKey:TIMER_START];
        }
        @catch (NSException *e) {}
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
    [aCoder encodeInt:self->runningTimer forKey:RUNNING_TIMER];
    [aCoder encodeObject:self->timerStart forKey:TIMER_START];
}
@end

@implementation iffSaveSettings

#define BAD_INT (-1)

- (id)init
{
    self = [super init];
    self->valueTabs = self->valueFull = self->targetDiff = 0;
    self->initialTimer = self->subsequentTimer = BAD_INT;
    return self;
}

#define TABS_TANK_LEVEL @"TabsTankLevel"
#define FULL_TANK_LEVEL @"FullTankLevel"
#define TARGET_TANK_DIFF @"TargetTankDiff"
#define INITIAL_TIMER @"InitialTimer"
#define SUBSEQUENT_TIMER @"SubsequentTimer"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    /* Keep these in the order they were introduced. If we fail to load something
     it means the earlier ones will be good. We should be using reasonable
     defaults */
    @try {
        self->valueTabs = [aDecoder decodeIntForKey:TABS_TANK_LEVEL];
        self->valueFull = [aDecoder decodeIntForKey:FULL_TANK_LEVEL];
        self->targetDiff = [aDecoder decodeIntForKey:TARGET_TANK_DIFF];
    }
    @catch (NSException *e) {}
    
    if ([aDecoder containsValueForKey:INITIAL_TIMER] &&
        [aDecoder containsValueForKey:SUBSEQUENT_TIMER]) {
        @try {
            self->initialTimer = [aDecoder decodeIntForKey:INITIAL_TIMER];
            self->subsequentTimer = [aDecoder decodeIntForKey:SUBSEQUENT_TIMER];
        }
        @catch (NSException *e) {}
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self->valueTabs forKey:TABS_TANK_LEVEL];
    [aCoder encodeInt:self->valueFull forKey:FULL_TANK_LEVEL];
    [aCoder encodeInt:self->targetDiff forKey:TARGET_TANK_DIFF];
    [aCoder encodeInt:self->initialTimer forKey:INITIAL_TIMER];
    [aCoder encodeInt:self->subsequentTimer forKey:SUBSEQUENT_TIMER];
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
@synthesize timerText;
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

@synthesize valueInitialTimer;
@synthesize valueSubsequentTimer;

@synthesize timerStart;
@synthesize timer;
@synthesize notification;

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

- (void)layoutRulerFromSlider
{
    CGRect fs = [self.stepperBothTanks frame];
    CGRect flr = [self.leftRightTank frame];
    int top, bottom;
    
    top = flr.origin.y + flr.size.height;
    bottom = fs.origin.y;
    [self.fuelRuler layoutFromSliderRect:self->sliderBothTanks :self.sliderBackground.frame :top :bottom];
}

- (void)viewWillLayoutSubviews
{
    [self layoutRulerFromSlider];
}

- (void)fixTextRelativeHeight:(UIView*) item :(CGFloat)h
{
    CGRect tr;
    tr = [item frame];
    tr.size.height = h;
    item.frame = tr;
}

#define THEIGHT_PCT 0.03

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Get our frame so we can do relative object sizing */
    CGFloat text_height;
    CGRect frame = [[self view] frame];
    text_height = frame.size.height * THEIGHT_PCT;
    
    /* Adjust the relative heights of the full and tabs value fields */
    [self fixTextRelativeHeight:self.tabsValue :text_height];
    [self fixTextRelativeHeight:self.fullValue :text_height];
    [self fixTextRelativeHeight:self.textBothTanks :text_height];
    [self fixTextRelativeHeight:self.textUsedFuel :text_height];
    [self fixTextRelativeHeight:self.timerText :text_height];
    
    self->startTank = 0;
    self->switchOverPoints = [[NSMutableArray alloc]initWithCapacity:10];
    self->projectedSwitchOverPoints = [[NSMutableArray alloc]initWithCapacity:1];
    
    /* These are where we set the non-stored defaults. There's probably
       a better place for these */
    self->ison = FALSE;
    /* Use -> here = don't want to copy these initializers */
    self->startedFuel = [[FuelValue alloc]initFromInt:0];
    self->valueTabs = [[FuelValue alloc]initFromInt:60];
    self->valueFull = [[FuelValue alloc]initFromInt:92];
    self->maxEachTank = nil;
    self->targetDiff = [[FuelValue alloc]initFromValue:85];
    self->valueInitialTimer = valueFromInteger(0);
    self->valueSubsequentTimer = valueFromInteger(0);
    self->runningTimer = 0;
    self->timerStart = nil;
    self->timer = nil;
    
    /* Load the data and settings from storage */
    iffSaveData *sd = [self loadSaveData];
    iffSaveSettings *ss = [self loadSaveSettings];

    /* If we failed to load either, make a default structure */
    if (sd == nil)
        sd = [[iffSaveData alloc]init];
    if (ss == nil)
        ss = [[iffSaveSettings alloc]init];
    
    /* For anything we didn't load, use our defaults instead */
    if (ss->valueTabs == 0)
        ss->valueTabs = [self->valueTabs toValue];
    if (ss->valueFull == 0)
        ss->valueFull = [self->valueFull toValue];
    if (ss->targetDiff == 0)
        ss->targetDiff = [self->targetDiff toValue];
    if (ss->initialTimer == BAD_INT)
        ss->initialTimer = (int)integerFromValue(self->valueInitialTimer);
    if (ss->subsequentTimer == BAD_INT)
        ss->subsequentTimer = (int)integerFromValue(self->valueSubsequentTimer);
    
    self->startTank = sd->startedTank;
    if (sd.switchOverPoints != nil) {
        for (FuelValue *x in sd.switchOverPoints) {
            [self->switchOverPoints addObject:[x copy]];
        }
    }
    
    [self.leftFuelTank setName:@"Left Tank"];
    [self.rightFuelTank setName:@"Right Tank"];
    
    /* Now we use the data and settings structures. These should be either loaded
       or defaults at this point */
    [self.leftFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->leftTankLevel]];
    [self.rightFuelTank setLevel:[[FuelValue alloc]initFromValue:sd->rightTankLevel]];
    
    self.valueTabs = [[FuelValue alloc]initFromValue:ss->valueTabs];
    self.valueFull = [[FuelValue alloc]initFromValue:ss->valueFull];
    self.targetDiff = [[FuelValue alloc]initFromValue:ss->targetDiff];
    self.valueInitialTimer = valueFromInteger(ss->initialTimer);
    self.valueSubsequentTimer = valueFromInteger(ss->subsequentTimer);
    
    self.leftRightTank.selectedSegmentIndex = sd->activeTank;
    self.startedFuel = [[FuelValue alloc]initFromValue:sd->valueStartedFuel];

    /* The minimum movement is 0.1 gals */
    stepperBothTanks.stepValue = 0.1;
    [self setTankDefaults];
    
    /* Rotate 90 degress to make vertical */
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
    self->runningTimer = sd->runningTimer;
    self->timerStart = sd.timerStart;
    self->notification = nil;
    
    if (self->ison) {
        self.inFlightSwitch.on = TRUE;
        [self isInFlight:true];
    } else {
        [self timerStopFlight];
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
    [self setValueInitialTimer:nil];
    [self setValueSubsequentTimer:nil];
    [self setTimerStart:nil];
    [self setTimer:nil];
    [self setNotification:nil];
    [self setTimerText:nil];
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

- (void)updateTimerText :(Boolean *)exp
{
    Boolean negative = false;
    NSDate *now = [NSDate date];
    NSTimeInterval i = [now timeIntervalSinceDate:self.timerStart];
    int remaining_seconds = 0;
    if (self->runningTimer == 1)
        remaining_seconds = (int)integerFromValue(self.valueInitialTimer) * 60;
    else if (self->runningTimer == 2)
        remaining_seconds = (int)integerFromValue(self.valueSubsequentTimer) * 60;
    
    remaining_seconds -= (int)i;
    if (remaining_seconds < 0) {
        negative = true;
        remaining_seconds = -remaining_seconds;
    }
    int hrs = remaining_seconds / 3600;
    remaining_seconds -= 3600 * hrs;
    int mins = remaining_seconds / 60;
    remaining_seconds -= 60 * mins;
    int secs = remaining_seconds;
    
    NSString *t;
    if (hrs) {
        t = [[NSString alloc]initWithFormat:@"%s%.2d:%.2d:%.2d",
             negative ? "-" : "", hrs, mins, secs];
    } else {
        t = [[NSString alloc]initWithFormat:@"%s%.2d:%.2d",
             negative ? "-" : "", mins, secs];
    }
    if (negative) {
        if (exp)
            *exp = true;
        [self.timerText setTextColor:[UIColor redColor]];
    } else {
        if (exp)
            *exp = false;
        [self.timerText setTextColor:nil];
    }
         
    [self.timerText setText:t];
    [self.timerText setNeedsDisplay];
}

- (void)timerSeconds :(NSTimer *)t
{
    if (t != self.timer) {
        [t invalidate];
    }
    [self updateTimerText:NULL];
}


- (void)invalidateTimer
{
    if (self.timer) {
        [self.timer invalidate];
        [self setTimer:nil];
    }
    if (self.notification) {
        UIApplication *theApp = [UIApplication sharedApplication];
        [theApp cancelLocalNotification:self.notification];
        [theApp cancelAllLocalNotifications];
        self.notification = nil;
    }
}

- (void)resetTimer
{
    if (self->runningTimer == 1) {
        self->runningTimer = 2;
        if (integerFromValue(self.valueSubsequentTimer) == 0) {
            [self timerStopFlight];
            return;
        }
    }
    self.timerStart = [NSDate date];
    [self invalidateTimer];
    [self timerInFlight:false];
}

/* timerInFlight
 
   The flight is ongoing and we need to set up timer stuff. This happens on the InFlight switchover
   and also when we are recovering from a crash.
*/
- (void)timerInFlight: (Boolean)restart
{
    NSTimeInterval delta;
    /* If no timer value, just set it to disabled */
    if (integerFromValue(self.valueInitialTimer) == 0 &&
        integerFromValue(self.valueSubsequentTimer) == 0) {
        [self.timerText setTextColor:nil];
        [self.timerText setText:@"Disabled"];
        self->runningTimer = 0;
    } else {
        if (self->runningTimer == 1) {
            delta = integerFromValue(self.valueInitialTimer) * 60;
        } else {
            delta = integerFromValue(self.valueSubsequentTimer) * 60;
        }
        Boolean expired = false;
        /* We should alays have a proper running timer and start time at this point. Update the text */
        [self updateTimerText:&expired];
        
        if (self.timer == nil) {
            /* Set up the callback to refresh the text and check for expiry */
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timerSeconds:)
                                                        userInfo:nil
                                                         repeats:true];
        }
        /* If we don't already have a notification (not sure how this could happen anyway),
           and we aren't expired on a restart, then handle setting up the notification */
        if (self.notification == nil && !(expired && restart)) {
            UIApplication *theApp = [UIApplication sharedApplication];
            [theApp cancelAllLocalNotifications];
            /* Set up the alert */
            self.notification = [UILocalNotification alloc];
            self.notification.alertAction = @"Fuel Timer";
            self.notification.alertBody = @"Fuel timer expired";
            self.notification.fireDate = [[NSDate alloc]initWithTimeInterval:delta
                                                                   sinceDate:self.timerStart];
            self.notification.repeatInterval = 0;
            self.notification.repeatCalendar = 0;
            if (expired) {
                [theApp presentLocalNotificationNow:self.notification];
            } else {
                [theApp scheduleLocalNotification:self.notification];
            }

        }
    }
}

/* timerStartFlight
 
   We have flipped from not flying to flying. Do the initialization stuff.
*/
- (void)timerStartFlight
{
    /* Set which timer we are running */
    if (integerFromValue(self.valueInitialTimer) != 0) {
        self->runningTimer = 1;
    } else if (integerFromValue(self.valueSubsequentTimer) != 0) {
        self->runningTimer = 2;
    } else {
        self->runningTimer = 0;
    }
    
    /* Set what time it started at. Don't call resetTimer here - it also flips the timer */
    if (self->runningTimer)
        self.timerStart = [NSDate date];
    
    /* Don't call timerInFlight here. It will get called from isInFlight. */
}

- (void)timerStopFlight
{
    [self.timerText setTextColor:nil];
    [self.timerText setText:@"Off"];
    self->runningTimer = 0;
    [self invalidateTimer];
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

- (void)isInFlight: (Boolean)restart
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
    [self timerInFlight:restart];
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
        [self timerStopFlight];
    } else {
        [self resetUsedFuel];
        if (leftRightTank.selectedSegmentIndex == 0) {
            self->startTank = 0;
        } else {
            self->startTank = 1;
        }
        self->switchOverPoints = [[NSMutableArray alloc]initWithCapacity:10];
        
        /* Initialize the timer values. isInFlight will take care of the rest */
        [self timerStartFlight];
        [self isInFlight:false];
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
    int count = (int)[self->switchOverPoints count];
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
    [self resetTimer];
    
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
    sd->activeTank = (int)self.leftRightTank.selectedSegmentIndex;
    sd->valueStartedFuel = [self.startedFuel toValue];
    sd->isOn = self->ison;
    sd->startedTank = self->startTank;
    sd.switchOverPoints = self->switchOverPoints;
    sd->runningTimer = self->runningTimer;
    sd.timerStart = self->timerStart;
    
    NSString *archivePath = [self pathForDataFile];
    [NSKeyedArchiver archiveRootObject:sd toFile:archivePath];
}

- (void)saveLastSettings
{
    iffSaveSettings *ss = [[iffSaveSettings alloc]init];
    ss->valueTabs = [self.valueTabs toValue];
    ss->valueFull = [self.valueFull toValue];
    ss->targetDiff = [self.targetDiff toValue];
    ss->initialTimer = (int)integerFromValue(self.valueInitialTimer);
    ss->subsequentTimer = (int)integerFromValue(self.valueSubsequentTimer);
    
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
        [pOther initializeValues:self.valueTabs valueFull:self.valueFull valueDiff:self.targetDiff
               valueInitialTimer:self.valueInitialTimer valueSubsequenTimer:self.valueSubsequentTimer];
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
    [self setValueInitialTimer:controller.valueInitialTimer];
    [self setValueSubsequentTimer:controller.valueSubsequentTimer];
    [self setValuesDefaults];
    [self saveLastSettings];
    [controller dismissViewControllerAnimated:TRUE
                                   completion:nil];
}

- (void)iffInfoViewControllerDidFinish:(iffInfoViewController *)controller
{
    [controller dismissViewControllerAnimated:TRUE
                                    completion:nil];
}

@end
