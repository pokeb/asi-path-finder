//
//  ASITeam.m
//  ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASITeam.h"
#import "ASIPathSearchDataTypes.h"
#import "ASIUnit.h"
#import "ASISpaceTimeMap.h"
#import "ASIPath.h"

@implementation ASITeam

- (id)initWithMap:(ASIWorldMap *)newMap
{
	self = [super init];
	[self setMap:newMap];
	[self setUnits:[NSMutableArray array]];
	[self setSpaceTimeMap:[[[ASISpaceTimeMap alloc] initWithSize:CGSizeMake(20, 20) timeSpan:20] autorelease]];
	return self;
}

- (void)performPathFinding
{
	ASIUnit *firstUnit;
	unsigned int totalUnits = [units count];
	int originalPlanUnit;
	
	[spaceTimeMap incrementTime];
	if ([spaceTimeMap currentTimeStep] == 0) {
		
		for (ASIUnit *unit in units) {
			[unit setHavePerformedPathFinding:NO];
			[unit setHaveMoved:NO];
		}
		planUnit++;
		
		if (planUnit > totalUnits-1) {
			planUnit = 0;
		}
		originalPlanUnit = planUnit;
		
		firstUnit = [units objectAtIndex:planUnit];
		
		// This makes stuck units move quicker, at the expense of some correctness
		// Basically, if there are *any* objects that want to move, one of these will take priority over any objects that want to stay still
		// So, we first check to see if a unit wants to move
		// If not, we ask the next unit, until we either find one that does, or we run out of units
		while (EqualPositions([firstUnit position], [firstUnit destination])) {
			planUnit++;
			if (planUnit > totalUnits-1) {
				planUnit = 0;
			}
			firstUnit = [units objectAtIndex:planUnit];
			if (planUnit == originalPlanUnit) {
				break;
			}
		}
		
		[self setPlanOrder:[NSMutableArray array]];
		[self tellUnitToPlan:firstUnit];
		
		// Now get any units that haven't planned a path to plan
		for (ASIUnit *unit in units) {
			if (![unit havePerformedPathFinding]) {
				[self tellUnitToPlan:unit];
			}
		}
		
	} else {
		for (ASIUnit *unit in units) {
			[unit setHaveMoved:NO];
		}
	}
	
	for (ASIUnit *unit in [planOrder reverseObjectEnumerator]) {
		[unit move];
		
		// For any objects that have been given orders to move since we last planned - this will only happen if we aren't on the first time step
		if (![unit havePerformedPathFinding]) {
			[unit performPathFinding];
		}
	}	
}
	
- (void)tellUnitToPlan:(ASIUnit *)unit
{
	[planOrder addObject:unit];
	[unit performPathFinding];
	ASIPath *path = [unit path];
	unsigned int i;
	for (i=0; i<[path length]; i++) {
		Position3D position = [path nodeAtIndex:i];
		ASIMapObject *objectInTheWay = [map objectAtPosition:position];
		if ([objectInTheWay isKindOfClass:[ASIUnit class]] && objectInTheWay != unit && ![(ASIUnit *)objectInTheWay havePerformedPathFinding]) {
			[self tellUnitToPlan:(ASIUnit *)objectInTheWay];
		}
	}
}
		

- (void)addUnit:(ASIUnit *)unit
{
	[units addObject:unit];
	[unit setTeam:self];
}
- (void)removeUnit:(ASIUnit *)unit
{
	[units removeObject:self];
	[unit setTeam:nil];	
}

@synthesize map;
@synthesize spaceTimeMap;
@synthesize planOrder;
@synthesize units;
@end
