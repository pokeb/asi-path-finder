//
//  ASIWorldMap.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 28/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIWorldMap.h"
#import "ASIMapObject.h"
#import "ASISpaceTimeMap.h"
#import "ASIUnit.h"

@implementation ASIWorldMap

+ (id)map
{
    return [[[ASIWorldMap alloc] initWithMapSize:Size3DMake(20, 20, 1)] autorelease];
}

- (id)initWithMapSize:(Size3D)newSize
{
	self = [super initWithMapSize:newSize];
	[self setObjects:[NSMutableArray array]];
	[self setTeams:[NSMutableArray array]];
	return self;
}

- (void)addObject:(ASIMapObject *)object
{
	[objects addObject:object];
	[super setObject:object atPosition:[object position]];
}

- (void)removeObject:(ASIMapObject *)object
{
	[super removeObject:object atPosition:[object position]];
	[objects removeObject:object];
}

- (void)removeObjectAtPosition:(Position3D)position
{
	ASIMapObject *object = [self objectAtPosition:position];
	if (object) {
		[self removeObject:object];
	}
}

- (NSArray *)units
{
	NSMutableArray *units = [NSMutableArray array];
	for (ASIMapObject *object in objects) {
		if ([object isKindOfClass:[ASIUnit class]]) {
			[units addObject:object];
		}
	}
	return units;
}


@synthesize objects;
@synthesize teams;
@end
