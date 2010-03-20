//
//  ASISpaceTimePathFinder.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//  ASISpaceTimePathFinder is a co-operative path finder. It calculates a portion of a path between two points, and reserves the positions it will use in an ASISpaceTimeMap
//  It requires the full path between the origin and destination has been previously computed by an ASISpatialPathAssessor
//  It then uses the path assessment data to work out where it should go each step, with the additional constraint that it must avoid positions other units have already taken

#import "ASIPathSearchDataTypes.h"

@class MapDocument;
@class ASIMoveableObject;
@class ASIPath;
@class ASISpatialPathAssessor;

@interface ASISpaceTimePathFinder : NSObject {
	
	// The object performing the path finding
	ASIMoveableObject *object;
	
	// When set to YES, the path finder will ask the object if we're near enough to the target to stop each time it finds a valid position
	// This might be used when telling objects to attack another object - they only need to get within range of it to attack
	BOOL stopWhenWithinRangeOfTarget;
	
	// Set to YES when the path assessor couldn't find a route, so we'll use our current location as the target
	// We do this rather than setting the destination to the origin, so the object can re-attempt to find a route later on
	BOOL attemptToStayInSameLocation; 
}

// Create a path finder
- (id)initWithObject:(ASIMoveableObject *)newObject;

// Perform path finding, and return a path that the object can use until they perform path finding again
- (ASIPath *)findPath;

@property (assign, nonatomic) ASIMoveableObject *object;
@property (assign, nonatomic) BOOL stopWhenWithinRangeOfTarget;
@property (assign, nonatomic) BOOL attemptToStayInSameLocation;
@end
