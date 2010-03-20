//
//  ASIPathSearchDataTypes.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIPathSearchDataTypes.h"
#import "ASIMapObject.h"

static Node **nodeList = NULL;
static unsigned int allocatedNodeCount = 0;
static unsigned int allocatedSpaceForNodes = 0;

inline struct Node *nodeAlloc(void)
{
	Node *n = (struct Node *) malloc(sizeof(struct Node));
	n->cost = 0;
	n->distance = 0;
	n->position = InvalidPosition;
	n->time = 0;
	n->direction = 0;
	n->parentNode = NULL;
	
	// Now store a reference to the node in the list so we can free it later
	if (!allocatedSpaceForNodes) {
		allocatedSpaceForNodes = 20;
		nodeList = malloc(sizeof(Node *)*allocatedSpaceForNodes);
	} else if (allocatedNodeCount == allocatedSpaceForNodes ) {
		allocatedSpaceForNodes *= 2;
		nodeList = realloc(nodeList, sizeof(Node *)*allocatedSpaceForNodes);
	}
	
	Node **pos = nodeList+allocatedNodeCount;
	*pos = n;
	allocatedNodeCount++;
	return n;
}



inline void freeNodes() {
	Node **pos = nodeList;
	unsigned int i;
	for (i=0; i<allocatedNodeCount; i++) {
		Node *n = *pos;
		free(n);
		pos++;
	}
	free(nodeList);
	nodeList = nil;
	allocatedNodeCount = 0;
	allocatedSpaceForNodes = 0;
}

inline Position3D Position3DMake(int x, int y, int z)
{
	Position3D p = {x,y,z};
	return p;
}

inline Size3D Size3DMake(int xSize, int ySize, int zSize)
{
	Size3D p = {xSize,ySize,zSize};
	return p;
}

inline BOOL EqualPositions(Position3D position1,Position3D position2)
{
	return (position1.x == position2.x && position1.y == position2.y && position1.z == position2.z);
}

inline float DistanceBetweenPositions(Position3D position1, Position3D position2)
{
	// Simpler approach, probably faster
	//return abs(position1.x-position2.x)+abs(position1.y-position2.y);
	
	// Much more accurate, necessary for firing line calculations
	return (float)sqrt((position1.x-position2.x)*(position1.x-position2.x) + (position1.y-position2.y)*(position1.y-position2.y)); 	
}

inline NSString *StringFromPosition3D(Position3D position)
{
	return [NSString stringWithFormat:@"%hi,%hi,%hi",position.x,position.y,position.z];
}
inline Position3D Position3DFromString(NSString *string)
{
	NSArray *components = [string componentsSeparatedByString:@","];
	return Position3DMake([[components objectAtIndex:0] intValue], [[components objectAtIndex:1] intValue], [[components objectAtIndex:2] intValue]);
}

inline NSString *StringFromSize3D(Size3D size)
{
	return [NSString stringWithFormat:@"%hi,%hi,%hi",size.xSize,size.ySize,size.zSize];
}
inline Size3D Size3DFromString(NSString *string)
{
	NSArray *components = [string componentsSeparatedByString:@","];
	return Size3DMake([[components objectAtIndex:0] intValue], [[components objectAtIndex:1] intValue], [[components objectAtIndex:2] intValue]);
}

inline NSInteger sortByDistance(id obj1, id obj2, void *fromPos)
{
	float distance1 = DistanceBetweenPositions([(ASIMapObject *)obj1 position], [(ASIMapObject *)fromPos position]);
	float distance2 = DistanceBetweenPositions([(ASIMapObject *)obj2 position], [(ASIMapObject *)fromPos position]);
	if (distance1 < distance2) {
		return NSOrderedAscending;
	} else if (distance1 > distance2) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

Position3D InvalidPosition = {-1, -1, -1};
