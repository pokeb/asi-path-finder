//
//  EGODatabaseRow.h
//  EGODatabase
//
//  Created by Shaun Harrison on 3/6/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EGODatabaseResult;
@interface EGODatabaseRow : NSObject {
@private
	NSMutableArray* columnData;
	EGODatabaseResult* result;
}

- (id)initWithDatabaseResult:(EGODatabaseResult*)aResult;

- (int)intForColumn:(NSString*)columnName;
- (int)intForColumnIndex:(NSUInteger)columnIdx;

- (long)longForColumn:(NSString*)columnName;
- (long)longForColumnIndex:(NSUInteger)columnIdx;

- (BOOL)boolForColumn:(NSString*)columnName;
- (BOOL)boolForColumnIndex:(NSUInteger)columnIdx;

- (double)doubleForColumn:(NSString*)columnName;
- (double)doubleForColumnIndex:(NSUInteger)columnIdx;

- (NSString*)stringForColumn:(NSString*)columnName;
- (NSString*)stringForColumnIndex:(NSUInteger)columnIdx;

- (NSDate*)dateForColumn:(NSString*)columnName;
- (NSDate*)dateForColumnIndex:(NSUInteger)columnIdx;

@property(readonly) NSMutableArray* columnData;
@end
