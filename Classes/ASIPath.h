//
//  ASIPath.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/04/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//  An array of positions representing a path - objects use this to figure out where they are moving to next.
//  A Path object is the output of ASISpaceTimePathFinder. 
//  For speed, it has a fixed size, which is not a problem for our purposes as each path will always be exactly the same length

#import "ASIPathSearchDataTypes.h"

@interface ASIPath : NSObject {
	
	// Pointer to the storage for our positions
	Position3D *nodes;
	
	// The length of this path
	unsigned char length;
	
	// Internal counter that records the point we are at while adding positions to the path
	unsigned char writeCounter;
	
	// Internal counter that records the point we are at while reading from the path
	unsigned char readCounter;
}

// Create a path with a size
- (id)initWithInitialSize:(int)size;

// Add a position to the end of the path 
- (void)addNode:(Position3D)newPosition;

// Add a position to the beginning of the path
- (void)insertNodeAtStart:(Position3D)newPosition;

// Get the first position in the path
- (Position3D)firstNode;

// Remove the first position in the path
- (void)removeFirstNode;

// The number of positions remaining in the path
- (int)length;

// Returns a position from a point in the path (primarily useful for debugging)
- (Position3D)positionAtIndex:(unsigned int)index;
@end
