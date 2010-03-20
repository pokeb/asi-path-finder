//
//  SpatialPathAssessor.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASISpatialPathAssessor.h"
#import "ASIWorldMap.h"
#import "ASIUnit.h"
#import "ASIPath.h"
#import "ASIObjectMap.h"
#import "ASISearchNodeList.h"

@implementation ASISpatialPathAssessor

#define MAX_NODES_TO_ASSESS_PER_STEP 75

- (id)initWithMap:(ASIWorldMap *)newMap
{
	self = [super init];
	[self setMap:newMap];
	
	Size3D size = [map mapSize];
	int count = size.xSize*size.ySize;
	if ((positions = calloc(count,sizeof(float))) == NULL) {
		NSLog(@"Out of memory");
		return nil;
	}
	return self;
}

- (void)reset
{
	[self setNodeList:nil];
	failedToFindRoute = NO;
	haveFinishedAssessingPath = NO;
	Size3D size = [map mapSize];
	int count = size.xSize*size.ySize;
	memset(positions, 0, sizeof(float)*count);
	
}



- (void)assessPathFrom:(Position3D)newOrigin to:(Position3D)newDestination
{
	// If we're assessing a path between the same positions, stop
	if (EqualPositions(newOrigin, newDestination)) {
		haveFinishedAssessingPath = YES;
		return;
	}
	
	// Have we already started finding a path? If so, let's resume path finding
	if (nodeList) {
		[self resumeSearch];
		return;
	}
	
	
	[self setNodeList:[[[ASISearchNodeList alloc] init] autorelease]];
	[self setOrigin:newOrigin];
	[self setDestination:newDestination];
	
	// This will be our starting point node
	Node node;
	node.position = newOrigin;
	node.cost = 0;
	node.time = 0;
	node.distance = 0;
	node.parentNode = NULL;
	[nodeList addNode:&node];
	
	[self resumeSearch];
	
}
	
