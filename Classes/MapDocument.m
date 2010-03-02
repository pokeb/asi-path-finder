//
//  MyDocument.m
//  Part of ASIPathFinder --> http://allseeing-i.com/ASIPathFinder
//
//  Created by Ben Copsey on 27/02/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "MapDocument.h"
#import "EGODatabase.h"
#import "MapObject.h"
#import "ASIWorldMap.h"
#import "ASIImmovableObject.h"
#import "ASIMoveableObject.h"
#import "SimulationView.h"

@implementation MapDocument

+ (NSArray *)examples
{
	NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Examples"];
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:NULL];	
}

+ (NSArray *)failedExamples
{
	NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ExampleFailures"];
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:NULL];	
}


- (void)awakeFromNib
{
	[editView setMap:[self map]];
	[assessorView setMap:[self map]];
	[pathFinderView setMap:[self map]];
	[simulationView setMap:[self map]];
	[super awakeFromNib];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	if ([anItem tag] == 2000) {
		NSMenuItem *item = (NSMenuItem *)anItem;
		if ([item isHidden]) {
			return NO;
		}
		[item setHidden:YES];
		NSMenu *menu = [item menu];

		
		NSMenuItem *newItem;
		
		NSMenu *subMenu = [[[NSMenu alloc] initWithTitle:@"Examples"] autorelease];
		for (NSString *file in [[MapDocument examples] reverseObjectEnumerator]) {
			NSMenuItem *newItem = [[[NSMenuItem alloc] initWithTitle:[file stringByDeletingPathExtension] action:@selector(chooseExample:) keyEquivalent:@""] autorelease];
			[newItem setRepresentedObject:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Examples"] stringByAppendingPathComponent:file]];
			[newItem setTarget:self];
			[subMenu addItem:newItem];
		}
		newItem = [[[NSMenuItem alloc] initWithTitle:@"Examples" action:nil keyEquivalent:@""] autorelease];
		[newItem setSubmenu:subMenu];
		[menu addItem:newItem];

		subMenu = [[[NSMenu alloc] initWithTitle:@"Failing Examples"] autorelease];
		for (NSString *file in [[MapDocument failedExamples] reverseObjectEnumerator]) {
			newItem = [[[NSMenuItem alloc] initWithTitle:[file stringByDeletingPathExtension] action:@selector(chooseExample:) keyEquivalent:@""] autorelease];
			[newItem setRepresentedObject:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ExampleFailures"] stringByAppendingPathComponent:file]];
			[newItem setTarget:self];
			[subMenu addItem:newItem];
		}
		newItem = [[[NSMenuItem alloc] initWithTitle:@"Failing Examples" action:nil keyEquivalent:@""] autorelease];
		[newItem setSubmenu:subMenu];
		[menu addItem:newItem];
		
		return NO;
	}
	return YES;
}

- (void)chooseExample:(id)sender
{
	MapDocument *document = [[[MapDocument alloc] init] autorelease];
	[document readFromURL:[NSURL fileURLWithPath:[sender representedObject] isDirectory:NO] ofType:@"Map" error:NULL];
	[document makeWindowControllers];
	[[NSDocumentController sharedDocumentController] addDocument:document];
	[document showWindows];
							   

}

- (id)init
{
    self = [super init];
    if (self) {
		[self setMap:[ASIWorldMap map]];
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
	
	
	result = [db executeQuery:@"select * from mapobject", nil];
	
	for (EGODatabaseRow *row in result) {
		MapObject *mapObject;
		if ([[row stringForColumn:@"type"] isEqualToString:@"building"]) {
			mapObject = [[[ASIImmovableObject alloc] initWithMap:[self map]] autorelease];
		} else {
			mapObject = [[[ASIMoveableObject alloc] initWithMap:[self map]] autorelease];
			[(ASIMoveableObject *)mapObject setDestination:Position3DFromString([row stringForColumn:@"destination"])];
		}
		[mapObject setPosition:Position3DFromString([row stringForColumn:@"position"])];
	}
	[db close];
	return YES;
}

- (BOOL)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
	EGODatabase *db = [EGODatabase databaseWithPath:[absoluteURL path]];
	if (!db || ![db open]) {
		return NO;
	}
	[db beginTransaction];
	
	[db executeQuery:@"create table properties(size text)", nil];
	[db executeQuery:@"create table mapobject(type text, position text, destination text)", nil];
	
	[db commit];
	[db beginTransaction];
	
	[db executeQuery:@"delete from properties", nil];
	[db executeQuery:@"delete from mapobject", nil];
	
	[db executeUpdate:@"insert into properties (size) values(?)", StringFromSize3D([map mapSize]), nil];
	
	
	for (MapObject *object in [map objects]) {
		if ([object isKindOfClass:[ASIImmovableObject class]]) {
			[db executeUpdate:@"insert into mapobject (type,position) values('building',?)", StringFromPosition3D([object position]), nil];
		} else {
			[db executeUpdate:@"insert into mapobject (type,position,destination) values('unit',?,?)", StringFromPosition3D([object position]), StringFromPosition3D([(ASIMoveableObject *)object destination]), nil];
		}
	}
	[db commit];
	[db close];
	return YES;
	
}

- (void)setPlanMoves:(id)sender
{
	[map setSpaceTimeMap:[[[ASISpaceTimeMap alloc] initWithSize:CGSizeMake(20, 20) timeSpan:[sender intValue]] autorelease]];
}

@synthesize map;

@end
