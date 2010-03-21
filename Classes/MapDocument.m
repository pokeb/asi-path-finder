//
//  MyDocument.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "MapDocument.h"
#import "EGODatabase.h"
#import "ASIMapObject.h"
#import "ASIWorldMap.h"
#import "ASIUnit.h"
#import "SimulationView.h"
#import "ASISpaceTimeMap.h"
#import "ASITeam.h"

@implementation MapDocument



- (void)awakeFromNib
{
	[editView setMap:[self map]];
	[assessorView setMap:[self map]];
	[pathFinderView setMap:[self map]];
	[simulationView setMap:[self map]];
	[super awakeFromNib];	
	[tabView selectFirstTabViewItem:nil];

}




- (void)switchToSimulationView
{
	[tabView selectLastTabViewItem:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
		[self setMap:[ASIWorldMap map]];
		[[[self map] teams] addObject:[[[ASITeam alloc] initWithMap:[self map]] autorelease]];
    }
    return self;
}

- (void)dealloc
{
	[simulationView pause:nil];
	[map release];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	EGODatabase *db = [EGODatabase databaseWithPath:[absoluteURL path]];
	if (!db || ![db open]) {
		return NO;
	}

	EGODatabaseResult *result = [db executeQuery:@"select * from properties", nil];
	for(EGODatabaseRow *row in result) {
		[self setMap:[[[ASIWorldMap alloc] initWithMapSize:Size3DFromString([row stringForColumn:@"size"])] autorelease]];
		break;
	}
	
	result = [db executeQuery:@"select id from team", nil];
	for(EGODatabaseRow *row in result) {
		ASITeam *team = [[[ASITeam alloc] initWithMap:[self map]] autorelease];
		[[map teams] addObject:team];
		break;
	}
	
	// We'll hard code all objects into the same team for this example
	ASITeam *team = [[map teams] objectAtIndex:0];
	
	result = [db executeQuery:@"select * from mapobject", nil];
	
	for (EGODatabaseRow *row in result) {
		ASIMapObject *mapObject;
		if ([[row stringForColumn:@"type"] isEqualToString:@"building"]) {
			mapObject = [[[ASIMapObject alloc] initWithMap:[self map]] autorelease];
		} else {
			mapObject = [[[ASIUnit alloc] initWithMap:[self map]] autorelease];
			[(ASIUnit *)mapObject setDestination:Position3DFromString([row stringForColumn:@"destination"])];
			[team addUnit:(ASIUnit *)mapObject];
		}
		[mapObject setPosition:Position3DFromString([row stringForColumn:@"position"])];
	}
	[db close];

	return YES;
}

// Basic, not particularly efficient way of storing map data
// Hopefully though it's clear from the code what is happening
- (BOOL)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
	EGODatabase *db = [EGODatabase databaseWithPath:[absoluteURL path]];
	if (!db || ![db open]) {
		return NO;
	}
	[db beginTransaction];
	
	[db executeQuery:@"create table team(id integer)",nil];
	[db executeQuery:@"create table properties(size text)", nil];
	[db executeQuery:@"create table mapobject(type text, position text, destination text, team integer)", nil];
	
	[db commit];
	[db beginTransaction];
	
	[db executeQuery:@"delete from properties", nil];
	[db executeQuery:@"delete from mapobject", nil];
	[db executeQuery:@"delete from team", nil];
	
	[db executeUpdate:@"insert into properties (size) values(?)", StringFromSize3D([map mapSize]), nil];
	
	[db executeUpdate:@"insert into team (id) values(1)", nil];
	
	for (ASIMapObject *object in [map objects]) {
		if ([object isKindOfClass:[ASIUnit class]]) {
			[db executeUpdate:@"insert into mapobject (type,position,destination,team) values('unit',?,?,1)", StringFromPosition3D([object position]), StringFromPosition3D([(ASIUnit *)object destination]), nil];
		} else {
			[db executeUpdate:@"insert into mapobject (type,position) values('building',?)", StringFromPosition3D([object position]), nil];
		}
	}
	[db commit];
	[db close];
	return YES;
	
}

- (void)setPlanMoves:(id)sender
{
	for (ASITeam *team in [map teams]) {
		[team setSpaceTimeMap:[[[ASISpaceTimeMap alloc] initWithSize:CGSizeMake(20, 20) timeSpan:[sender intValue]] autorelease]];
	}
}

@synthesize map;

@end
