//
//  FuelTank.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

@interface FuelTank : NSObject //<NSCoding>
{
    @public
    float level;
}

- (id)initWithLevel:(float)l;

@end
