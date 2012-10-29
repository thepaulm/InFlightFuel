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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
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
