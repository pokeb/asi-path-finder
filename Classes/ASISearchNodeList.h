//
//  ASISearchNodeList.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 17/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  In simple terms, ASISearchNodeList is an array of nodes used by ASISpatialPathAssessor and ASISpaceTimePathFinder
//  Nodes are added to the the list in such a way as to ensure the first item on the list will always be the best node to search next
//  In implementation, ASISearchNodeList is actually a Binary Heap. 
//  This is an efficient way to ensure the first item is always the next one to use, without having to compare a node against all others to keep the whole list sorted at all times
//  For more, see http://www.policyalmanac.org/games/binaryHeaps.htm (the algorithm implemented here is based on the description in this article)

#import "ASIPathSearchDataTypes.h"

@interface ASISearchNodeList : NSObject {
	
	// Stores the data used for the nodes. Will normally be larger than the the actual number of nodes we are storing to reduce the number of malloc calls
	Node *heap;
	
	// The number of nodes we have stored
	unsigned int length;
	
	// The length we have allocated. When adding a node, if the new length would exceed the storage we have allocated, we will allocate more space for nodes
	unsigned int allocatedLength;
}

// Adds a node to the list
- (void)addNode:(Node *)node;

// Removes the first node in the list, and reorders any existing items so that the first item is the best node
- (void)removeFirstNode;

// Get a pointer to the first node in the list
- (Node *)firstNode;

// Allocates more space for nodes
- (void)increaseSize;

// Accessor for our length
- (unsigned int)length;

// Prints information about the nodes we have stored and their position. Only really useful for debugging
- (void)log;

// Adds a node to the end position. Only really useful for debugging
- (void)addNodeWithoutComparison:(Node)node;

@end
