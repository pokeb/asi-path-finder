//
//  ASIPath.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 20/04/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASIPath.h"

@implementation ASIPath

- (id)initWithInitialSize:(int)size
{
	self = [super init];
	length = size;
	nodes = malloc(size*sizeof(Position3D));
	writeCounter = 0;
	readCounter = 0;
	return self;
}

- (void)dealloc
{
	free(nodes);
	[super dealloc];
}

- (void)addNode:(Position3D)newPosition
{
	if (writeCounter >= length) {
		//NSLog(@"Argh!");
		return;
	}
	Position3D *p = nodes+writeCounter;
	*p = newPosition;
	writeCounter++;

}

- (void)insertNodeAtStart:(Position3D)newPosition
{
	if (writeCounter >= length) {
		//NSLog(@"Argh!");
		return;
	}
	memcpy(nodes+1, nodes, sizeof(Position3D)*(length-1));
	*nodes = newPosition;
	writeCounter++;

}

- (int)length
{
	return writeCounter-readCounter;
}

- (Position3D)firstNode
{
	if (readCounter > writeCounter) {
		return InvalidPosition;
	}
	return *(nodes+readCounter);	
}

- (void)removeFirstNode
{
	readCounter++;
}

- (NSString *)description
{
	NSString *description = @"";
	int i;
	for (i=readCounter; i<writeCounter; i++) {
		description = [description stringByAppendingFormat:@"%@\r\n",StringFromPosition3D(*(nodes+i))];
	}
	return description;
}

- (Position3D)positionAtIndex:(unsigned int)index
{
	return *(nodes+readCounter+index);
}


@end
