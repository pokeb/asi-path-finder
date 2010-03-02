//
//  SpatialPathAssessor.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASISpatialPathAssessor.h"
#import "ASIWorldMap.h"
#import "ASIMoveableObject.h"
#import "ASIPath.h"
#import "ASIObjectMap.h"
#import "ASISearchNodeList.h"

@implementation ASISpatialPathAssessor


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

- (float)realDistanceFromDestination:(Position3D)position
{
	return positions[position.x+(position.y*[map mapSize].xSize)];
}

- (void)assessPathFrom:(Position3D)newOrigin to:(Position3D)newDestination
{
	if (EqualPositions(newOrigin, newDestination)) {
		return;
	}
	
	Size3D size = [map mapSize];

	ASISearchNodeList *nodeList = [[ASISearchNodeList alloc] init];

	[self setOrigin:newOrigin];
	[self setDestination:newDestination];
	
	Node node;
	node.position = newOrigin;
	node.cost = 0;
	node.time = 0;
	node.distance = 0;
	node.parentNode = NULL;
	[nodeList addNode:&node];
	

	BOOL foundPath = NO;
	int x,y;
	
	Position3D position;
	Position3D nodePosition;
	
	MapObject *mapObject;
	float distance;
	float cost;
	float existingCostForThisPosition;
	
	int searched = 0;
	char searchDirection;
	
	signed char searchZ = 0;
	
	
//	BOOL canAttack = ([object attackPowerAgainst:object]);
//	Alliance *alliance = [[object team] alliance];
	
//	SunObject *target = [object target];
//	Position targetPosition = [target position];
	
	//NSLog(@"---");
	
	while ([nodeList length]) {
		
		node = *[nodeList firstNode];
		//NSLog(@"(%hi,%hi) distance: %hu cost: %hu",node.position.x,node.position.y,node.distance,node.cost);
		[nodeList removeFirstNode];
		
		searched++;

		nodePosition = node.position;

		
		searchDirection = -1;

		for (x=-1; x<2; x++) {
			for (y=-1; y<2; y++) {
				if (x != 0 || y != 0) {
					
					searchDirection++;			
					
					position = Position3DMake(nodePosition.x+x,nodePosition.y+y,searchZ);
					

					existingCostForThisPosition = positions[position.x+(position.y*size.xSize)];
					// Are we out of bounds
					if (position.x < 0 || position.x > size.xSize-1 || position.y < 0 || position.y > size.ySize-1 || EqualPositions(origin,position)) {
						continue;
					}
					
					cost = node.cost+1;	

		
					mapObject = [map objectAtPosition:position];
						
					if (mapObject) {
						if (![mapObject isKindOfClass:[ASIMoveableObject class]]) {
							continue;
						} else if (mapObject != object) {
							cost += 6;

						}
					}
					
					if (existingCostForThisPosition > 0 && existingCostForThisPosition < cost) {
						continue;
					}
					
					if (searchZ == 0) {
					

						
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
							default:
								cost -= 0.25;
						}
							
					}

					

					distance = DistanceBetweenPositions(position, destination);				
					
					positions[position.x+(position.y*size.xSize)] = cost;
					//NSLog(@"Cost for position (%hi,%hi) is %f",position.x,position.y,cost);
					Node n;
					n.cost = cost;
					n.distance = distance;
					n.position = position;
					n.time = 0;
					n.direction = searchDirection;
					n.parentNode = &node;
					
					[nodeList addNode:&n];
				
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
	if (!foundPath) {
		failedToFindRoute = YES;
	}
	[nodeList release];
}

- (NSString *)description
{
	NSString *s = @"\r\n  ";
	NSString *cost;
	Size3D size = [map mapSize];
	int x,y;
	NSString *xPos, *yPos;
	NSString *line = @"  -";
	for (x=0; x<size.xSize; x++) {
		line = [NSString stringWithFormat:@"%@---",line];
		
		xPos = [NSString stringWithFormat:@"%hi",x];
		if ([xPos length] == 1) {
			xPos = [NSString stringWithFormat:@"0%@",xPos];
		}
		s = [NSString stringWithFormat:@"%@ %@",s,xPos];
	}
	line = [NSString stringWithFormat:@"%@\r\n",line];
	s = [NSString stringWithFormat:@"%@\r\n%@",s,line];
	for (y=0; y<size.ySize; y++) {
		
		yPos = [NSString stringWithFormat:@"%hi",y];
		if ([yPos length] == 1) {
			yPos = [NSString stringWithFormat:@"0%@",yPos];
		}
		s = [NSString stringWithFormat:@"%@%@|",s,yPos];
		for (x=0; x<size.xSize; x++) {
			cost = [NSString stringWithFormat:@"%hi",positions[x+(y*size.xSize)]];
			if ([cost length] == 1) {
				cost = [NSString stringWithFormat:@"0%@",cost];
			}
			s = [NSString stringWithFormat:@"%@%@|",s,cost];
		}
		s = [NSString stringWithFormat:@"%@\r\n%@",s,line];
	}
	return s;
}

- (BOOL)haveAssessed:(Position3D)position
{
	return (BOOL)positions[position.x+(position.y*[map mapSize].xSize)];
}



- (void)dealloc
{
	free(positions);
	[super dealloc];
}


@synthesize origin;
@synthesize destination;
@synthesize map;
@synthesize object;
@synthesize failedToFindRoute;
@end
