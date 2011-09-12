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
-(CGPoint)locationForRow:(BoardRow*)row;
-(int)rowPadding;

-(void)startTileAnimation:(BoardRow*)row;
-(void)stopTileAnimation;

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
        [self animateBoard:arc4random() % 8]; // Choose a random animation
    } 
    else {
        [self guessDidReturn];
    }
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self layoutBoard];
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
        if (CGRectContainsPoint(tile.boundingBox, touchLocation)) {            
            [self playTile:tile];
            return YES;
        }
    }    
    return NO;
}

#pragma mark -
#pragma mark Board Rendering
-(CGPoint)locationForRow:(BoardRow*)boardRow {
    return ccp(kRowInset, self.contentSize.height - (boardRow.boundingBox.size.height * boardRow.row) - ([self rowPadding] * (boardRow.row + 1)));

}
-(void)startTileAnimation:(BoardRow *)row {
    for (Tile* tile in row.tiles) {
        [tile startAnimating];
    }
}
-(void)stopTileAnimation {
    for (id child in self.children) {
        if ([child isKindOfClass:[BoardRow class]]) {
            BoardRow *row = (BoardRow*)child;
            for (Tile* tile in row.tiles) {
                [tile stopAnimating];
            }
        }
    }
}
-(void)animateBoard:(BoardRowAnimation)boardRowAnimation {
    
    // Stop timer while we are doing this
    [[GameScene timerLayer] stopTimer];
    
    self.animatingRows = [CCArray arrayWithCapacity:BOARD_GRID_ROWS];
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        
        // Grab the row
        int tag = kRowTagStart + row;
        BoardRow *boardRow = (BoardRow*)[self getChildByTag:tag];
        [self startTileAnimation:boardRow];

        // Determine where the row should end up, this is the same for all animation types
        CGPoint finalRestingPlace = [self locationForRow:boardRow];
        
        // Determine the starting position
        CGPoint startingPoint = CGPointZero;
        
        
        CCLOG(@"self.contentSize = %@", NSStringFromCGSize(self.contentSize));
        CCLOG(@"boardRow.boundingBox = %@", NSStringFromCGRect(boardRow.boundingBox));
        
        // start_x
        if (boardRowAnimation == BoardRowAnimationLeftTop || boardRowAnimation == BoardRowAnimationLeftBottom) {
            startingPoint.x = self.position.x - boardRow.boundingBox.size.width;
        } else if (boardRowAnimation == BoardRowAnimationRightTop || boardRowAnimation == BoardRowAnimationRightBottom) {
            startingPoint.x = self.position.x + self.contentSize.width;
        } else if (boardRowAnimation == BoardRowAnimationAlternatingLeftRightTop || boardRowAnimation == BoardRowAnimationAlternatingLeftRightBottom) {
            startingPoint.x = (row % 2 == 0 ? self.position.x - boardRow.boundingBox.size.width : self.position.x + self.contentSize.width);
        } else if (boardRowAnimation == BoardRowAnimationTop || boardRowAnimation == BoardRowAnimationBottom) {
            startingPoint.x = kRowInset;
        }
        
        // start_y
        if (boardRowAnimation > BoardRowAnimationBottom) {
            startingPoint.y = finalRestingPlace.y;
        } else if (boardRowAnimation == BoardRowAnimationTop) {
            startingPoint.y = self.contentSize.height + boardRow.boundingBox.size.height;
        } else if (boardRowAnimation == BoardRowAnimationBottom) {
            startingPoint.y = self.position.y;
        }
            

        // Position the row at its starting point
        boardRow.position = startingPoint;

        
        // Move to where it goes with an ease at the end
        id moveAction = [CCMoveTo actionWithDuration:kRowAnimationDuration position:finalRestingPlace];
        id ease = [CCEaseOut actionWithAction:moveAction rate:2.0];
        
        // Top vs Bottom is based on the amount we delay each row
        id delayAction = nil;
        if (boardRowAnimation == BoardRowAnimationLeftTop || boardRowAnimation == BoardRowAnimationAlternatingLeftRightTop || boardRowAnimation == BoardRowAnimationRightTop ||
            boardRowAnimation == BoardRowAnimationBottom) {
            delayAction = [CCDelayTime actionWithDuration:powf( row * kRowAnimationMoveDelayFactor, kRowEaseFactor)];
            //delayAction = [CCDelayTime actionWithDuration:logf( row * kRowAnimationMoveDelayFactor, kRowEaseFactor)]
        } else {
            delayAction = [CCDelayTime actionWithDuration:powf( (BOARD_GRID_ROWS - row - 1) * kRowAnimationMoveDelayFactor, kRowEaseFactor)];
            //delayAction = [CCDelayTime actionWithDuration:logf( (BOARD_GRID_ROWS - row - 1) * kRowAnimationMoveDelayFactor, kRowEaseFactor)];
        }

        // Sequence them together for this rows animation
        id animationAction = [CCSequence actions:delayAction, ease, nil];
        
        // Queue that holds pending animations, once they are all done the round can start
        [animatingRows addObject:boardRow];
        
        // Run the animation, always add in the callfunc to the end to notify of the animation done
        id callFuncND = [CCCallFuncND actionWithTarget:self selector:@selector(boardRowAnimationComplete:) data:boardRow];
        [boardRow runAction:[CCSequence actions:animationAction, callFuncND, nil]];
    }
}
-(void)boardRowAnimationComplete:(void*)data {
    
    [animatingRows removeObject:data];

    // Are all the board row animations complete?
    if ([animatingRows count] == 0) {

        // Important, stop tile animations before doing any other calls here,
        // because we need to reset the tile states to their real values
        [self stopTileAnimation];
        
        // Done animating the board in, set the board to not new and start the round
        BaseGame *gameData = [GameState sharedInstance].gameData;
        Board *board = gameData.board;
        board.isNew = NO;
        
        // Solve the first and last words
        int firstRowIdx = 0; int lastRowIdx = [board.chain length] - 1;
        [board.chain solveWordAtIndex:firstRowIdx];
        [board.chain solveWordAtIndex:lastRowIdx];
        
        // Animate the two solved rows
        BoardRow *firstRow = (BoardRow*)[self getChildByTag:kRowTagStart + firstRowIdx];
        BoardRow *lastRow = (BoardRow*)[self getChildByTag:kRowTagStart + lastRowIdx];
        [firstRow animateRowToIndex:0 solved:YES completion:^{
            [board updateGameData];

            // Refresh the UI
            [self updateBoard];
            [self updateHud];
            [self updateTimer];
            
            // Start the timer
            [[GameScene timerLayer] startTimer];
        }];
        [lastRow animateRowToIndex:0 solved:YES completion:nil];
        
        
    }                         
}


// Initializes the grid of rows/tiles
-(void)layoutBoard {

    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;

    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        
        BoardRow *boardRow = (BoardRow*)[self getChildByTag:kRowTagStart + row];
        if (boardRow == nil) {
        
            // Create a new row
            BoardRow *boardRow = [BoardRow node];
            boardRow.row = row;
            [self addChild:boardRow z:0 tag:kRowTagStart + row];
        }
        
        // Populate the row with tiles
        CCArray *tileArray = [CCArray arrayWithCapacity:BOARD_GRID_COLUMNS];
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
