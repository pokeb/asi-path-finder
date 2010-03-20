//
//  ASIMapObject.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIMapObject.h"
#import "ASIWorldMap.h"

@implementation ASIMapObject

- (id)initWithMap:(ASIWorldMap *)newMap
{
	self = [super init];
	[self setMap:newMap];
	[self setPosition:InvalidPosition];
	return self;
}


// By default, objects cannot pass through each other, so we'll return NO
- (BOOL)isPassableByObject:(ASIMapObject *)mapObject movingNow:(BOOL)aboutToMove atPosition:(Position3D *)myPosition fromPosition:(Position3D *)theirPosition withCost:(float *)cost andDistance:(float *)distance
{
	return NO;
}

- (BOOL)allowsCornerCutting
{
	return YES;
}

- (void)setPosition:(Position3D)newPosition
{
	[map removeObject:self];
	position = newPosition;
	[map addObject:self];
}


@synthesize map;
@synthesize position;
@end
