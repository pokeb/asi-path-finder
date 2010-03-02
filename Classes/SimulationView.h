//
//  SimulationView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 01/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "PathFinderView.h"


@interface SimulationView : PathFinderView {
	NSTimer *updateTimer;
	int planUnit;
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *pauseButton;
	IBOutlet NSButton *stepButton;
	IBOutlet NSSlider *speedSlider;
	unsigned int frameCount;
	NSMutableArray *planOrder;
}

- (IBAction)start:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)step:(id)sender;
- (IBAction)update:(id)sender;

@property (retain, nonatomic) NSTimer *updateTimer;
@property (retain, nonatomic) NSMutableArray *planOrder;
@end
