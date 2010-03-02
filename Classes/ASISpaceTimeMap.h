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
	
	// Used internally to record our position in the set of time steps we have
	// When incrementTime is called, we clear the current time step, then increment timePointer so the current time step is now the next one
	// Since we have a fixed number of time steps to keep track of, when timePointer exceeds the number of timeSteps (timeSpan), we simply reset to zero
	// This trick means we don't have to move anything in memory to increment time
	unsigned char timePointer;
	
	// A counter that increases every time we increment time - can be used in debugging to see which time step we're on
	int gameTime;
}

// Clears the whole space time map for all time steps
- (void)clear;

// The number of time steps this space time map will hold
- (int)timeSpan;
- (void)setTimeSpan:(int)newTimeSpan;

// Create a new space time map with a map size, and the number of time steps
- (id)initWithSize:(CGSize)size timeSpan:(int)newTimeSpan;

// Convenience method to set an object at a position for all time steps we're tracking
- (void)setObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(int)time;

// Convenience method to remove an object from a position for all time steps we're tracking
- (void)removeObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(int)time;

// Clear the current time step, and increment timePointer so we can deal with the next one
- (void)incrementTime;

// May be helpful for debugging - prints out a particular timestep to the console
- (NSString *)printMapForTime:(int)time;

@property (assign, nonatomic) unsigned char timePointer;
@property (assign, nonatomic) int gameTime;
@end
