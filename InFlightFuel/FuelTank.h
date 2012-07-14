//
//  FuelTank.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 7/13/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FuelTank : NSManagedObject

@property (nonatomic, retain) NSNumber * tankNo;
@property (nonatomic, retain) NSNumber * level;

@end
