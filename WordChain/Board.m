//
//  Board.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Board.h"

@interface Board()
-(void)initGrid;
@end

@implementation Board
@synthesize chain;

-(void)newChain {
    self.chain = [NSArray arrayWithObjects:@"final", @"four", @"square", @"dance", @"party", @"time", nil];
    
    // Build the grid
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
            
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            Tile *tile = [Tile tileWithLetter:[self letterForRow:row col:col] row:row col:col];
            grid[row][col] = tile;
            
            // Position the tile
            
            tile.position = ccp([tile boundingBox].size.width * col, [CCDirector sharedDirector].winSize.height - [tile boundingBox].size.height * row);
            [self addChild:tile];
        }
    }
    
}

-(NSString*)wordForRow:(NSUInteger)row {
    return [self.chain objectAtIndex:row];
}
-(NSString*)letterForRow:(NSUInteger)row col:(NSUInteger)c {
    NSString *word = [self wordForRow:row];
    
    if (c < [word length]) {
        return [[NSString stringWithFormat:@"%C", [word characterAtIndex:c]] uppercaseString];
    } else {
        return nil;
    }
}
                                 
                                 

@end
