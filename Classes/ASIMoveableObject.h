//
//  ASIMovableObject.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  An example of an object that can move

#import "MapObject.h"

@class ASISpatialPathAssessor;
@class ASIPath;

@interface ASIMoveableObject : MapObject {
	
	// The destination of this object (may be the same as its position if it needs to remain in one place
	Position3D destination;
	
	// 
	ASISpatialPathAssessor *pathAssessment;
	MapObject *target;
	BOOL didFailToFindARouteToTarget;
	BOOL movingToAttackTarget;
	unsigned char offCourseCount;
	ASIPath *path;
	unsigned short tag;
	BOOL havePerformedPathFinding;
	BOOL isAskingToMove;
	BOOL haveMoved;
}
- (BOOL)willMoveForUnit:(ASIMoveableObject *)unit;
- (unsigned char)speed;
- (void)performPathFinding;
- (BOOL)isObjectWithinLineOfFire:(MapObject *)object;
- (BOOL)isObjectWithinLineOfFire:(MapObject *)object ifWeWereAt:(Position3D)newPosition;
- (void)move;

@property (assign, nonatomic) Position3D destination;
@property (retain, nonatomic) ASISpatialPathAssessor *pathAssessment;
@property (retain, nonatomic) MapObject *target;
@property (retain, nonatomic) ASIPath *path;
@property (assign, nonatomic) unsigned short tag;
@property (assign, nonatomic) BOOL havePerformedPathFinding;
@property (assign, nonatomic) BOOL isAskingToMove;
@property (assign, nonatomic) BOOL haveMoved;

@end
