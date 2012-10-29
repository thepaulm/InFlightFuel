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
"    The purpose of this app is to help in fuel planning and projections for tank switching.  When InFlight mode "
"is off, you can set the tank levels to Tabs for Full, or manually set the levels with the fuel slider. "
"You can also enter the options window and set the Tabs and Full levels, as well as the target difference "
"for the levels between tanks.  These settings will be remembered.\n\n"
"    When InFlight mode is On, all of the controls other than the main slider and tank switch are disabled. "
"This is to prevent accidentally resetting your fuel levels while in Flight.  In Flight mode will also "
"enable tracking of your previous cumulative tank switch levels, as well as projections for when you "
"should switch to maintain your target tank differential.  Don't worry if you switch early or late, "
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
