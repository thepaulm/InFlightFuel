//
//  iffInfoViewController.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 10/28/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iffInfoViewController;

@protocol iffInfoViewControllerDelegate
- (void)iffInfoViewControllerDidFinish:(iffInfoViewController*)controller;
@end

@interface iffInfoViewController : UIViewController

@property (weak, nonatomic) id <iffInfoViewControllerDelegate> delegate;
- (IBAction)clickDone:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end
