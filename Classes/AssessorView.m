//
//  AssessorView.m
//  ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "AssessorView.h"
#import "ASISpatialPathAssessor.h"
#import "ASIUnit.h"

static NSDictionary *textAttributes = nil;

@implementation AssessorView

+ (void)initialize
{
	if (self == [AssessorView class]) {
		textAttributes = [[NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:8.5] forKey:NSFontAttributeName] retain];
	}
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
			
			ASISpatialPathAssessor *assessor = [[[ASISpatialPathAssessor alloc] initWithMap:map] autorelease];
			[assessor setObject:selectedUnit];
			while (![assessor haveFinishedAssessingPath]) {
				[assessor assessPathFrom:[selectedUnit destination] to:[selectedUnit position]];
			}
			[selectedUnit setPathAssessment:assessor];
			
			if ([assessor failedToFindRoute]) {
				[assessmentStatus setStringValue:@"✘ Failed to find route"];
			} else {
				[assessmentStatus setStringValue:@"✔ Found route"];
			}
		}
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (selectedUnit) {
		Position3D position = [selectedUnit position];
		NSRect drawRect = NSMakeRect(position.x*23, position.y*23, 23, 23);
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path appendBezierPathWithOvalInRect:drawRect];
		[[NSColor greenColor] setFill];
		[path fill];
		[[NSColor blueColor] setStroke];
		[path stroke];
		
		position = [selectedUnit destination];
		drawRect = NSMakeRect(position.x*23, position.y*23, 23, 23);
		if (!EqualPositions(position, InvalidPosition)) {
			[[NSColor redColor] setStroke];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(drawRect.origin.x+3, drawRect.origin.y+3) toPoint:NSMakePoint(drawRect.origin.x+20, drawRect.origin.y+20)];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(drawRect.origin.x+3, drawRect.origin.y+20) toPoint:NSMakePoint(drawRect.origin.x+20, drawRect.origin.y+3)];
			
			int x,y;
			float distanceFromDestination;
			float estDist;
			for (x=0; x<[map mapSize].xSize; x++) {
				for (y=0; y<[map mapSize].ySize; y++) {
					distanceFromDestination = [[selectedUnit pathAssessment] realDistanceFromDestination:Position3DMake(x, y, 0)];
					estDist = DistanceBetweenPositions(Position3DMake(x, y, 0), [selectedUnit position]);
					if (distanceFromDestination > 0) {
						[[NSString stringWithFormat:@"%.1f\r\n%.1f",distanceFromDestination,estDist] drawAtPoint:NSMakePoint((x*23)+3, (y*23)+3) withAttributes:textAttributes];
					}
				}
			}
			
			
		}
	}
	

}

@synthesize selectedUnit;
@end
