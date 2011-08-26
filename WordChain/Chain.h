//
//  Chain.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chain : NSObject {

    @private
    NSArray *words;
    NSMutableArray *solvedIndices;
}


-(NSString*)wordAtIndex:(NSUInteger)idx;
-(NSString*)letterForWord:(NSUInteger)wordIdx atIndex:(NSUInteger)idx;

-(BOOL)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx;
-(BOOL)isWordSolved:(NSUInteger)idx;
-(void)solveWordAtIndex:(NSUInteger)idx;
-(BOOL)isChainSolved;
-(NSUInteger)lowestUnsolvedIndex;
-(NSUInteger)highestUnsolvedIndex;

@end
