//
//  MapDocument.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//


#import "ASIObjectMap.h"

@class ASIWorldMap;
@class EditView;
@class AssessorView;
@class PathFinderView;
@class SimulationView;

@interface MapDocument : NSDocument {
	ASIWorldMap *map;
	IBOutlet EditView *editView;
	IBOutlet AssessorView *assessorView;
	IBOutlet PathFinderView *pathFinderView;
	IBOutlet SimulationView *simulationView;
}

+ (NSArray *)examples;
+ (NSArray *)failedExamples;
- (IBAction)setPlanMoves:(id)sender;

@property (retain, nonatomic) ASIWorldMap *map;
@end
