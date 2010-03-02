//
//  ASISpaceTimeMap.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 15/06/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASISpaceTimeMap.h"
#import "ASIPathSearchDataTypes.h"

@implementation ASISpaceTimeMap

- (id)initWithSize:(CGSize)newSize timeSpan:(int)newTimeSpan
{
	self = [super initWithMapSize:Size3DMake(newSize.width, newSize.height, newTimeSpan)];
	return self;
}

- (int)timeSpan
{
	return mapSize.zSize;
}

- (void)setTimeSpan:(int)newTSize
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
	int copyLength = xByY*timePointer;
	memset(grid+copyLength, 0, 2*xByY*sizeof(id));
	
	timePointer+=2;
	if (timePointer == mapSize.zSize) {
		timePointer = 0;
	}
	gameTime+=2;
}

- (id)objectAtPosition:(CGPoint)position time:(int)time
{
	return [super objectAtPosition:Position3DMake(position.x, position.y, time)];
}

- (void)setObject:(id)object atPosition:(CGPoint)position time:(int)time
{
	[super setObject:object atPosition:Position3DMake(position.x, position.y, time)];
}

- (void)setObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(int)time
{
	int t = time;
	int i=0;
	while (i < mapSize.zSize-time) {
		[super setObject:object atPosition:Position3DMake(position.x, position.y, t)];
		i++;
		t++;
	}
}


- (void)removeObject:(id)object atPositionIndefinitely:(CGPoint)position fromTime:(int)time
{
	int t = time;
	
	int i=0;
	while (i < mapSize.zSize-time) {
		[super removeObject:object atPosition:Position3DMake(position.x, position.y, t)];
		i++;
		t++;
	}
}

- (NSString *)description
{
	return [self printMapForTime:0];
}

- (NSString *)printMapForTime:(int)time
{
	NSString *s = @"\r\n  ";
	NSString *cost;
	int x,y;
	NSString *xPos, *yPos;
	NSString *line = @"  -";
	for (x=0; x<mapSize.xSize; x++) {
		line = [NSString stringWithFormat:@"%@---",line];
		
		xPos = [NSString stringWithFormat:@"%hi",x];
		if ([xPos length] == 1) {
			xPos = [NSString stringWithFormat:@"0%@",xPos];
		}
		s = [NSString stringWithFormat:@"%@ %@",s,xPos];
	}
	line = [NSString stringWithFormat:@"%@\r\n",line];
	s = [NSString stringWithFormat:@"%@\r\n%@",s,line];
	for (y=0; y<mapSize.ySize; y++) {
		
		yPos = [NSString stringWithFormat:@"%hi",y];
		if ([yPos length] == 1) {
			yPos = [NSString stringWithFormat:@"0%@",yPos];
		}
		s = [NSString stringWithFormat:@"%@%@|",s,yPos];

		for (x=0; x<mapSize.xSize; x++) {
			
			cost = [NSString stringWithFormat:@"%hi",[[self objectAtPosition:CGPointMake(x,y) time:time] tag]];
			if ([cost length] == 1) {
				cost = [NSString stringWithFormat:@"0%@",cost];
			}
			if ([cost isEqualToString:@"00"]) {
				cost = @"  ";
			}
			s = [NSString stringWithFormat:@"%@%@|",s,cost];
		}
		s = [NSString stringWithFormat:@"%@\r\n%@",s,line];
	}
	return s;
}

@synthesize timePointer;
@synthesize gameTime;
@end
