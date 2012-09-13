//
//  FuelTank.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "FuelTank.h"


@implementation FuelTank

- (id)initWithLevel:(float)l
{
    self = [super init];
    self->level = l;
    return self;
}

@end
