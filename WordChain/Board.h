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
#import "GuessView.h"

@interface Board : CCLayerColor <CCTargetedTouchDelegate, GuessViewDelegate> {
    
    /** Board Consists of a grid of tiles **/
    Tile *grid[BOARD_GRID_ROWS][BOARD_GRID_COLUMNS];
    
    /** Current Word Chain **/
    Chain *chain;
    
    @private
    NSMutableArray *selectableTiles; // Any any given point only certain tiles will be "selectable"
    UITextField *hiddenTextField; // Hidden textfield that forces the keyboard to show up
    GuessView *guessView; // The accessory view where the user enter's their guess
}
    

@property (nonatomic,retain) Chain *chain;

-(void)newChain; 
-(void)updateTileStates;
-(Tile*)tileForRow:(NSUInteger)row col:(NSUInteger)c;
-(void)playTile:(Tile*)tile;
@end
