//
//  BoardLayer.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "BoardLayer.h"
#import "GameState.h"
#import "HudLayer.h"
#import "GameManager.h"
#import "Constants.h"
#import "GuessScene.h"

@interface BoardLayer()
-(BOOL)selectTileForTouch:(CGPoint)touchLocation;
-(NSString*)visibleTextForRow:(NSUInteger)row;
-(void)updateBoard;
-(void)updateHud;

@property (nonatomic,retain) GuessView *guessView;
@property (nonatomic,retain) UITextField *hiddenTextField;
@end

@implementation BoardLayer
@synthesize guessView, hiddenTextField;

#pragma mark -
#pragma mark Initialization
-(id)init {
    if (self = [super init]) {
        // Register for touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        // Configure the board
        [self layoutBoard];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    /*
     * This method is called every time the CCNode enters the 'stage'.
     */
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    if (gameData.board) {
        if (gameData.isGameOver) {
            [[GameManager sharedGameManager] runSceneWithID:SceneTypeMainMenu];
        }

        [self updateBoard];
        [self updateHud];
    }
}

#pragma mark -
#pragma mark Toches
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    return [self selectTileForTouch:touchLocation];      
}
-(BOOL)selectTileForTouch:(CGPoint)touchLocation {
   
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    for (BoardLocation *boardLocation in board.selectableTiles) {
        
        // Find the actual tile for this location
        Tile *tile = [self tileAtLocation:boardLocation];
        if (CGRectContainsPoint(tile.boundingBox, touchLocation)) {            
            CCLOG(@"Touched Tile: row = %i, col = %i", tile.row, tile.col);
            [self playTile:tile];
            return YES;
        }
    }    
    return NO;
}

#pragma mark -
#pragma mark Board Rendering
-(void)layoutBoard {
    
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;

    
    // Add a tile at every position
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            
            // Get the tilestate from the model
            TileState state = [board tileStateAtLocation:[BoardLocation locationWithRow:row col:col]];
            
            Tile *tile = [Tile tileWithLetter:[board.chain letterForWord:row atIndex:col] row:row col:col];
            tile.tileState = state;
            
            // Position the tile (Starting at the top left of the board)
            tile.position = ccp([tile boundingBox].size.width * col, self.contentSize.height - [tile boundingBox].size.height * row);
            [self addChild:tile];
            
        }
    }
}
-(void)updateBoard {
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    for (id child in self.children) {
        // Is it a tile?
        if ([child isKindOfClass:[Tile class]]) {
            
            // Get the tilestate from the model
            Tile *tile = (Tile*)child;
            BoardLocation *bl = [BoardLocation locationWithRow:tile.row col:tile.col];
            
            // Need to see if the letter has changed
            NSString *newLetter = [board letterAtLocation:bl];
            if (newLetter == nil || [newLetter caseInsensitiveCompare:tile.letter] != NSOrderedSame) {
                tile.letter = newLetter;
            }
            
            TileState state = [board tileStateAtLocation:[BoardLocation locationWithRow:tile.row col:tile.col]];
            tile.tileState = state;
        }
    }
}
-(void)updateHud {
    HudLayer *hud = (HudLayer*) [[CCDirector sharedDirector].runningScene getChildByTag:kHudLayerTag];
    [hud updateHud];
}
#pragma mark -
-(Tile*)tileAtLocation:(BoardLocation *)boardLocation {
    
    for (id child in self.children) {
        // Is it a tile?
        if ([child isKindOfClass:[Tile class]]) {
            
            Tile *tile = (Tile*)child;
            if (tile.row == boardLocation.row && tile.col == boardLocation.col) {
                return tile;
            }
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Game Logic
-(void)playTile:(Tile *)tile {
    [tile play];
    
    lastPlayedTile = tile;
//    [self promptForGuess:tile];
    GuessScene *guessScene = [GuessScene nodeWithGuessLocation:[BoardLocation locationWithRow:tile.row col:tile.col]];
    [[CCDirector sharedDirector] pushScene:guessScene ];

}

-(NSString*)visibleTextForRow:(NSUInteger)row {
    
    // Get Model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    return [board solvedTextForRow:row];
}
                          
-(void)dealloc {
    [super dealloc];
    [guessView release];
    [hiddenTextField release];
}
                                 

@end
