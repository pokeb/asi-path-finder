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
#import "ASIMoveableObject.h"
#import "ASIPath.h"
#import "ASISpaceTimeMap.h"
#import "ASISearchNodeList.h"

static BOOL *searchedPositions = NULL;
static unsigned int lastMapSize = 0;
static char positions[3] = {0,-1,1};

@implementation ASISpaceTimePathFinder

static unsigned char searchDirections[8] = {PathDirectionNorthEast,PathDirectionSouthWest,PathDirectionNorthWest,PathDirectionNorth,PathDirectionWest,PathDirectionSouthEast,PathDirectionEast,PathDirectionSouth};

- (id)initWithObject:(ASIMoveableObject *)newObject;
{
	self = [super init];
	[self setObject:newObject];
	return self;
}

- (ASIPath *)findPath
{
	ASIWorldMap *map = [object map];
	ASISpaceTimeMap *spaceTimeMap = [map spaceTimeMap];
	ASISpatialPathAssessor *spatialPathAssessor = [object pathAssessment];
	int timeSize = [spaceTimeMap timeSpan];
	Size3D size = [map mapSize];	
	int sizeXByY = size.xSize*size.ySize;

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
	int speed = [object speed];
	
	Position3D origin = [object position];


	Position3D destination = [object destination];
	if (attemptToStayInSameLocation) {
		destination = origin;
	}
	int i;
	for (i=0; i<speed; i++) {
		[spaceTimeMap setObject:object atPosition:Position3DMake(origin.x,origin.y,i)];
	}
	ASISearchNodeList *nodeList = [[ASISearchNodeList alloc] init];

	
	
	Node *node = nodeAlloc();
	node->time = 0;
	

	node->position = origin;
	node->distance = [spatialPathAssessor realDistanceFromDestination:origin];
	[nodeList addNode:node];

	int x,y;
	
	Position3D position;
	Position3D nodePosition;
	MapObject *mapObject;
	float distance;
	float cost;
	unsigned char time;
	unsigned char searchDirection;
	char directionCounter;
	int searched = 0;
	int costPos;
	Node *nearestNodeSoFar = NULL;
	
	MapObject *objectAtPosition = nil;
	
	BOOL atDestination;
	BOOL canStayHere;
	BOOL shouldStop = NO;
	


	signed char searchZ = 0;
	
	int xPos, yPos;

	while ([nodeList length]) {
		
		node = nodeAlloc();
		*node = *[nodeList firstNode];
		[nodeList removeFirstNode];
		
		if (node->time > timeSize-speed) {
			continue;
		}
		time = node->time+speed;
		searched++;
		

		nodePosition = node->position;
		//NSLog(@"%hi,%hi",nodePosition.x,nodePosition.y);
		directionCounter = -1;
		
		// We need to look at position (0,0) first, as a lot of the time we need to stay still
		for (xPos = 0; xPos<3; xPos++) {
			for (yPos=0; yPos<3; yPos++) {
				
				x = positions[xPos];
				y = positions[yPos];
				//NSLog(@"%hi,%hi",x,y);
					
				position = Position3DMake(nodePosition.x+x,nodePosition.y+y,searchZ);
				
				if (x != 0 || y != 0) {
					directionCounter++;
					searchDirection = searchDirections[directionCounter];
				}
				
				// Have we searched this node at the same cost already?
				costPos = position.x+(position.y*size.xSize)+(sizeXByY*time);
				if (searchedPositions[costPos]) {
					//NSLog(@"Already looked in (%hi,%hi) cost: %hi",position.x,position.y,[node cost]+1);
					continue;
				}
				

				// Are we out of bounds?
				if (position.x < 0 || position.x > size.xSize-1 || position.y < 0 || position.y > size.ySize-1) {
					continue;
				}
				
				if (x==0 && y==0) {
					cost = node->cost;
				} else {
					cost = node->cost+1;
				}
	
				
				//Look for a building at this point
				mapObject = [map objectAtPosition:position];
				if (mapObject) {
					if (![mapObject isKindOfClass:[ASIMoveableObject class]]) {
						continue;
					} else if (mapObject != object) {
						if (![(ASIMoveableObject *)mapObject willMoveForUnit:object]) {
							continue;
						} else {
							cost += 3;
						}
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
				
				
				searchedPositions[costPos] = YES;
				
				
				int i = 0;

				
				objectAtPosition = [spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,time+i)];
				if (objectAtPosition && objectAtPosition != object) {
					//NSLog(@"Can't go to (%hi,%hi)",position.x,position.y);
					//found = YES;
					continue;
				} else {
					objectAtPosition =[spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,node->time+i)];

		
					//
					if (objectAtPosition && objectAtPosition != object && objectAtPosition == [spaceTimeMap objectAtPosition:Position3DMake(node->position.x,node->position.y,time+i)]) {
						//NSLog(@"Can't go to (%hi,%hi) because the object there is about to move here",position.x,position.y);
						//found = YES;
						continue;
					}
				}
	
				


				atDestination = NO;
				if (stopWhenWithinRangeOfTarget && [object isObjectWithinLineOfFire:[object target] ifWeWereAt:position]) {
					distance = 0;
					cost = node->cost;
					atDestination  = YES;
					if (time == timeSize) {
						shouldStop = YES;
					}
				} else if (EqualPositions(position, destination)) {
					distance = 0;
					cost = node->cost;
					atDestination  = YES;
				} else {

					
					distance = [spatialPathAssessor realDistanceFromDestination:position];
					//Make sure the spatial assessor looked at this node
					if (distance == 0) {
						
						// If not, we'll just add one to the current node distance, which should be accurate enough for most purposes
						distance = node->distance+1;
					}
					
					
					if (searchDirection != node->direction && !EqualPositions(node->position, InvalidPosition)) {
						cost +=0.25f;
					}
					
					
					//i = [nodeList positionToAddNodeWithDistance:distance cost:cost position:position checkingSamePosition:YES];
				}
				
				Node *n = nodeAlloc();
				n->parentNode = node;
				n->position = position;
				n->distance = distance;
				n->cost = cost;
				n->time = time;
				n->direction = searchDirection;
				[nodeList addNode:n];
				canStayHere = NO;
				//NSLog(@"%u",[nodeList length]);
				
				if (atDestination || (time == timeSize && (!nearestNodeSoFar || distance < nearestNodeSoFar->distance))) {
					//if (!nearestNodeSoFar || (distance < nearestNodeSoFar->distance) || (distance == nearestNodeSoFar->distance && x==0 && y==0)) {
					//if (!nearestNodeSoFar || ([n distance] <= [nearestNodeSoFar distance])) {
					canStayHere = YES;
					for (i=time; i< timeSize; i++) {
						objectAtPosition = [spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,i)];
						//NSLog(@"Looking at %hi,%hi for time %hi",position.x,position.y,i);
						if (objectAtPosition && objectAtPosition != object) {
							canStayHere = NO;
							break;
						}
						if (speed == 2) {
							objectAtPosition = [spaceTimeMap objectAtPosition:Position3DMake(position.x,position.y,i+1)];
						}
						if (objectAtPosition && objectAtPosition != object) {
							canStayHere = NO;
							break;
						}
					}
					if (canStayHere) {
						nearestNodeSoFar = n;	
						//if (atDestination) {
							shouldStop = YES;
						//}
					}
					//}
				//} else {
				//	nearestNodeSoFar = n;
				}
				
				if (!canStayHere) {
					shouldStop = NO;
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
		freeNodes();
		[nodeList release];
		//NSLog(@"Fail %@",object);
		//NSLog(@"%@",[[[map playerTeam] spaceTimeMap] printMapForTime:0]);
		return nil;		
	}
	node = nearestNodeSoFar;

	Position3D p = node->position;
	
	[spaceTimeMap setObject:object atPositionIndefinitely:CGPointMake(p.x,p.y) fromTime:node->time];

	int endTime = node->time;
	Position3D endPosition = node->position;
	
	ASIPath *path = [[[ASIPath alloc] initWithInitialSize:timeSize+1] autorelease];

	while (node->parentNode && node->parentNode != node) {
		
		[path insertNodeAtStart:node->position];

		if (speed == 2) {
			[spaceTimeMap setObject:object atPosition:Position3DMake(p.x,p.y,node->time-1)];
			[spaceTimeMap setObject:object atPosition:Position3DMake(p.x,p.y,node->time)];
		} else {
			[spaceTimeMap setObject:object atPosition:Position3DMake(p.x,p.y,node->time)];
		}
		
		node = node->parentNode;
		p = node->position;
	}
	
	for (i=endTime+1; i<=timeSize; i++) {
		[spaceTimeMap setObject:object atPosition:Position3DMake(endPosition.x,endPosition.y,i)];
		
		//[path addNode:endPosition];
	}

	//NSLog(@"Searched %hi",searched);
	if (stopWhenWithinRangeOfTarget > 0 && [object isObjectWithinLineOfFire:[object target] ifWeWereAt:nearestNodeSoFar->position]) {
		[object setDestination:nearestNodeSoFar->position];
	}
	//NSLog(@"%@",path);
	freeNodes();
	[nodeList release];
	return path;

}



@synthesize object;
@synthesize stopWhenWithinRangeOfTarget;
@synthesize attemptToStayInSameLocation;
@end
