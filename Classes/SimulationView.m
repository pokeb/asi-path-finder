//
//  SimulationView.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 01/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "SimulationView.h"
#import "ASIMoveableObject.h"
#import "ASIWorldMap.h"
#import "ASISpaceTimeMap.h"
#import "ASIPath.h"

@implementation SimulationView

- (void)dealloc
{
	[updateTimer invalidate];
	[updateTimer release];
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	Position3D position = [self positionAtPoint:point];
	MapObject *unit = [map objectAtPosition:position];
	if (unit && [unit isKindOfClass:[ASIMoveableObject class]]) {
		[self setSelectedUnit:(ASIMoveableObject *)unit];
	} else if (selectedUnit) {
		
		// Force the unit to the start of the planning queue
		frameCount = 0;
		
		
		planUnit = [[map moveableObjects] indexOfObject:selectedUnit]-1;
		if (planUnit == -1) {
			planUnit = [[map moveableObjects] count]-1;
		}
		if (![map objectAtPosition:position]) {
			[selectedUnit setDestination:position];
			[selectedUnit performPathFinding];
		}
	}
	[self setNeedsDisplay:YES];
}

- (IBAction)start:(id)sender
{
	[self pause:nil];
	[startButton setEnabled:NO];
	[pauseButton setEnabled:YES];
	[stepButton setEnabled:NO];

	[self setUpdateTimer:[NSTimer scheduledTimerWithTimeInterval:1.0f/[speedSlider intValue] target:self selector:@selector(update:) userInfo:nil repeats:YES]];
}

- (IBAction)pause:(id)sender
{
	if ([self updateTimer]) {
		[[self updateTimer] invalidate];
		[self setUpdateTimer:nil];
	}
	[startButton setEnabled:YES];
	[pauseButton setEnabled:NO];
	[stepButton setEnabled:YES];
}

- (IBAction)step:(id)sender
{
	[self update:nil];
}

- (IBAction)update:(id)sender
{	
	NSArray *units = [map moveableObjects];
	ASIMoveableObject *firstUnit;
	unsigned int totalUnits = [units count];
	int originalPlanUnit;
	
	//[[map spaceTimeMap] incrementTime];
	frameCount++;
	if (frameCount == [[map spaceTimeMap] timeSpan]-1) {
		frameCount = 0;
		[[map spaceTimeMap] clear];
		

		
		for (ASIMoveableObject *unit in units) {
			[unit setHavePerformedPathFinding:NO];
			[unit setHaveMoved:NO];
		}
		planUnit++;
		
		if (planUnit > totalUnits-1) {
			planUnit = 0;
		}
		originalPlanUnit = planUnit;
		
		firstUnit = [units objectAtIndex:planUnit];
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
		
		units = [units sortedArrayUsingFunction:sortByDistance context:firstUnit];
		[self setPlanOrder:[NSMutableArray array]];
		ASIMoveableObject *newUnit;
		while (firstUnit) {
			[planOrder addObject:firstUnit];
			[firstUnit performPathFinding];
			[firstUnit setHavePerformedPathFinding:YES];
			Position3D position = [[firstUnit path] firstNode];
			newUnit = [map objectAtPosition:position];
			if (firstUnit != newUnit && ![newUnit havePerformedPathFinding]) {
				firstUnit = newUnit;
			} else {
				break;
			}
		}
		
		for (ASIMoveableObject *unit in units) {
			if (![unit havePerformedPathFinding]) {
				[planOrder addObject:unit];
				[unit performPathFinding];
			}
		}
		
//		unsigned int i;
//		for (i=planUnit; i<totalUnits; i++) {
//			[[units objectAtIndex:i] performPathFinding];
//		}
//		for (i=0; i<planUnit; i++) {
//			[[units objectAtIndex:i] performPathFinding];
//		}	
	}
//	int i;
//	for (i=planUnit-1; i>-1; i--) {
//		[[units objectAtIndex:i] move];
//	}
//	for (i=totalUnits-1; i>planUnit-1; i--) {
//		[[units objectAtIndex:i] move];
//	}
	
	for (ASIMoveableObject *unit in [planOrder reverseObjectEnumerator]) {
		[unit move];
	}
	
	[self setNeedsDisplay:YES];
}



@synthesize updateTimer;
@synthesize planOrder;
@end
