//
//  ASISpaceTimePathFinder.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASISpaceTimePathFinder.h"
#import "ASISpatialPathAssessor.h"
#import "ASIWorldMap.h"
#import "ASIUnit.h"
#import "ASIPath.h"
#import "ASISpaceTimeMap.h"
#import "ASISearchNodeList.h"
#import "ASITeam.h"

// Since only one object ever plans at once, we store the list of positions we've already looked at in a static array
// If you were threading path finding (which I would strongly advise against) you need to allocate storage for this differently
static BOOL *searchedPositions = NULL;
static unsigned int lastMapSize = 0;

// Controls the order in which we'll search positions
// This basically means we search our current position first (since a great deal of the time, we're actually path finding to stay still!)
static char positions[3] = {0,-1,1};

@implementation ASISpaceTimePathFinder

static unsigned char searchDirections[8] = {PathDirectionNorthEast,PathDirectionSouthWest,PathDirectionNorthWest,PathDirectionNorth,PathDirectionWest,PathDirectionSouthEast,PathDirectionEast,PathDirectionSouth};

- (id)initWithObject:(ASIUnit *)newObject;
{
	self = [super init];
	[self setObject:newObject];
	return self;
}

- (ASIPath *)findPath
{
	ASIWorldMap *map = [object map];
	ASISpaceTimeMap *spaceTimeMap = [[object team] spaceTimeMap];
	int timeSize = [spaceTimeMap timeSpan];
	
	// If the object is planning part way through the pre-calculated timespan, we need to remove its current path
	unsigned char currentTimeStep = [spaceTimeMap currentTimeStep];
	if (currentTimeStep) {
		while ([[object path] length]) {
			Position3D pos = [[object path] firstNode];
			[spaceTimeMap removeObject:object atPositionIndefinitely:CGPointMake(pos.x,pos.y) fromTime:currentTimeStep];
			[[object path] removeFirstNode];
		}
	}
	
	// Clear the object's path
	ASIPath *path = [object path];
	if (!path) {
		[object setPath:[[[ASIPath alloc] initWithPathSize:timeSize] autorelease]];
		path = [object path];
	} else {
		[path clear];
	}	
	
	Size3D size = [map mapSize];	
	int sizeXByY = size.xSize*size.ySize;
	ASISpatialPathAssessor *spatialPathAssessor = [object pathAssessment];

	// Allocate storage for a map of positions we've already looked at, if we haven't already, or we're path finding on a different sized map
	unsigned int mapSize = sizeXByY*(timeSize+1);
	if (!searchedPositions || lastMapSize != mapSize) {
		if (searchedPositions) {
			free(searchedPositions);
		}
		if ((searchedPositions = (BOOL *)calloc(mapSize,sizeof(BOOL))) == NULL ) {
			NSLog(@"Out of memory!!!");
			return nil;
		}
		lastMapSize = mapSize;
	} else {
		memset(searchedPositions, 0, mapSize);
	}
	
	// An object's speed governs how many time steps it needs to move from one position to another
	// An object with a speed of 1 moves in a single time step, while a speed of 2 is half the speed, and takes two time steps to perform the same move
	int speed = [object speed];
	
	
	Position3D origin = [object position];
	Position3D destination = [object destination];
	if (attemptToStayInSameLocation) {
		destination = origin;
	}
	
	// Record our current position, so units don't try to swap positions in a head-on collision
	int i;
	for (i=0; i<speed; i++) {
		[spaceTimeMap setObject:object atPosition:Position3DMake(origin.x,origin.y,currentTimeStep+i)];
	}
	ASISearchNodeList *nodeList = [[ASISearchNodeList alloc] init];

	
	// Create a new node to store our starting position
	Node *node = nodeAlloc();
	node->time = 0;
	node->position = origin;
	node->distance = [spatialPathAssessor realDistanceFromDestination:origin];
	[nodeList addNode:node];

	int x,y;
	
	Position3D position;
	Position3D nodePosition;
	ASIMapObject *mapObject;
	float distance;
	float cost;
	unsigned char time;
	unsigned char searchDirection;
	char directionCounter;
	int searched = 0;
	int costPos;
	Node *nearestNodeSoFar = NULL;
	
	ASIMapObject *objectAtPosition = nil;
	
	BOOL atDestination;
	BOOL canStayHere;
	BOOL shouldStop = NO;

	signed char searchZ = 0;
	
	int xPos, yPos;

	while ([nodeList length]) {
		
		// Grab the first node from the list (it will always be the best node to look at next
		node = nodeAlloc();
		*node = *[nodeList firstNode];
		[nodeList removeFirstNode];
		
		// If we're at the boundary of our time span, we don't need to plan any further from here
		if (node->time > timeSize-speed) {
			continue;
		}
		time = node->time+speed;
		searched++;
		

		nodePosition = node->position;
		directionCounter = -1;
		
		// We need to look at position (0,0) first, as a lot of the time we need to stay still
		for (xPos = 0; xPos<3; xPos++) {
			for (yPos=0; yPos<3; yPos++) {
				
				x = positions[xPos];
				y = positions[yPos];
					
				// Create a position for the place we're looking at
				position = Position3DMake(nodePosition.x+x,nodePosition.y+y,searchZ);
				
				// If we aren't staying still, the direction we're travelling in
				if (x != 0 || y != 0) {
					directionCounter++;
					searchDirection = searchDirections[directionCounter];
				}
				
				// Are we out of bounds?
				if (position.x < 0 || position.x > size.xSize-1 || position.y < 0 || position.y > size.ySize-1) {
					continue;
				}
				
				
				// Have we searched this node already?
				costPos = position.x+(position.y*size.xSize)+(sizeXByY*time);
				if (searchedPositions[costPos]) {
					continue;
				}
			
				// If we're staying still, our cost will be the same as our parent node
				if (x==0 && y==0) {
					cost = node->cost;
				// Otherwise, increase our cost by one
				} else {
					cost = node->cost+1;
				}
	
				
				//Look for a building at this point
				mapObject = [map objectAtPosition:position];
				if (mapObject && mapObject != object) {
					if (![mapObject isPassableByObject:object movingNow:YES atPosition:&position fromPosition:&nodePosition withCost:&cost andDistance:&distance]) {
						continue;
					}
				}

					
				if (x != 0 || y != 0) {	
					//Stop paths hugging corners
					switch (searchDirection) {
						case PathDirectionNorth:
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x-1,nodePosition.y,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x,nodePosition.y-1,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							break;
						case PathDirectionWest:
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x-1,nodePosition.y,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x,nodePosition.y+1,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							break;
						case PathDirectionEast:
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x+1,nodePosition.y,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x,nodePosition.y-1,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							break;
						case PathDirectionSouth:
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x+1,nodePosition.y,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							mapObject = [map objectAtPosition:Position3DMake(nodePosition.x,nodePosition.y+1,0)];
							if (mapObject && ![mapObject allowsCornerCutting]) {
								continue;
							}
							break;
					}
				}
				
				// If we've arrived here, this position is valid to travel to, let's record the cost
				searchedPositions[costPos] = YES;
				
				
				// Now look at the space time map to see if any other units have already reserved this position at this time step
				unsigned int i = 0;
				BOOL positionAlreadyReserved = NO;
				for (i=0; i<speed; i++) {
					objectAtPosition = [spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,time+i)];
					if (objectAtPosition && objectAtPosition != object) {
						// An object has already reserved this position
						positionAlreadyReserved = YES;
						break;
						
					} else {
						objectAtPosition =[spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,node->time+i)];
						if (objectAtPosition && objectAtPosition != object && objectAtPosition == [spaceTimeMap objectAtPosition:Position3DMake(node->position.x,node->position.y,time+i)]) {
							// The object at this position at the last time step is going to move to the space we are currently in.
							// This would be a head-on collision, so we need to ignore this position continue looking
							positionAlreadyReserved = YES;
							break;
						}
					}
				}
				if (positionAlreadyReserved) {
					continue;
				}
		
				


				atDestination = NO;
				
				// If we're moving to attack an object, we don't need to reach the destination - we only need to get within range of it
				if (stopWhenWithinRangeOfTarget && [object isObjectWithinLineOfFire:[object target] ifWeWereAt:position]) {
					
					// This position is within range of the target
					distance = 0;
					cost = node->cost;
					atDestination  = YES;
					if (time == timeSize) {
						shouldStop = YES;
					}
					
				// Have we reached the destination?
				} else if (EqualPositions(position, destination)) {
					distance = 0;
					cost = node->cost;
					atDestination  = YES;
					
					
				} else {

					// Get the distance to the destination from the path assessor
					distance = [spatialPathAssessor realDistanceFromDestination:position];
					
					//Make sure the spatial assessor looked at this node
					if (distance == 0) {
						
						// If not, we'll just add one to the current node distance, which should be accurate enough for most purposes
						distance = node->distance+1;
					}
					
					// Increase the cost slightly if we've had to change direction to get here
					// This stops us zigzagging around
					if (searchDirection != node->direction) {
						cost +=0.25f;
					}
					
				}
				
				// This is valid position to move to at this timestep
				// Add the node to the search list
				Node *n = nodeAlloc();
				n->parentNode = node;
				n->position = position;
				n->distance = distance;
				n->cost = cost;
				n->time = time;
				n->direction = searchDirection;
				[nodeList addNode:n];
				canStayHere = NO;

				
				// If we've arrived at the destination, but are not on the final time step, let's just look forward in time to see if we can stay at this position
				// This means we only need to look at a single node if we're planning to stay still
				if (atDestination && time < timeSize) {

					shouldStop = YES;
					for (i=time; i< timeSize; i++) {
						unsigned int i2;
						for (i2=0; i2<speed; i2++) {
							objectAtPosition = [spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,i+i2)];
							if (objectAtPosition && objectAtPosition != object) {
								atDestination = NO;
								shouldStop = NO;
								break;
							}
						}
						if (!shouldStop) {
							break;
						}
					}
					if (shouldStop) {
						nearestNodeSoFar = n;
					}
					
				// We haven't reached the destination, but we're at the final time step for planning
				// If we are nearer than we've ever been before to the target, make this the nearest node
				} else if ((time == timeSize && (!nearestNodeSoFar || distance < nearestNodeSoFar->distance))) {
					nearestNodeSoFar = n;	
				}
			
				if (shouldStop) {
					break;
				}
				
			}
			if (shouldStop) {
				break;
			}
		}
		if (shouldStop) {
			break;
		}
	}

	if (!nearestNodeSoFar) {
		// We have failed to find any kind of path. This might happen if we're completely hemmed in
		freeNodes();
		[nodeList release];
		return nil;		
	}
	
	// If we get here, we at least have a partial path to the destination, if not a full path
	// We start with the node that we found to be nearest to our destination, and work backwards through its parent nodes to construct a path
	node = nearestNodeSoFar;

	
	
	// Reserve our final position on the space time map
	// If we ended up at this node part way through the time span, we'll reserve this node for the rest of the time span, starting from the time we got here
	[spaceTimeMap setObject:object atPositionIndefinitely:CGPointMake(node->position.x,node->position.y) fromTime:node->time];

	// Now loop through the parent nodes, constructing our path (by adding each parent to the start of the path)
	// and reserving the positions on the space time map
	while (node->parentNode && node->parentNode != node) {
		
		[path insertNodeAtStart:node->position];

		if (speed == 2) {
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time-1)];
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time)];
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time+1)];
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time+2)];
		} else {
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time)];
			[spaceTimeMap setObject:object atPosition:Position3DMake(node->position.x,node->position.y,node->time+1)];
		}
		
		node = node->parentNode;
	}
	
	// If we were moving to attack a target, and we got in range of it, let's set the object's destination to the position we will arrive at
	if (stopWhenWithinRangeOfTarget > 0 && [object isObjectWithinLineOfFire:[object target] ifWeWereAt:nearestNodeSoFar->position]) {
		[object setDestination:nearestNodeSoFar->position];
	}
	
	// free all the nodes we allocated on the heap
	freeNodes();
	
	// Get rid of our search list
	[nodeList release];
	return path;

}



@synthesize object;
@synthesize stopWhenWithinRangeOfTarget;
@synthesize attemptToStayInSameLocation;
@end
