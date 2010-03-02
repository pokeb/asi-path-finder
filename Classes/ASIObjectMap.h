//
//  ASIObjectMap.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 06/07/2007.
//  Copyright 2007 All-Seeing Interactive. All rights reserved.
// 
//  An ASIObjectMap is a three dimensional array of pointers with a fixed size
//  Positions in the array with no value are NULL
//  It is used to store objects on a map, and offers fast access to objects at a particular position
//  ASIMap is a subclass that stores the position of objects in 3 dimensions
//  ASISpaceTimeMap is a subclass that uses the third dimension to represent time
//  IMPORTANT: Core Foundation / Obj-C objects stored in this array are NOT retained

#import "ASIPathSearchDataTypes.h"

@interface ASIObjectMap : NSObject {
	
	// The size of the object map
	Size3D mapSize;
	
	// The size of the first two dimensions of the map, cached because we use it quite often
	unsigned short xByY;
	
	// A pointer to the storage used for the map
	id *grid;
}

// Create a new map with the size of each dimension
- (id)initWithMapSize:(Size3D)size;

// Get the object at a particular position
- (id)objectAtPosition:(Position3D)position;

// Set an object at a position
- (void)setObject:(id)theObject atPosition:(Position3D)position;

// Remove an object if it exists at a particular position
- (void)removeObject:(id)theObject atPosition:(Position3D)position;

// Acessor to allow direct access our storage. May be used to cut down on objc_msg_send
- (id *)grid;

@property (assign, nonatomic) Size3D mapSize;

@end
