//
//  PathFinderView.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 28/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "PathFinderView.h"
#import "ASIPathSearchDataTypes.h"
#import "ASIUnit.h"
#import "ASIPath.h"
#import "ASISpatialPathAssessor.h"
#import "ASISpaceTimeMap.h"
#import "ASITeam.h"

@implementation PathFinderView

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	Position3D position = [self positionAtPoint:point];
	ASIMapObject *unit = [map objectAtPosition:position];
	if (unit && [unit isKindOfClass:[ASIUnit class]]) {
		[self setSelectedUnit:(ASIUnit *)unit];
	} else if (selectedUnit) {
		
		if (![map objectAtPosition:position]) {
			[[[selectedUnit team] spaceTimeMap] clear];
			[selectedUnit setDestination:position];
			while (![[selectedUnit pathAssessment] haveFinishedAssessingPath]) {
				[selectedUnit performPathFinding];
			}
			if ([[selectedUnit pathAssessment] failedToFindRoute]) {
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
		[self drawObjectPath:selectedUnit];
	}
}

- (void)drawObjectPath:(ASIUnit *)object
{
	Position3D position = [object position];
	NSRect drawRect = NSMakeRect(position.x*23, position.y*23, 23, 23);
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path appendBezierPathWithOvalInRect:drawRect];
	
	if (object == selectedUnit) {
		[[NSColor blueColor] setStroke];
		[path stroke];
	}
	
	NSColor *color = [NSColor orangeColor];
	
	if (object == selectedUnit) {
		color = [NSColor blueColor];
	}
	
	NSRect lastRect = drawRect;
	
	position = [object destination];
	drawRect = NSMakeRect(position.x*23, position.y*23, 23, 23);
	if (!EqualPositions(position, InvalidPosition) && !EqualPositions(position, [object position])) {
		[color setStroke];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(drawRect.origin.x+3, drawRect.origin.y+3) toPoint:NSMakePoint(drawRect.origin.x+20, drawRect.origin.y+20)];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(drawRect.origin.x+3, drawRect.origin.y+20) toPoint:NSMakePoint(drawRect.origin.x+20, drawRect.origin.y+3)];
	}
	
	
	ASIPath *movePath = [object path];
	int i;
	for (i=0; i<[movePath length]; i++) {
		Position3D position = [movePath positionAtIndex:i];
		drawRect = NSMakeRect((position.x*23)+5, (position.y*23)+5, 13, 13);
		path = [NSBezierPath bezierPath];
		[path appendBezierPathWithOvalInRect:drawRect];
		[color setFill];
		[color setStroke];
		[path fill];
		[NSBezierPath setDefaultLineWidth:2];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(drawRect.origin.x+(drawRect.size.width/2), drawRect.origin.y+(drawRect.size.height/2)) toPoint:NSMakePoint(lastRect.origin.x+(lastRect.size.width/2), lastRect.origin.y+(lastRect.size.height/2))];
		lastRect = drawRect;
		[NSBezierPath setDefaultLineWidth:1];
		
	}	
}

@synthesize selectedUnit;
@end

