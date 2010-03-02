//
//  EGODatabaseRow.m
//  EGODatabase
//
//  Created by Shaun Harrison on 3/6/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import "EGODatabaseRow.h"
#import "EGODatabaseResult.h"


@implementation EGODatabaseRow
@synthesize columnData;

- (id)initWithDatabaseResult:(EGODatabaseResult*)aResult {
	if((self = [super init])) {
		columnData = [[NSMutableArray alloc] init];
		result = aResult;
		// result = [aResult retain];
	}
	
	return self;
}

- (int)columnIndexForName:(NSString*)columnName {
	return [result.columnNames indexOfObject:columnName];
}

- (int)intForColumn:(NSString*)columnName {
    NSUInteger columnIndex = [self columnIndexForName:columnName];
	if (columnIndex == NSNotFound) return 0;
    return [[columnData objectAtIndex:columnIndex] intValue];
}

- (int)intForColumnIndex:(NSUInteger)columnIndex {
    return [[columnData objectAtIndex:columnIndex] intValue];
}

- (long)longForColumn:(NSString*)columnName {
    NSUInteger columnIndex = [self columnIndexForName:columnName];
	if (columnIndex == NSNotFound) return 0;
    return [[columnData objectAtIndex:columnIndex] longValue];
}

- (long)longForColumnIndex:(NSUInteger)columnIndex {
    return [[columnData objectAtIndex:columnIndex] longValue];
}

- (BOOL)boolForColumn:(NSString*)columnName {
    return ([self intForColumn:columnName] != 0);
}

- (BOOL)boolForColumnIndex:(NSUInteger)columnIndex {
    return ([self intForColumnIndex:columnIndex] != 0);
}

- (double)doubleForColumn:(NSString*)columnName {
    NSUInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex == NSNotFound) return 0;
    return [[columnData objectAtIndex:columnIndex] doubleValue];
}

- (double)doubleForColumnIndex:(NSUInteger)columnIndex {
    return [[columnData objectAtIndex:columnIndex] doubleValue];
}

- (NSString*) stringForColumn:(NSString*)columnName {
    NSUInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex == NSNotFound) return @"";
    return [columnData objectAtIndex:columnIndex];
}

- (NSString*)stringForColumnIndex:(NSUInteger)columnIndex {
    return [columnData objectAtIndex:columnIndex];
}

- (NSDate*)dateForColumn:(NSString*)columnName {
    NSUInteger columnIndex = [self columnIndexForName:columnName];
    if(columnIndex == NSNotFound) return nil;
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIndex]];
}

- (NSDate*)dateForColumnIndex:(NSUInteger)columnIndex {
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIndex]];
}

- (void)dealloc {
	// [result release];
	[columnData release];
	[super dealloc];
}

@end
