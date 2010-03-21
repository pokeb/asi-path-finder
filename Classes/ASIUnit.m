//
//  ASIUnit.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIUnit.h"
#import "ASISpatialPathAssessor.h"
#import "ASISpaceTimePathFinder.h"
#import "ASIPath.h"

static unsigned short nextTag = 0;

@implementation ASIUnit

- (id)initWithMap:(ASIWorldMap *)newMap
{
	self = [super initWithMap:newMap];
	[self setDestination:InvalidPosition];
	
	nextTag++;
	[self setTag:nextTag];
	return self;
}

- (BOOL)allowsCornerCutting
{
	return YES;
}


- (void)performPathFinding
{
	// If we haven't done path finding before, create a path assessor
	if (!pathAssessment) {
		[self setPathAssessment:[[[ASISpatialPathAssessor alloc] initWithMap:map] autorelease]];
		[pathAssessment setObject:self];	
	}
	
	// This little hack alternates the destination between current pos and target pos
	// It basically allows us to remain in one place when we're in range of the target
	// But try to move to another position that's in range of the target if we need to if another object wants this square
	if (target) {
		
		if ([self isObjectWithinLineOfFire:target]) {
			destination = position;
			movingToAttackTarget = NO;
		} else {
			if (!EqualPositions(destination, [target position])) {
				destination = [target position];
				[pathAssessment reset];
			}
			movingToAttackTarget = YES;
		}
	}
	
	// If we didn't finish assessing the path last time around, we need to resume path assessment
	if (![pathAssessment haveFinishedAssessingPath]) {
		[pathAssessment assessPathFrom:destination to:position];	
		offCourseCount = 0;
		didFailToFindARouteToTarget = [pathAssessment failedToFindRoute];
		
	// If we didn't find a route to the target, let's stay where we are for now
	} else if (didFailToFindARouteToTarget) {
		offCourseCount++;
		
		// After 5 planning steps, we'll try to find a path again
		if (offCourseCount == 5) {
			offCourseCount = 0;
			didFailToFindARouteToTarget = NO;
		}
		
	// We have been blown off course, so we need to perform path assessment to get us back on track
	} else if (!EqualPositions(position, destination) && ![pathAssessment haveAssessed:position]) {
		offCourseCount++;
		if (offCourseCount == 3) {
			[pathAssessment reset];
			offCourseCount = 0;	
		} else {
			[pathAssessment setShouldPerformOffCourseAssessment:YES];
		}
		[pathAssessment assessPathFrom:destination to:position];
		didFailToFindARouteToTarget = [pathAssessment failedToFindRoute];
	}

	
	ASISpaceTimePathFinder *pathFinder = [[[ASISpaceTimePathFinder alloc] initWithObject:self] autorelease];
	if (movingToAttackTarget) {
		[pathFinder setStopWhenWithinRangeOfTarget:5];
	}
	[pathFinder setAttemptToStayInSameLocation:(didFailToFindARouteToTarget || ![pathAssessment haveFinishedAssessingPath])];
	
	[pathFinder findPath];
	havePerformedPathFinding = YES;
}

- (void)setDestination:(Position3D)newDestination
{
	destination = newDestination;
	[self setPathAssessment:nil];
}

- (unsigned char)speed
{
	return 1;
}

- (BOOL)isObjectWithinLineOfFire:(ASIMapObject *)object
{
	return [self isObjectWithinLineOfFire:object ifWeWereAt:[self position]];
}

- (BOOL)isObjectWithinLineOfFire:(ASIMapObject *)object ifWeWereAt:(Position3D)newPosition
{
	if (DistanceBetweenPositions(position, newPosition) < 5) {
		return YES;
	}
	return NO;
}

- (void)stop
{
	[self setPath:nil];
}

- (BOOL)canMove
{
	BOOL canMove = NO;
	isAskingToMove = YES;
	Position3D newPosition = [[self path] firstNode];
	ASIMapObject *objectInTheWay = [[self map] objectAtPosition:newPosition];
	if (!objectInTheWay) {
		canMove = YES;
	} else if (![objectInTheWay isKindOfClass:[ASIUnit class]]) {
		canMove = NO;
	} else if ([(ASIUnit *)objectInTheWay isAskingToMove]) {
		canMove = YES;
	} else if ([(ASIUnit *)objectInTheWay haveMoved] || ![[(ASIUnit *)objectInTheWay path] length] || EqualPositions([[(ASIUnit *)objectInTheWay path] firstNode], newPosition)) {
		canMove = NO;
	} else {
		canMove = [(ASIUnit *)objectInTheWay canMove];
	}
	isAskingToMove = NO;
	return canMove;

}

- (void)move
{
	if ([[self path] length]) {
		if (![self canMove]) {
			[self stop];
		} else {
			
			Position3D newPosition = [[self path] firstNode];
			[self setPosition:newPosition];
			[[self path] removeFirstNode];
		}
	}
	[self setHaveMoved:YES];
}

// This object won't nescessarily be in this position forever, so we'll allow other objects to pass through it
- (BOOL)isPassableByObject:(ASIMapObject *)mapObject movingNow:(BOOL)aboutToMove atPosition:(Position3D *)myPosition fromPosition:(Position3D *)theirPosition withCost:(float *)cost andDistance:(float *)distance
{
	return YES;
}

@synthesize team;
@synthesize destination;
@synthesize pathAssessment;
@synthesize target;
@synthesize path;
@synthesize havePerformedPathFinding;
@synthesize isAskingToMove;
@synthesize haveMoved;
@synthesize tag;
@end
