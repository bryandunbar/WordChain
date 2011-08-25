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

@interface Board : CCLayerColor {
    
    /** Board Consists of a grid of tiles **/
    Tile *grid[BOARD_GRID_ROWS][BOARD_GRID_COLUMNS];
    
    /** Current Word Chain **/
    NSArray *chain;
}
    

@property (nonatomic,retain) NSArray *chain;


-(void)newChain; 
-(NSString*)wordForRow:(NSUInteger)row;
-(NSString*)letterForRow:(NSUInteger)row col:(NSUInteger)c;

@end
