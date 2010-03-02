//
//  MapObject.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIWorldMap.h"
#import "ASIObjectMap.h"

@interface MapObject : NSObject {
	ASIWorldMap *map;
	Position3D position;
}
- (id)initWithMap:(ASIWorldMap *)newMap;
- (BOOL)allowsCornerCutting;

@property (assign, nonatomic) ASIWorldMap *map;
@property (assign, nonatomic) Position3D position;
@end