- (void)resumeSearch
{
	Size3D size = [map mapSize];
	BOOL foundPath = NO;
	int x,y;
	
	Position3D position;
	
	ASIMapObject *mapObject;
	float distance;
	float cost;
	Node node;
	
	char searchDirection;
	
	// Search Z represents the 'z' position on the map that we want to search in while finding a path
	// It is hard coded here to 0, but if you have a 3D map, you might want to use another number for path finding on a plane above the ground
	signed char searchZ = 0;
	
	unsigned int assessedNodeCount = 0;
	unsigned int maxSearchNodes = MAX_NODES_TO_ASSESS_PER_STEP;
	
	while ([nodeList length]) {
		
		// Have we asssessed more nodes than our maximum for this pass?
		assessedNodeCount++;
		if (assessedNodeCount == maxSearchNodes) {
			// Yes, stop path finding, we can resume later
			break;
		}
		
		// Grab the best node to look at next from the list
		node = *[nodeList firstNode];
		[nodeList removeFirstNode];
		
		searchDirection = -1;

		for (x=-1; x<2; x++) {
			for (y=-1; y<2; y++) {
				if (x != 0 || y != 0) {
					
					// Change direction - this is used for making sure we aren't cutting corners, and to make travelling diagaonally more expensive
					// Values for search direction are defined in ASIPathSearchDataTypes.h
					searchDirection++;			
					
					// Create a new position to represent the place we are searching
					position = Position3DMake(node.position.x+x,node.position.y+y,searchZ);

					// Are we out of bounds?
					if (position.x < 0 || position.x > size.xSize-1 || position.y < 0 || position.y > size.ySize-1) {
						continue;
					}
					
					// Have we looked at this position already?
					if (positions[position.x+(position.y*size.xSize)]) {
						
						// If we are resuming a search because we are off course, and have already assessed this node, let's stop
						if (shouldPerformOffCourseAssessment) {
							foundPath = YES;
							break;
						} else {
							continue;
						}
					}
					
					// By default, the cost of travelling to this node will be 1 more than the cost of travelling to its parent node
					// Objects we pass through may increase this cost
					cost = node.cost+1;	

					mapObject = [map objectAtPosition:position];
					// Is there an object at this position already?
					if (mapObject) {
						
						// Ask the object if we can pass through it, and, if so, how much extra will it cost us to do so
						// Why would we want to allowing objects to travel through others at an increased cost?
						// An example: To allow objects that can attack to find a path _through_ enemy walls.
						// If the cost is increased to account for the fact that they'll have to destroy the walls on the way, it may be faster for an object to destroy an obstacle rather than go around it
						if (![mapObject isPassableByObject:object movingNow:NO atPosition:&position fromPosition:&node.position withCost:&cost andDistance:&distance]) {
							continue;
						}
					}
					
					if (searchZ == 0) {

						
						// Stop paths hugging corners
						// This basically is used to prevent objects appearing to walk through the corner of another object
						// Certain objects may allow this - they'll return YES to allowsCornerCutting
						switch (searchDirection) {
							case PathDirectionNorth:
								mapObject = [map objectAtPosition:Position3DMake(node.position.x-1,node.position.y,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								mapObject = [map objectAtPosition:Position3DMake(node.position.x,node.position.y-1,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								break;
							case PathDirectionWest:
								mapObject = [map objectAtPosition:Position3DMake(node.position.x-1,node.position.y,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								mapObject = [map objectAtPosition:Position3DMake(node.position.x,node.position.y+1,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								break;
							case PathDirectionEast:
								mapObject = [map objectAtPosition:Position3DMake(node.position.x+1,node.position.y,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								mapObject = [map objectAtPosition:Position3DMake(node.position.x,node.position.y-1,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								break;
							case PathDirectionSouth:
								mapObject = [map objectAtPosition:Position3DMake(node.position.x+1,node.position.y,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								mapObject = [map objectAtPosition:Position3DMake(node.position.x,node.position.y+1,0)];
								if (mapObject && ![mapObject allowsCornerCutting]) {
									continue;
								}
								break;
							default:
								cost -= 0.25;
						}
							
					}

					
					// If we get here, this node is a valid move, and we need to add it to the search list so we can look at where to go next from this position
					
					// Get a crow-files distance between here and our destination
					distance = DistanceBetweenPositions(position, destination);				
					
					// Record the cost it will take to get here via the route we've taken
					positions[position.x+(position.y*size.xSize)] = cost;

					// Create a node we can add to the search list
					Node n;
					n.cost = cost;
					n.distance = distance;
					n.position = position;
					n.time = 0;
					n.direction = searchDirection;
					n.parentNode = &node;
					
					// Add the node to the search list
					[nodeList addNode:&n];
				
					// If we've arrived at our destination, stop
					if (EqualPositions(position, destination)) {
						foundPath = YES;
						break;
					}
							
				}
			}
			if (foundPath) {
				break;
			}
		}
		if (foundPath) {
			break;
		}

	}
	if (assessedNodeCount == maxSearchNodes) {
		// We had to stop path finding because we looked at more nodes than the maximum per cycle
		// We can resume this search later
	} else {
		// We finished path finding
		haveFinishedAssessingPath = YES;
		
		// Clear the search list - we no longer need it
		[self setNodeList:nil];
		
		// Set failedToFindRoute to YES if we ran out of nodes to look at
		failedToFindRoute = !foundPath;
	}
}


- (float)realDistanceFromDestination:(Position3D)position
{
	return positions[position.x+(position.y*[map mapSize].xSize)];
}

- (BOOL)haveAssessed:(Position3D)position
{
	return (BOOL)positions[position.x+(position.y*[map mapSize].xSize)];
}

- (void)dealloc
{
	[nodeList release];
	free(positions);
	[super dealloc];
}


@synthesize origin;
@synthesize destination;
@synthesize map;
@synthesize object;
@synthesize failedToFindRoute;
@synthesize haveFinishedAssessingPath;
@synthesize shouldPerformOffCourseAssessment;
@synthesize nodeList;
@end
