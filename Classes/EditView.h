//
//  EditView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/06/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//  This view is used in the example Mac app to allow the user to draw scenery and units

#import "ASIObjectMap.h"

@class ASIWorldMap;
@class TileObject;
@class ASIMapObject;

@interface EditView : NSView {
	NSPoint drawOffset;
	ASIWorldMap *map;
	BOOL erasing;
}
- (Position3D)positionAtPoint:(NSPoint)point;
- (void)paintBuildingAtPosition:(Position3D)position;
- (void)paintUnitAtPosition:(Position3D)position;
- (void)paintObject:(ASIMapObject *)object atPosition:(Position3D)position;

@property (assign, nonatomic) NSPoint drawOffset;
@property (assign, nonatomic) ASIWorldMap *map;
@end
