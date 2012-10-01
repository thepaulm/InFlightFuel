//
//  FuelValue.h
//  InFlightFuel
//
//  Created by Paul Mikesell on 9/25/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuelValue : NSObject
{
    int value;
}

-(id)initFromValue:(int)v;
-(id)initFromInt:(int)v;
-(id)initFromFloat:(float)v;
-(NSString*)toString;
-(void)add:(FuelValue*)other;
-(void)subtract:(FuelValue*)other;
-(void)intDevide:(int)x;
-(float)toFloat;
-(int)toValue;

-(id)copy;

-(id)plus:(FuelValue*)other;
-(id)minus:(FuelValue*)other;
-(id)slashInt:(int)x;

-(BOOL)lt:(FuelValue *)other;
-(BOOL)gt:(FuelValue *)other;

@end
