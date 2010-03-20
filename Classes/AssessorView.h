//
//  AssessorView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  This view is used in the example Mac app and plots information about a single unit's path assessment

#import "EditView.h"

@class ASIUnit;

@interface AssessorView : EditView {
	ASIUnit *selectedUnit;
	IBOutlet NSTextField *assessmentStatus;
}

@property (retain, nonatomic) ASIUnit *selectedUnit;
@end
