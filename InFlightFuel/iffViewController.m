//
//  iffViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 6/24/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffViewController.h"

@interface iffViewController ()

@end

@implementation iffViewController
@synthesize textUsedFuel;

@synthesize textRightTank;
@synthesize sliderRightTank;

@synthesize textLeftTank;
@synthesize sliderLeftTank;

@synthesize textBothTanks;

@synthesize sliderBothTanks;
@synthesize leftRightTank;


float leftTankFuel = 30;
float rightTankFuel = 30;
BOOL ison = FALSE;
float startedFuel = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    sliderLeftTank.value = leftTankFuel;
    sliderRightTank.value = rightTankFuel;
    textLeftTank.text = [self getTankString:sliderLeftTank];
    textRightTank.text = [self getTankString:sliderRightTank];
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    sliderBothTanks.value = leftTankFuel + rightTankFuel;
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
            sliderBothTanks.value = leftTankFuel + rightTankFuel;
        // overflow
        } else if (leftTankFuel - diff > 46.0) {
            leftTankFuel = 46.0;
            sliderBothTanks.value = leftTankFuel + rightTankFuel;
        } else {
            leftTankFuel -= diff;
        }
        textLeftTank.text = [self getValueString:leftTankFuel];
        sliderLeftTank.value = leftTankFuel;
    } else {
        // underflow
        if (rightTankFuel < diff) {
            rightTankFuel = 0.0;
            sliderBothTanks.value = leftTankFuel + rightTankFuel;
        // overflow
        } else if (rightTankFuel - diff > 46.0) {
            rightTankFuel = 46.0;
            sliderBothTanks.value = leftTankFuel + rightTankFuel;
        } else {
            rightTankFuel -= diff;
        }
        textRightTank.text = [self getValueString:rightTankFuel];
        sliderRightTank.value = rightTankFuel;
    }
    textBothTanks.text = [self getValueString:leftTankFuel + rightTankFuel];
    textUsedFuel.text = [self getValueString:startedFuel - (leftTankFuel + rightTankFuel)];
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
@end
