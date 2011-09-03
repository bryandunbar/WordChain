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
-(void)promptForGuess:(Tile*)tile;
-(NSString*)visibleTextForRow:(NSUInteger)row;
-(void)zoomToRow:(Tile*)tile;
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
        [self updateBoard];
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
    [[CCDirector sharedDirector] pushScene:guessScene];

}

-(void)promptForGuess:(Tile*)tile {

    [self zoomToRow:tile];
    
    
    if (!guessView) {
        self.guessView = (GuessView*)[[[NSBundle mainBundle] loadNibNamed:@"GuessView" owner:self options:nil] objectAtIndex:0];
        guessView.delegate = self;
    }
    
    
    if (!hiddenTextField) {
        self.hiddenTextField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        [[[[CCDirector sharedDirector] openGLView] window] addSubview:hiddenTextField];
        hiddenTextField.inputAccessoryView = guessView;
    }
    
    // Set the text and show the keyboard
    guessView.textField.text = [self visibleTextForRow:tile.row];
    [hiddenTextField becomeFirstResponder];
    [guessView.textField becomeFirstResponder];
}

-(void)zoomToRow:(Tile*)tile {

    // Reposition
    float newY = self.contentSize.height - tile.position.y;
    [self runAction:[CCMoveTo actionWithDuration:0.25 position:ccp(self.position.x, newY)]];
}
-(void)zoomOut {
    [self runAction:[CCMoveTo actionWithDuration:0.25 position:ccp(self.position.x,0)]];
}
-(void)didGuess:(GuessView*)gv guess:(NSString *)g {

    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    
    // Reshow the whole board
    [self zoomOut];
    
    // Check the guess
    [gameData guess:g forWordAtIndex:lastPlayedTile.row];
    
    // Did they answer it right?
    if ([gameData.board.chain isWordSolved:lastPlayedTile.row]) {
        // Show a superlative in the middle of the screen :)
        
        CGSize size = [self contentSize];
        CCLabelBMFont * feedTxt = [CCLabelBMFont labelWithString:RAND_SUPERLATIVE fntFile:@"feedbackFont.fnt"];
        feedTxt.scale = 5;
        [self addChild:feedTxt z:50];
        
        [feedTxt setPosition:ccp(size.width / 2, size.height / 2)];
        [feedTxt setColor:ccRED];
        [feedTxt runAction:[CCSequence actions:[CCFadeIn
                                                actionWithDuration:.5],
                            [CCDelayTime actionWithDuration:.25],[CCFadeOut
                                                                actionWithDuration:.5],
                            [CCCallFuncN actionWithTarget:self selector:@
                             selector(removeSprite:)],
                            nil]];
    }
    
    if (gameData.isGameOver) {
        [[GameManager sharedGameManager] runSceneWithID:SceneTypeMainMenu];
    }
    
    // Update View
    [self updateBoard];
    [self updateHud];
}

-(void)removeSprite:(CCNode *)n {
    [self removeChild:n cleanup:YES];
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
