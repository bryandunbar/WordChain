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
#import "TimerLayer.h"
#import "BoardRow.h"
#import "GameScene.h"

@interface BoardLayer()
-(NSString*)visibleTextForRow:(NSUInteger)row;
-(void)updateBoard;
-(void)updateHud;
-(void)updateTimer;

-(void)animateBoard;
-(CGPoint)locationForRow:(BoardRow*)row;

-(int)rowPadding;

@property (nonatomic,retain) NSMutableArray *animatingRows;
@end

@implementation BoardLayer
@synthesize animatingRows;

#pragma mark -
#pragma mark Initialization
-(id)init {
    if (self = [super initWithColor:ccc4(200, 200, 200, 255)]) {
        // Register for touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        [self layoutBoard];
    }
    return self;
}

-(void)guessDidReturn {
    [self updateTimer];
    [self updateBoard];
    [self updateHud];
    [[GameScene timerLayer] startTimer];            
}

- (void)onEnter
{
    [super onEnter];
    
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    
    
    // Is the board still considered new?
    if (gameData.board.isNew) {
        [self updateBoard];
        [self animateBoard]; // Animates the board in
    } 
    else {
        [self guessDidReturn];
    }
}

#pragma mark -
#pragma mark Guess Scene Delegate methods

-(void)guessDidComplete {
    [[CCDirector sharedDirector] popScene];
}

-(void)gameDidComplete {
    [[CCDirector sharedDirector] popScene];
    [[GameManager sharedGameManager] runSceneWithID:SceneTypeMainMenu];     
}

#pragma mark -
#pragma mark Toches
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event { 
    
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    for (BoardLocation *boardLocation in board.selectableTiles) {
        
        // Find the actual tile for this location
        Tile *tile = [self tileAtLocation:boardLocation];
        
        CGPoint touchLocation = [tile convertTouchToNodeSpace:touch];
        CCLOG(@"touchLocaton = %@", NSStringFromCGPoint(touchLocation));
        CCLOG(@"tile.rect = %@", NSStringFromCGRect([tile rect]));
        CCLOG(@"tile.boundingBox = %@", NSStringFromCGRect([tile boundingBox]));
        
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
-(CGPoint)locationForRow:(BoardRow*)boardRow {
    return ccp(5, self.contentSize.height - (boardRow.boundingBox.size.height * boardRow.row) - ([self rowPadding] * (boardRow.row + 1)));

}
-(void)animateBoard {
    
    // Stop timer while we are doing this
    [[GameScene timerLayer] stopTimer];
    
    self.animatingRows = [CCArray arrayWithCapacity:BOARD_GRID_ROWS];
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        
        // Grab the row
        int tag = kRowTagStart + row;
        BoardRow *boardRow = (BoardRow*)[self getChildByTag:tag];
        
        // Move it to above the screen and hide it
        boardRow.position = ccp(5, self.contentSize.height + 2 * boardRow.boundingBox.size.height);
        [animatingRows addObject:boardRow];
        
        // Determine where the row should end up
        CGPoint finalRestingPlace = [self locationForRow:boardRow];
        
        // Run a sequence of actions to place the row
        id moveAction = [CCMoveTo actionWithDuration:kRowAnimationDuration position:finalRestingPlace];
        id delayAction = [CCDelayTime actionWithDuration:powf( (BOARD_GRID_ROWS - row - 1) * kRowAnimationMoveDelayFactor, kRowEaseFactor)];
        //        id delayAction = [CCDelayTime actionWithDuration:logf( (BOARD_GRID_ROWS - row + 1) * kRowAnimationMoveDelayFactor)];
        id ease = [CCEaseOut actionWithAction:moveAction rate:2.0];
        id callFuncND = [CCCallFuncND actionWithTarget:self selector:@selector(boardRowAnimationComplete:) data:boardRow];
        id sequence = [CCSequence actions:delayAction, ease, callFuncND, nil];
        [boardRow runAction:sequence];
    }
}
-(void)boardRowAnimationComplete:(void*)data {
    
    [animatingRows removeObject:data];
    
    // Are all the board row animations complete?
    if ([animatingRows count] == 0) {
    
        // Done animating the board in, set the board to not new and start the round
        BaseGame *gameData = [GameState sharedInstance].gameData;
        Board *board = gameData.board;
        board.isNew = NO;
        
        // Solve the first and last words
        [board.chain solveWordAtIndex:0];
        [board.chain solveWordAtIndex:[board.chain length] - 1];
        [board updateGameData];
        
        // Refresh the UI
        [self updateBoard];
        [self updateHud];
        [self updateTimer];
        
        // Start the timer
        [[GameScene timerLayer] startTimer];
    }                         
}


// Initializes the grid of rows/tiles
-(void)layoutBoard {

    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;

    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        
        // Create a new row
        BoardRow *boardRow = [BoardRow node];
        boardRow.row = row;
        
        // Populate the row with tiles
        NSMutableArray *tileArray = [NSMutableArray arrayWithCapacity:BOARD_GRID_COLUMNS];
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            
            // Get the tilestate
            TileState state = board.isNew ? TileStateInitialized : [board tileStateAtLocation:[BoardLocation locationWithRow:row col:col]];
            
            Tile *tile = [Tile tileWithLetter:[board.chain letterForWord:row atIndex:col] row:row col:col];
            tile.tileState = state;
            [tileArray addObject:tile];
        }

        // Set the tiles
        boardRow.tiles = tileArray;
        
        // if the board is not new, place the row where it goes
        if (!board.isNew) {
            boardRow.position = [self locationForRow:boardRow];
        }
        [self addChild:boardRow z:0 tag:kRowTagStart + row];
    }
}

