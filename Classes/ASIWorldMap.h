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

@class MapObject;
@class ASISpaceTimeMap;

@interface ASIWorldMap : ASIObjectMap {
	NSMutableArray *objects;
	ASISpaceTimeMap *spaceTimeMap;
}

+ (id)map;
- (void)addObject:(MapObject *)object;
- (void)removeObject:(MapObject *)object;
- (void)removeObjectAtPosition:(Position3D)position;
- (NSArray *)moveableObjects;

@property (retain, nonatomic) NSMutableArray *objects;
@property (retain, nonatomic) ASISpaceTimeMap *spaceTimeMap;

@end
