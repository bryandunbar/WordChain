//
//  Chain.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chain : NSObject <NSCoding> {

    @private
    NSArray *words;
    NSMutableArray *solvedIndices;
    NSManagedObjectContext *_moc;
}

@property (nonatomic, retain) NSManagedObjectContext *moc;

-(NSString*)wordAtIndex:(NSUInteger)idx;
-(NSString*)letterForWord:(NSUInteger)wordIdx atIndex:(NSUInteger)idx;

-(BOOL)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx;
-(BOOL)isWordSolved:(NSUInteger)idx;
-(void)solveWordAtIndex:(NSUInteger)idx;
-(BOOL)isChainSolved;
-(NSUInteger)lowestUnsolvedIndex;
-(NSUInteger)highestUnsolvedIndex;
-(NSArray *)wordsForLevel:(int)lvl;

@end
