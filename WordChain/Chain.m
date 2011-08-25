//
//  Chain.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Chain.h"

@interface Chain ()
@property (nonatomic,retain) NSArray *words;
@property (nonatomic,retain) NSMutableArray *solvedIndices;
@end

@implementation Chain
@synthesize words, solvedIndices;

- (id)init
{
    self = [super init];
    if (self) {
        self.words = [NSArray arrayWithObjects:@"final", @"four", @"square", @"dance", @"party", @"time", nil];
        
        // First and last start as solved
        self.solvedIndices = [NSMutableArray arrayWithCapacity:[self.words count]];
        [self solveWordAtIndex:0];
        [self solveWordAtIndex:[self.words count] - 1];
    }
    
    return self;
}

-(NSString*)wordAtIndex:(NSUInteger)idx {
    return [words objectAtIndex:idx];
}
-(NSString*)letterForWord:(NSUInteger)wordIdx atIndex:(NSUInteger)idx {
    NSString *word = [self wordAtIndex:wordIdx];
    
    if (idx < [word length]) {
        return [[NSString stringWithFormat:@"%C", [word characterAtIndex:idx]] uppercaseString];
    } else {
        return nil;
    }
}
-(BOOL)isWordSolved:(NSUInteger)idx {
    return [self.solvedIndices containsObject:[NSNumber numberWithInt:idx]];
}
-(void)solveWordAtIndex:(NSUInteger)idx {
    if (![self isWordSolved:idx]) {
        [self.solvedIndices addObject:[NSNumber numberWithInt:idx]];
    }
}
-(BOOL)isChainSolved {
    return [self.words count] == [self.solvedIndices count];
}
-(NSUInteger)lowestUnsolvedIndex {
    
    if ([self isChainSolved]) return -1;
    for (NSUInteger i = 0; i < [words count]; i++) {
        if (![self isWordSolved:i]) {
            return i;
        }
    }
    return -1; // This code should never be reached
}
-(NSUInteger)highestUnsolvedIndex {

    if ([self isChainSolved]) return -1;
    for (NSUInteger i = [words count] - 1; i >=0; i--) {
        if (![self isWordSolved:i]) {
            return i;
        }
    }
    return -1; // This code should never be reached
}
-(void)dealloc {
    [super dealloc];
    [words release];
    [solvedIndices release];
}

@end
