//
//  iffInfoViewController.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 10/28/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "iffInfoViewController.h"

@interface iffInfoViewController ()

@end

@implementation iffInfoViewController
@synthesize text;

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.text setNumberOfLines:0];
    [self.text setText:
@"Welcome to InFlightFuel!\n\n"
"    The purpose of this app is to help in fuel planning and projections for tank switching.\n\n"
"Mode of Operation:\n\n"
"    With the InFlight switch set to \"Off\", use the Tabs or Full buttons, or manually set your "
"starting fuel levels with the slider.  Once you have your initial starting fuel levels set, "
"switch the InFlight switch to \"On\" before you begin your flight.\n\n"
"    With the InFlight switch set to \"On\", InFlightFuel will track your in flight tank switches "
"as well as make projections about when (in terms of total fuel used) you should switch to "
"maintain your target tank differential.  You can set initial (departure leg) and subsequent "
"alert timers to remind you in case you forget to check fuel consumption. "
" The pink line is showing your current tank use segment "
"and the black lines show historical tank switches.  Don't worry if you switch early or late, "
"we will recalculate the next switch projection on the fly.\n\n"
"    Comments, suggestions, or bug reports to pmikesell@gmail.com"];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)clickDone:(id)sender {
    [self.delegate iffInfoViewControllerDidFinish:self];
}
@end
