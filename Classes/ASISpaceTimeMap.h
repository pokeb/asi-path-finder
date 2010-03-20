//
//  ASISpaceTimeMap.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 15/06/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//  An ASISpaceTimeMap records the predicted position of objects in the future
//  When objects plan a route, they record where they think they're going to be at each time step
//  This allows objects to co-operatively path find - they won't be able to travel to positions that other units have already reserved for that point in time
//  As game time advances, incrementTime effectively throws away the most recent time step to make space for a future one
//  In implementation, a space time map is an array of positions on the map, with a new array for each time step

#import "ASIObjectMap.h"

@interface ASISpaceTimeMap : ASIObjectMap {
	
	// Record our positions in the set of time steps we have
	// When incrementTime is called, we increment this, or reset it to zero if we're at the end of the time span
	// This allows us to perform path finding part way through the time span
	unsigned char currentTimeStep;
	
}

// Clears the whole space time map for all time steps
- (void)clear;

// The number of time steps this space time map will hold
- (int)timeSpan;
- (void)setTimeSpan:(unsigned int)newTimeSpan;

// Create a new space time map with a map size, and the number of time steps
- (id)initWithSize:(CGSize)size timeSpan:(unsigned int)newTimeSpan;

// Set an object at a position for a certain amount of time
- (void)setObject:(id)object atPosition:(CGPoint)position fromTime:(unsigned int)time forTimeSteps:(unsigned int)timeSteps;

// Remove an object at a position for a certain amount of time
- (void)removeObject:(id)object atPosition:(CGPoint)position fromTime:(unsigned int)time forTimeSteps:(unsigned int)timeSteps;

// Convenience method to set an object at a position for all time steps we're tracking
- (void)setObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(unsigned int)time;

// Convenience method to remove an object from a position for all time steps we're tracking
- (void)removeObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(unsigned int)time;

// Increment currentTimeStep, and clear the whole map if we're on step 0
- (void)incrementTime;


@property (assign, nonatomic) unsigned char currentTimeStep;
@property (assign, nonatomic) unsigned char timePointer;
@end
