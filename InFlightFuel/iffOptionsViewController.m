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

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = NULL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
