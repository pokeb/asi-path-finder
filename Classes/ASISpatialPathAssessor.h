//
//  ASISpatialPathAssessor.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//  ASISpatialPathAssessor is a class that implements an A* path finder - it looks for a full route between two points
//  When used in conjunction with an ASISpaceTimePathFinder, it acts as the first stage to finding a path
//  Tell the path assessor to search backwards from the destination to the origin, and it will record the distance of each point on the way from the destination
//  The space time path finder can then use this data to figure out where to go next without having to compute a full path each time

#import "ASIPathSearchDataTypes.h"

@class ASIWorldMap;
@class MapObject;
@class ASIPath;
@class ASIMoveableObject;

@interface ASISpatialPathAssessor : NSObject {
	
	// The starting point - when used with a space time path finder, this will normally be the destination position
	Position3D origin;
	
	// The end point - when used with a space time path finder, this will normally be the starting position
	Position3D destination;
	
	// A reference to the map - we look here to find fixed objects (eg buildings) that are in the way
	ASIWorldMap *map;
	
	// An array of positions we've looked at - the distance from our origin position will be stored here
	float *positions;
	
	// The object that wants to assess a path - we use this to ensure an object will ignore itself when looking for free positions
	ASIMoveableObject *object;
	
	// Set to YES when we fail to find a route between two positions
	BOOL failedToFindRoute;
}

// Create a new path assessor
- (id)initWithMap:(ASIWorldMap *)newMap;

// Attempt to find a path between two points
// Rather than returning a path, we record the distance from our origin of each point along the way
// A space time path finder can then use this data as a hint for where to go next as it plans
- (void)assessPathFrom:(Position3D)newOrigin to:(Position3D)newDestination;

// Space time path finders use this to obtain the distance from their destination of a particular position they are considering
- (float)realDistanceFromDestination:(Position3D)position;
- (BOOL)haveAssessed:(Position3D)position;

@property (assign, nonatomic) Position3D origin;
@property (assign, nonatomic) Position3D destination;
@property (assign, nonatomic) ASIWorldMap *map;
@property (assign, nonatomic) ASIMoveableObject *object;
@property (assign, nonatomic) BOOL failedToFindRoute;
@end
