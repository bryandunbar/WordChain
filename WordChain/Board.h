//
//  Board.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "Tile.h"
#import "Chain.h"

@interface Board : CCLayerColor {
    
    /** Board Consists of a grid of tiles **/
    Tile *grid[BOARD_GRID_ROWS][BOARD_GRID_COLUMNS];
    
    /** Current Word Chain **/
    Chain *chain;
    
}
    

@property (nonatomic,retain) Chain *chain;

-(void)newChain; 
-(void)updateSelectableTiles;
-(void)updateTileStates;
-(Tile*)tileForRow:(NSUInteger)row col:(NSUInteger)c;
@end
