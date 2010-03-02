//
//  ASISearchNodeList.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 17/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASISearchNodeList.h"

@implementation ASISearchNodeList

- (id)init
{
	self = [super init];
	[self increaseSize];
	return self;
}

- (void)dealloc
{
	free(heap);
	[super dealloc];
}

- (void)increaseSize
{

	if (heap) {
		allocatedLength *= 2;
		heap = realloc(heap, sizeof(Node)*allocatedLength);
	} else {
		allocatedLength += 10;
		heap = malloc(sizeof(Node)*allocatedLength);
	}
}

- (void)addNodeWithoutComparison:(Node *)node
{
	Node *position = heap+length;
	*position = *node;
	length++;
}

- (void)addNode:(Node *)node
{
	//NSLog(@"About to add node Distance: %f Cost: %f",node->distance,node->cost);
	if (length == 0) {
		*heap = *node;
		length++;
		return;
	}
	length++;
	if (length == allocatedLength) {
		[self increaseSize];
	}
	unsigned int currentPosition = length;
	Node *position = heap+currentPosition-1;
	*position = *node;
	while (currentPosition > 1) {
		
		currentPosition = floor(currentPosition/2.0f);
		Node *childNode = heap+currentPosition-1;
		
		if (childNode->distance > node->distance) {
			//swap
			*position = *childNode;
			*childNode = *node;
			position = childNode;
			
		} else if (childNode->distance == node->distance) {
			if (childNode->cost > node->cost) {
				//swap
				*position = *childNode;
				*childNode = *node;
				position = childNode;
			}
		} else {
			break;
		}

	}
	//[self log];
}

- (Node *)firstNode
{
	return heap;
}

- (void)removeFirstNode
{
	//NSLog(@"About to remove node");
	Node *node = heap+length-1;
	*heap = *node;
	length--;
	
	Node n = *heap;
	Node *firstChild;
	Node *secondChild;
	
	unsigned int currentPosition = 1;
	Node *position = heap;
	while (1) {
		
		if ((currentPosition*2) > length) {
			break;
		}
		firstChild = heap+(currentPosition*2)-1;
		
		if ((currentPosition*2)+1 <= length) {
			
			secondChild = firstChild+1;
			
			// Both children exist, find the lowest
			if (secondChild->distance < firstChild->distance) {
				firstChild = secondChild;
				currentPosition = (currentPosition*2)+1;
			} else if (secondChild->distance == firstChild->distance) {
				if (secondChild->cost < firstChild->cost) {
					firstChild = secondChild;
					currentPosition = (currentPosition*2)+1;
				} else {
					currentPosition = currentPosition*2;	
				}
			} else {
				currentPosition = currentPosition*2;	
			}
		}
		if (firstChild->distance < position->distance) {
			//swap
			*position = *firstChild;
			*firstChild = n;
			position = firstChild;
		} else if (firstChild->distance == position->distance && firstChild->cost < position->cost) {
			//swap
			*position = *firstChild;
			*firstChild = n;
			position = firstChild;	
		} else {
			break;
		}
		
	}
	//[self log];
}

- (void)log
{
	NSLog(@"---");
	unsigned int i;
	for (i=0; i<length; i++) {
		Node *n = heap+i;
		NSLog(@"Distance: %f cost: %f",n->distance,n->cost);
	}	
}

- (unsigned int)length
{
	return length;
}

@end
