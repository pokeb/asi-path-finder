//
//  ASISpaceTimeMap.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 15/06/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASISpaceTimeMap.h"
#import "ASIPathSearchDataTypes.h"

// Each space time map will start planning at a different time
// As planning happens on a schedule, this will force each individual space time map to plan at a different frame
// So, if you have several teams, each can plan on a different frame, helping balance the cpu load
static unsigned char planStartTime = 0;

@implementation ASISpaceTimeMap

- (id)initWithSize:(CGSize)newSize timeSpan:(unsigned int)newTimeSpan
{
	self = [super initWithMapSize:Size3DMake(newSize.width, newSize.height, newTimeSpan)];
	currentTimeStep = planStartTime;
	planStartTime++;
	if (planStartTime == newTimeSpan) {
		planStartTime = 0;
	}
	return self;
}

- (int)timeSpan
{
	return mapSize.zSize;
}

- (void)setTimeSpan:(unsigned int)newTSize
{
	if (grid) {
		free(grid);
	}
	[self setMapSize:Size3DMake(mapSize.xSize, mapSize.ySize, newTSize)];
	int memorySize = xByY*newTSize;
	if (mapSize.xSize > 0 && mapSize.ySize > 0 && mapSize.zSize > 0) {
		grid = calloc(memorySize,sizeof(id));
	}
}

- (void)clear
{
	if (grid) {
		memset(grid, 0, mapSize.zSize*xByY*sizeof(id));
	}		
}

- (void)incrementTime
{
	currentTimeStep++;
	if (currentTimeStep == mapSize.zSize) {
		currentTimeStep = 0;
		[self clear];
	}
}

- (id)objectAtPosition:(CGPoint)position time:(unsigned int)time
{
	return [super objectAtPosition:Position3DMake(position.x, position.y, time)];
}

- (void)setObject:(id)object atPosition:(CGPoint)position time:(unsigned int)time
{
	[super setObject:object atPosition:Position3DMake(position.x, position.y, time)];
}

- (void)setObject:(id)object atPosition:(CGPoint)position fromTime:(unsigned int)time forTimeSteps:(unsigned int)timeSteps
{
	Position3D startPos = Position3DMake(position.x, position.y, time);
	if (startPos.x >= mapSize.xSize || startPos.y >= mapSize.ySize || startPos.z+(int)timeSteps >= mapSize.zSize) {
		return;
	}
	
	id *pos = grid+startPos.x+(startPos.y*mapSize.xSize)+(startPos.z*xByY);
	unsigned int i;
	for (i=0; i<timeSteps; i++) {
		if (*pos != object) {
			*pos = object;
		}
		pos+=xByY;
	}
}

- (void)removeObject:(id)object atPosition:(CGPoint)position fromTime:(unsigned int)time forTimeSteps:(unsigned int)timeSteps
{
	Position3D startPos = Position3DMake(position.x, position.y, time);
	if (startPos.x >= mapSize.xSize || startPos.y >= mapSize.ySize || startPos.z+(int)timeSteps >= mapSize.zSize) {
		return;
	}
	
	id *pos = grid+startPos.x+(startPos.y*mapSize.xSize)+(startPos.z*xByY);
	unsigned int i;
	for (i=0; i<timeSteps; i++) {
		if (*pos != object) {
			*pos = NULL;
		}
		pos+=xByY;
	}
}

- (void)setObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(unsigned int)time
{
	[self setObject:object atPosition:position fromTime:time forTimeSteps:mapSize.zSize-time];
}


- (void)removeObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(unsigned int)time
{
	[self removeObject:object atPosition:position fromTime:time forTimeSteps:mapSize.zSize-time];
}



@synthesize currentTimeStep;
@synthesize timePointer;
@end
