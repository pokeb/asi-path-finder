//
//  ASITeam.h
//  ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIWorldMap;
@class ASISpaceTimeMap;
@class ASIUnit;

@interface ASITeam : NSObject {
	
	// A reference to the world map
	ASIWorldMap *map;
	
	// The space time map that will be used for reserving future positions during path finding
	ASISpaceTimeMap *spaceTimeMap;
	
	// A list of the units in this team
	NSMutableArray *units;
	
	NSMutableArray *planOrder;
	int planUnit;
}

// Perform path finding for all objects in this team
- (void)performPathFinding;

// Adding and removing members of this team
- (void)addUnit:(ASIUnit *)unit;
- (void)removeUnit:(ASIUnit *)unit;

// This method will be called with the unit that is top of the path finding queue
// Once it has done path finding, this method will be called again with any units in its way, and so on, recursively
// Though not foolproof, it can help to resolve collisions before they happen by adjusting the plan order based on who is in the way of the top unit
// Basically, it's a simple priority system - the top unit gets a chance to plan its whole path, and others have to move out of the top units way
- (void)tellUnitToPlan:(ASIUnit *)unit;

@property (assign, nonatomic) ASIWorldMap *map;
@property (retain, nonatomic) ASISpaceTimeMap *spaceTimeMap;
@property (retain, nonatomic) NSMutableArray *units;
@property (retain, nonatomic) NSMutableArray *planOrder;
@end
