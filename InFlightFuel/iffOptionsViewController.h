//
//  iffOptionsViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 8/28/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iffOptionsViewController;

@protocol iffOptionsViewControllerDelegate
- (void)iffOptionsViewControllerDidFinish:(iffOptionsViewController*)controller;
@end

@interface iffOptionsViewController : UIViewController
{
    @public
    float valueTabs;
    float valueFull;
}

@property (weak, nonatomic) id <iffOptionsViewControllerDelegate> delegate;
- (void)initializeValues:(float)vt valueFull:(float)vf;
- (IBAction)clickDone:(id)sender;

@end