-(void)updateBoard {
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    for (id child in self.children) {
        
        if ([child isKindOfClass:[BoardRow class]]) {
            // Set the state of the row
            BoardRow *boardRow = (BoardRow*)child;
            boardRow.state = [board.chain isWordSolved:boardRow.row] ? BoardRowSolved : BoardRowUnsolved;
            
            
            // Set the tile states in the row
            for (id child2 in [boardRow children]) {
                if ([child2 isKindOfClass:[Tile class]]) {
                    
                    // Get the tilestate from the model
                    Tile *tile = (Tile*)child2;
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
    }
}
-(void)updateHud {
    HudLayer *hud = [GameScene hudLayer];
    [hud updateHud];
}

-(void)updateTimer {
    TimerLayer *timerLayer = [GameScene timerLayer];
    if (timerLayer) {
        timerLayer.delegate = self; //redundant to do this here, but saves repeating this logic
        [timerLayer updateTimer];   
    }
    else {
        NSLog(@"timer layer not found");
    }
}

#pragma mark -
-(Tile*)tileAtLocation:(BoardLocation *)boardLocation {
    
    for (id child in self.children) {
        
        if ([child isKindOfClass:[BoardRow class]]) {
            
            BoardRow *boardRow = (BoardRow*)child;
            for (id child2 in [boardRow children]) {
                // Is it a tile?
                if ([child2 isKindOfClass:[Tile class]]) {
                    
                    Tile *tile = (Tile*)child2;
                    if (tile.row == boardLocation.row && tile.col == boardLocation.col) {
                        return tile;
                    }
                }
            }
        }
        
    }
    return nil;
}

-(void)handleTimerExpired {
    BaseGame *gameData = [GameState sharedInstance].gameData;
    [gameData turnTimeExpired];
    [self updateTimer];
    [self updateHud];
}

#pragma mark -
#pragma mark Game Logic
-(void)playTile:(Tile *)tile {
    [tile play];
    
    lastPlayedTile = tile;

    // push the guess scene
    GuessScene *guessScene = [GuessScene nodeWithGuessLocation:[BoardLocation locationWithRow:tile.row col:tile.col]];
    guessScene.delegate = self;
    [[CCDirector sharedDirector] pushScene:guessScene ];

}

-(NSString*)visibleTextForRow:(NSUInteger)row {
    
    // Get Model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    return [board solvedTextForRow:row];
}
        
-(int)rowPadding {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 10;
    } else {
        return 5;
    }
}
-(void)dealloc {
    [super dealloc];
    [animatingRows release];
}
                                 

@end
