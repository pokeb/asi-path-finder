//
//  ASIUnit.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  An example of an object that can move

#import "ASIMapObject.h"

@class ASISpatialPathAssessor;
@class ASIPath;
@class ASITeam;

@interface ASIUnit : ASIMapObject {

	// The team this object belongs to
	// Objects will co-operatively path find with other units in their team, but not with units from other teams
	ASITeam	*team;
	
	// The destination of this object (may be the same as its position if it needs to remain in one place
	Position3D destination;
	
	// This unit's path assessment allows the object to caculate a partial path, safe in the knowledge it is travelling in the right direction
	ASISpatialPathAssessor *pathAssessment;
	
	// Set to YES when our path assessor fails to find a route to the target
	// Used to delay path reassessment so we don't spend too much time looking for a path that will never be possible
	BOOL didFailToFindARouteToTarget;
	
	// A target is an object this unit is set to attack. When path finding, it will stop when it gets in firing range of this object
	ASIMapObject *target;

	// Set to YES when we are moving so we can get our target in range
	BOOL movingToAttackTarget;
	
	// Will be non-zero when we have been forced to move off-course
	// Is also used to delay path assessment if we have previously failed to find a path
	unsigned char offCourseCount;
	
	// This object's path - basically an array of positions that describe where it will travel to next
	// This is populated by an ASISpaceTimePathFinder
	ASIPath *path;
	
	// Set to YES when this object has performed path finding
	// Used by this objects team to help sort the objects in the best path finding order
	BOOL havePerformedPathFinding;
	
	// Used as part of canMove
	// Will be YES when this object is involved in a collision resolution
	BOOL isAskingToMove;
	
	// Records whether this object has moved this frame or not
	// Used for resolving unanticipated collisions 
	BOOL haveMoved;
	
	// A unique id for this object. Only really used for drawing the object in the Mac sample app
	unsigned short tag;
}

// Our speed, where 1 = Fastest (We can move 1 position in a single move)
// If our speed is 3, we will take 3 moves to move one position
- (unsigned char)speed;

// Called to perform path assessment and path finding
- (void)performPathFinding;

// Returns YES if the passed object is in our line of fire
- (BOOL)isObjectWithinLineOfFire:(ASIMapObject *)object;

// As above, but based on if we were at a particular position
- (BOOL)isObjectWithinLineOfFire:(ASIMapObject *)object ifWeWereAt:(Position3D)newPosition;

// Actually move this object
- (void)move;

// Returns YES if we are able to perform our next move
// Returns NO if an object is unexpectedly in our way
- (BOOL)canMove;

@property (retain, nonatomic) ASITeam *team;
@property (assign, nonatomic) Position3D destination;
@property (retain, nonatomic) ASISpatialPathAssessor *pathAssessment;
@property (retain, nonatomic) ASIMapObject *target;
@property (retain, nonatomic) ASIPath *path;
@property (assign, nonatomic) BOOL havePerformedPathFinding;
@property (assign, nonatomic) BOOL isAskingToMove;
@property (assign, nonatomic) BOOL haveMoved;
@property (assign, nonatomic) unsigned short tag;
@end
