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
    textTabs.text = [[NSString alloc]initWithFormat:@"%.1f", self->valueTabs];
}

- (void)updateTextFull
{
    textFull.text = [[NSString alloc]initWithFormat:@"%.1f", self->valueFull];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTextTabs];
    [self updateTextFull];
    stepperTabs.value = self->valueTabs;
    stepperFull.value = self->valueFull;
}

- (void)initializeValues:(float)vt valueFull:(float)vf
{
    self->valueTabs = vt;
    self->valueFull = vf;
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
    self->valueTabs = ((UIStepper*)sender).value;
    [self updateTextTabs];
}

- (IBAction)onStepperFull:(id)sender {
    self->valueFull = ((UIStepper*)sender).value;
    [self updateTextFull];
}
@end
