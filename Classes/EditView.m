//
//  EditView.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/06/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "EditView.h"
#import "ASIMapObject.h"
#import "ASIWorldMap.h"
#import "ASIUnit.h"
#import "ASITeam.h"

static NSDictionary *textAttributes = nil;


@implementation EditView

+ (void)initialize
{
	if (self == [EditView class]) {
		textAttributes = [[NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:10] forKey:NSFontAttributeName] retain];
	}
}

- (BOOL)acceptsFirstResponder {
    return YES;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDrawOffset:NSMakePoint(0, 0)];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	erasing = NO;
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	Position3D position = [self positionAtPoint:point];
	if ([map objectAtPosition:position]) {
		[map removeObjectAtPosition:position];
		erasing = YES;
	} else if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		[self paintUnitAtPosition:position];
	} else {
		[self paintBuildingAtPosition:position];
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	Position3D position = [self positionAtPoint:point];
	if (erasing) {
		[map removeObjectAtPosition:position];
	} else if (![map objectAtPosition:position]) {
		if ([theEvent modifierFlags] & NSAlternateKeyMask) {
			[self paintUnitAtPosition:position];
		} else {
			[self paintBuildingAtPosition:position];
		}
	}
	[self setNeedsDisplay:YES];
}

- (Position3D)positionAtPoint:(NSPoint)point
{
	return Position3DMake(floor((point.x-[self drawOffset].x)/23), floor((point.y-[self drawOffset].y)/23),0);
}

- (void)paintBuildingAtPosition:(Position3D)position
{
	ASIMapObject *building = [[[ASIMapObject alloc] initWithMap:map] autorelease];
	[building setPosition:position];
	[self paintObject:building atPosition:position];
}

- (void)paintUnitAtPosition:(Position3D)position
{
	ASIUnit *unit = [[[ASIUnit alloc] initWithMap:map] autorelease];
	[unit setPosition:position];
	[unit setDestination:position];
	[[[map teams] objectAtIndex:0] addUnit:unit];
	[self paintObject:unit atPosition:position];
}

- (void)paintObject:(ASIMapObject *)object atPosition:(Position3D)position
{
	if (position.x >= 0 && position.x < [map mapSize].xSize && position.y >= 0 && position.y < [map mapSize].ySize) {
		
		[map removeObjectAtPosition:position];
		[map addObject:object];
	}
}

- (BOOL)isFlipped
{
	return YES;
}


- (void)drawRect:(NSRect)rect
{
	[self setDrawOffset:NSMakePoint(([self frame].size.width-([map mapSize].xSize*23))/2, ([self frame].size.height-([map mapSize].ySize*23))/2)];
	[[NSColor lightGrayColor] setFill];
	[NSBezierPath fillRect:[self bounds]];
	
	NSAffineTransform *xform = [NSAffineTransform transform];
	[xform translateXBy:[self drawOffset].x yBy:[self drawOffset].y];
	[NSGraphicsContext saveGraphicsState];
	[xform concat];
	
	NSRect drawRect = NSMakeRect(0, 0, [map mapSize].xSize*23, [map mapSize].ySize*23);
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect:drawRect];
	
	[[NSColor blackColor] setStroke];
	[NSBezierPath strokeRect:drawRect];
	
    int x,y;
	
	for (x=1; x<[map mapSize].xSize; x++) {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(x*23,0) toPoint:NSMakePoint(x*23,[self bounds].size.height)];
														
	}
	for (y=1; y<[map mapSize].ySize; y++) {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0,y*23) toPoint:NSMakePoint([self bounds].size.width,y*23)];
	}
	for (ASIMapObject *object in [map objects]) {
		Position3D position = [object position];
		drawRect = NSMakeRect(position.x*23, position.y*23, 23, 23);
		if ([object isKindOfClass:[ASIUnit class]]) {
			[[NSColor greenColor] setFill];
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path appendBezierPathWithOvalInRect:drawRect];
			[path fill];
			
			[[NSColor blackColor] setFill];
			[[NSString stringWithFormat:@"%i",[(ASIUnit *)object tag]] drawAtPoint:NSMakePoint(drawRect.origin.x+3, drawRect.origin.y+3) withAttributes:textAttributes];
		} else {
			
			[[NSColor blackColor] setFill];
			[NSBezierPath fillRect:drawRect];
		}
		
	}
	[NSGraphicsContext restoreGraphicsState];

}


@synthesize drawOffset;
@synthesize map;
@end
