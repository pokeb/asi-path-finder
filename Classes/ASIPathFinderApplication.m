//
//  ASIPathFinderApplication.m
//  ASIPathFinder
//
//  Created by Ben Copsey on 20/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIPathFinderApplication.h"
#import "MapDocument.h"


@implementation ASIPathFinderApplication

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

- (void)chooseExample:(id)sender
{
	MapDocument *document = [[[MapDocument alloc] init] autorelease];
	[document readFromURL:[NSURL fileURLWithPath:[sender representedObject] isDirectory:NO] ofType:@"Map" error:NULL];
	[document makeWindowControllers];
	[[NSDocumentController sharedDocumentController] addDocument:document];
	[document showWindows];
	[document switchToSimulationView];
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
		for (NSString *file in [[ASIPathFinderApplication examples] reverseObjectEnumerator]) {
			NSMenuItem *newItem = [[[NSMenuItem alloc] initWithTitle:[file stringByDeletingPathExtension] action:@selector(chooseExample:) keyEquivalent:@""] autorelease];
			[newItem setRepresentedObject:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Examples"] stringByAppendingPathComponent:file]];
			[newItem setTarget:self];
			[subMenu addItem:newItem];
		}
		newItem = [[[NSMenuItem alloc] initWithTitle:@"Examples" action:nil keyEquivalent:@""] autorelease];
		[newItem setSubmenu:subMenu];
		[menu addItem:newItem];
		
		subMenu = [[[NSMenu alloc] initWithTitle:@"Failing Examples"] autorelease];
		for (NSString *file in [[ASIPathFinderApplication failedExamples] reverseObjectEnumerator]) {
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


@end
