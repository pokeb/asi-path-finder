//
//  ASIPathSearchDataTypes.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  Definitions of our data types, and functions that operate on them



//  A Position is a simple data structure that records an x,y,z position in space
//  x and y record coordinates on a two dimensional map
//  z can be used to record a 3rd dimension, or (as in the case of ASISpaceTimeMap) a time
typedef struct position3d
{
	signed char x;
	signed char y;   
	signed char z;
} Position3D;

typedef struct size3d
{
	signed char xSize;
	signed char ySize;   
	signed char zSize;
} Size3D;


//  Nodes are used by the various path finding classes to store a position along with additional data that describes how the path finder reached that node
typedef struct Node Node;
struct Node {
	
	// The cost to reach this position. Generally, this is the number of steps to get there, though other factors can increase the cost 
	// For example, moving diagonally is slightly more expensive than horizontally (this reduces the likelyhood that paths will zigzag)
	// Additionally, we increase the cost of moving to a position that already contains a unit, as it may take time for it to move out of the way
	// So, if it's possible to go around a unit easily, path finders will give preference to paths that do that
	float cost;
	
	// The distance from the destination node
	float distance;
	
	// The number of steps we took to get here
	unsigned char time;
	
	// The direction we are facing when we arrive here
	// Allows us to increase the cost of changing direction so we can ensure the straightest paths
	// Additionally, we use this to avoid cutting corners when we aren't allowed to do so - for example, to avoid appearing to pass diagonally through the corner of a square object
	unsigned char direction;
	
	// The actual position this node represents
	Position3D position;
	
	// The parent node is the node we were on before we arrived here. Allows us to step back in time when a path finder arrives at the destination to build a path
	Node *parentNode;
};

// Used for storing current direction
enum {
	PathDirectionNorth = 0,
	PathDirectionNorthWest = 1,
	PathDirectionWest = 2,
	PathDirectionNorthEast = 3,
	PathDirectionSouthWest = 4,
	PathDirectionEast = 5,
	PathDirectionSouthEast = 6,
	PathDirectionSouth = 7
};

// Allocates storage for a single node, and keeps track of the pointer in a global array so we can free the memory later
// Used when we need a reference to a node on the heap that won't change
struct Node *nodeAlloc(void);

// Free all the nodes we have allocated with nodeAlloc()
void freeNodes();

// A special position that represents an invalid point on the map (-1,-1,-1)
// This is normally used as the default Position where a position has not yet been set
extern Position3D InvalidPosition;

// Create a position
Position3D Position3DMake(int x, int y, int z);

// Create a position
Size3D Size3DMake(int xSize, int ySize, int zSize);

// Determine if two positions are equal to each other
BOOL EqualPositions(Position3D position1,Position3D position2);

// The distance between two positions, as the crow flies
float DistanceBetweenPositions(Position3D position1, Position3D position2);

// Turn a position into a string (perhaps to store it somewhere)
NSString *StringFromPosition3D(Position3D position);

// Turn a string into a position
Position3D Position3DFromString(NSString *string);

// Turn a size into a string (perhaps to store it somewhere)
NSString *StringFromSize3D(Size3D size);

// Turn a string into a position
Size3D Size3DFromString(NSString *string);

extern NSInteger sortByDistance(id obj1, id obj2, void *fromPos);

