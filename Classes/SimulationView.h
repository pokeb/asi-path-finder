//
//  SimulationView.h
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 01/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//
//  This view is used in the example Mac app and shows the world view updated in real-time, with object paths plotted

#import "PathFinderView.h"


@interface SimulationView : PathFinderView {
	NSTimer *updateTimer;
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *pauseButton;
	IBOutlet NSButton *stepButton;
	IBOutlet NSSlider *speedSlider;

}

- (IBAction)start:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)step:(id)sender;
- (IBAction)update:(id)sender;

@property (retain, nonatomic) NSTimer *updateTimer;

@end
