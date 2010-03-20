//
//  SimulationView.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 01/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "SimulationView.h"
#import "ASIUnit.h"
#import "ASIWorldMap.h"
#import "ASISpaceTimeMap.h"
#import "ASIPath.h"
#import "ASITeam.h"

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
	ASIMapObject *unit = [map objectAtPosition:position];
	if (unit && [unit isKindOfClass:[ASIUnit class]]) {
		[self setSelectedUnit:(ASIUnit *)unit];
	} else if (selectedUnit) {
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
	for (ASITeam *team in [map teams]) {
		[team performPathFinding];
	}
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	for (ASIUnit *unit in [map units]) {
		if (unit != selectedUnit) {
			[self drawObjectPath:unit];
		}
	}
	if (selectedUnit) {
		[self drawObjectPath:selectedUnit];
	}
}



@synthesize updateTimer;
@end
