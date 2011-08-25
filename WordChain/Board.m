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
-(void)findSelectableTiles;
@end

@implementation Board
@synthesize chain;

-(void)newChain {
    
    // Instatiate a new chain
    self.chain = [[Chain alloc] init];
    
    // rebuild the grid
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
            
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            Tile *tile = [Tile tileWithLetter:[chain letterForWord:row atIndex:col] row:row col:col];
            grid[row][col] = tile;
            
            // Position the tile (Starting at the top left of the board)
            tile.position = ccp([tile boundingBox].size.width * col, [CCDirector sharedDirector].winSize.height - [tile boundingBox].size.height * row);
            [self addChild:tile];
            
        }
    }
    
    // Perform the first tile state update
    [self updateTileStates];
}

-(void)updateTileStates {
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            Tile *tile = [self tileForRow:row col:col];
            
            if ([chain isWordSolved:row]) {
                tile.tileState = TileStatePlayed;
            }
        }
    }
    
    // Determine where the selectable tiles are. 
    [self findSelectableTiles];
}
-(void)findSelectableTiles {
    NSUInteger highestSelectableRow = [chain highestUnsolvedIndex];
    NSUInteger lowestSelectableRow = [chain lowestUnsolvedIndex];
    
    if (highestSelectableRow != -1 && lowestSelectableRow != -1) {
        
        // The first unplayed tile in each selectable row is selectable
        for (int i = 0; i < [[chain wordAtIndex:highestSelectableRow] length]; i++) {
            Tile *tile = [self tileForRow:highestSelectableRow col:i];
            if (tile.tileState == TileStateInitialized) {
                tile.tileState = TileStateSelectable;
                break;
            }
        }
        
        // Only do the lowest row if its not the same row
        if (highestSelectableRow != lowestSelectableRow) {
            for (int i = 0; i < [[chain wordAtIndex:lowestSelectableRow] length]; i++) {
                Tile *tile = [self tileForRow:lowestSelectableRow col:i];
                if (tile.tileState == TileStateInitialized) {
                    tile.tileState = TileStateSelectable;
                    break;
                }
            }
        }

    }
    
}
         
-(Tile*)tileForRow:(NSUInteger)row col:(NSUInteger)c {
    return grid[row][c];
}
                          
                          
-(void)dealloc {
    [super dealloc];
    [chain release];
}
                                 

@end
