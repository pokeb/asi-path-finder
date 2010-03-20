//
//  PathFinderView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 28/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  This view is used in the example Mac app and plots information a single unit's path finding

#import "EditView.h"

@class ASIUnit;

@interface PathFinderView : EditView {
	ASIUnit *selectedUnit;
	IBOutlet NSTextField *assessmentStatus;
}
- (void)drawObjectPath:(ASIUnit *)object;

@property (retain, nonatomic) ASIUnit *selectedUnit;
@end

