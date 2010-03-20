//
//  ASIWorldMap.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 28/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  A 3-dimensional map that stores the location of objects

#import <Foundation/Foundation.h>
#import "ASIObjectMap.h"
#import "ASIPathSearchDataTypes.h"

@class ASIMapObject;
@class ASISpaceTimeMap;

@interface ASIWorldMap : ASIObjectMap {
	NSMutableArray *objects;
	NSMutableArray *teams;
}

// Convienence constructor, hard coded for a 20*20*1 size used in the sample Mac app
+ (id)map;

// Add an object to the map
- (void)addObject:(ASIMapObject *)object;

// Remove an object from the map
- (void)removeObject:(ASIMapObject *)object;
- (void)removeObjectAtPosition:(Position3D)position;

// Returns an array of all the units on this map
- (NSArray *)units;

@property (retain, nonatomic) NSMutableArray *objects;
@property (retain, nonatomic) NSMutableArray *teams;

@end
