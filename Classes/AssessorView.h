//
//  AssessorView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "EditView.h"

@class ASIMoveableObject;

@interface AssessorView : EditView {
	ASIMoveableObject *selectedUnit;
	IBOutlet NSTextField *assessmentStatus;
}

@property (retain, nonatomic) ASIMoveableObject *selectedUnit;
@end
