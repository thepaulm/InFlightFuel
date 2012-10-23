//
//  FuelValue.m
//  InFlightFuel
//
//  Created by Paul Mikesell on 9/25/12.
//  Copyright (c) 2012 personal. All rights reserved.
//

#import "FuelValue.h"

//#define TRACK_FUEL_VALUES 1
#ifdef TRACK_FUEL_VALUES
int FuelValueCount = 0;
#endif

@implementation FuelValue

-(id)initFromValue:(int)v
{
    self = [super init];
    self->value = v;
    
#ifdef TRACK_FUEL_VALUES
    FuelValueCount ++;
    NSLog(@"initFromValue [%d]", FuelValueCount);
#endif
    return self;
}

-(id)initFromInt:(int)v
{
    self = [super init];
    self->value = v * 10;
    
#ifdef TRACK_FUEL_VALUES
    FuelValueCount++;
    NSLog(@"initFromInt [%d]", FuelValueCount);
#endif
    return self;
}

-(id)initFromFloat:(float)v
{
    self = [super init];
    /* Round this up */
    self->value = (v * 10.0) + 0.5;
    
#ifdef TRACK_FUEL_VALUES
    FuelValueCount++;
    NSLog(@"initFromFloat [%d]", FuelValueCount);
#endif
    return self;
}

-(void)dealloc
{
#ifdef TRACK_FUEL_VALUES
    FuelValueCount--;
    NSLog(@"dealloc [%d]", FuelValueCount);
#endif
}

-(NSString*)toString
{
    return [[NSString alloc]initWithFormat:@"%d.%d", self->value / 10, self->value % 10];
}

-(void)add:(FuelValue *)other
{
    self->value = self->value + other->value;
}

-(void)subtract:(FuelValue *)other
{
    self->value = self->value - other->value;
}

-(void)intDevide:(int)x
{
    self->value /= x;
}

-(float)toFloat
{
    return (float)(self->value / 10.0);
}

-(int)toInt
{
    return self->value;
}

-(int)toValue
{
    return self->value;
}

-(id)copy
{
    id n = [[FuelValue alloc]initFromValue:self->value];
    return n;
}

-(id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copy];
}

-(id)plus:(FuelValue*)other
{
    id n = [self copy];
    [n add:other];
    return n;
}

-(id)minus:(FuelValue*)other
{
    id n = [self copy];
    [n subtract:other];
    return n;
}

-(id)slashInt:(int)x
{
    id n = [self copy];
    [n intDevide:x];
    return n;
}

-(BOOL)lt:(FuelValue *)other
{
    return self->value < other->value;
}

-(BOOL)gt:(FuelValue *)other
{
    return self->value > other->value;
}

-(BOOL)eq:(FuelValue *)other
{
    return self->value == other->value;
}

#pragma mark -
#pragma mark Saving And Loading

#define FUEL_VALUE @"FuelValue"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    int v = [aDecoder decodeIntForKey:FUEL_VALUE];
    return [self initFromValue:v];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self->value forKey:FUEL_VALUE];
}

@end
