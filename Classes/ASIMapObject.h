//
//  ASIMapObject.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIWorldMap.h"
#import "ASIObjectMap.h"

@interface ASIMapObject : NSObject {
	ASIWorldMap *map;
	Position3D position;
}
- (id)initWithMap:(ASIWorldMap *)newMap;

// Objects that return YES allow their corners to be cut when another object is travelling past
- (BOOL)allowsCornerCutting;

// This method is called during path finding by both ASIPathAssessor and ASIPathFinder
// It allows objects to ask other in their way if they are allowed to pass through them
// This is what the parameters mean:
// * mapObject = the object that wants to pass through us
// * aboutToMove = are we wanting to know if we can actually move through this object right now (for ASISpaceTimePathFinder, this will be YES)
//   Or, are we asking if can potentially move to this space in future (for ASISpatialPathAssessor, this will be NO)
//   An immovable object will ignore this value, since it can never move out the way
//   A movable object might return yes if it can potentially vacate this position in future
// * myPosition = the position the object is asking about (large objects that take up multiple positions may be passable only at certain points)
// * theirPosition = the position the object is travelling from
// * cost = the current cost the object will take to get here. We are passed a pointer to this value so we can increase it
// * distance = similar to cost, the distance the object is from it's destination if it were here We can increase this too
- (BOOL)isPassableByObject:(ASIMapObject *)mapObject movingNow:(BOOL)aboutToMove atPosition:(Position3D *)myPosition fromPosition:(Position3D *)theirPosition withCost:(float *)cost andDistance:(float *)distance;


@property (assign, nonatomic) ASIWorldMap *map;
@property (assign, nonatomic) Position3D position;
@end
