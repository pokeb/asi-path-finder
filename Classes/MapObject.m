//
//  MapObject.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "MapObject.h"
#import "ASIWorldMap.h"

@implementation MapObject

- (id)initWithMap:(ASIWorldMap *)newMap
{
	self = [super init];
	[self setMap:newMap];
	[self setPosition:InvalidPosition];
	return self;
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
