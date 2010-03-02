//
//  ASIObjectMap.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 06/07/2007.
//  Copyright 2007 All-Seeing Interactive. All rights reserved.
//

#import "ASIObjectMap.h"

@implementation ASIObjectMap

- (id)initWithMapSize:(Size3D)newSize
{
	[super init];
	[self setMapSize:newSize];
	
	xByY = newSize.xSize*newSize.ySize;
	int memorySize = xByY*newSize.zSize;
	if (newSize.xSize > 0 && newSize.ySize > 0 && newSize.zSize > 0) {
		grid = calloc(memorySize,sizeof(id));
	}
	return self;
}

- (void)dealloc
{
	free(grid);
	[super dealloc];
}


- (id)objectAtPosition:(Position3D)position
{
	if (position.x >= mapSize.xSize|| position.y >= mapSize.ySize || position.z >= mapSize.zSize) {
		return nil;
	}
	id * pos = grid+position.x+(position.y*mapSize.xSize)+(position.z*xByY);
	if (!*pos) {
		return nil;
	}
	return *pos;
	
}
- (void)setObject:(id)theObject atPosition:(Position3D)position
{
	if (position.x >= mapSize.xSize || position.y >= mapSize.ySize || position.z >= mapSize.zSize) {
		return;
	}

	id *pos = grid+position.x+(position.y*mapSize.xSize)+(position.z*xByY);
	if (*pos != theObject) {
		*pos = theObject;
	}
}

- (void)removeObject:(id)theObject atPosition:(Position3D)position
{
	if (position.x >= mapSize.xSize || position.y >= mapSize.ySize || position.z >= mapSize.zSize) {
		return;
	}
	id * obj = grid+position.x+(position.y*mapSize.xSize)+(position.z*xByY);
	if (*obj == theObject) {
		*obj = nil;
	}
}


- (id *)grid
{
	return grid;
}


@synthesize mapSize;
@end
