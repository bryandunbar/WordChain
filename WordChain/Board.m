//
//  Board.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Board.h"
#import "GameState.h"

@interface Board()
-(void)findSelectableTiles;
-(BOOL)selectTileForTouch:(CGPoint)touchLocation;
-(void)promptForGuess:(Tile*)tile;
-(NSString*)visibleTextForRow:(NSUInteger)row;

@property (nonatomic,retain) NSMutableArray *selectableTiles;
@property (nonatomic,retain) GuessView *guessView;
@property (nonatomic,retain) UITextField *hiddenTextField;
@end

@implementation Board
@synthesize selectableTiles;
@synthesize guessView, hiddenTextField;

#pragma mark -
#pragma mark Initialization
-(id)init {
    if (self = [super init]) {
        // Register for touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}


#pragma mark -
#pragma mark Toches
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    return [self selectTileForTouch:touchLocation];      
}
-(BOOL)selectTileForTouch:(CGPoint)touchLocation {
   
    for (Tile *tile in selectableTiles) {
        if (CGRectContainsPoint(tile.boundingBox, touchLocation)) {            
            CCLOG(@"Touched Tile: row = %i, col = %i", tile.row, tile.col);
            [self playTile:tile];
            return YES;
        }
    }    
    return NO;
}


#pragma mark -
-(void)newChain {
    
    // Instatiate a new chain
    [GameState sharedInstance].chain = [[Chain alloc] init];
    [[GameState sharedInstance] save];
    
    // rebuild the grid
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
            
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            Tile *tile = [Tile tileWithLetter:[[GameState sharedInstance].chain letterForWord:row atIndex:col] row:row col:col];
            grid[row][col] = tile;
            
            // Position the tile (Starting at the top left of the board)
            tile.position = ccp([tile boundingBox].size.width * col, self.contentSize.height - [tile boundingBox].size.height * row);
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
            
            if ([[GameState sharedInstance].chain isWordSolved:row]) {
                tile.tileState = TileStatePlayed;
            }
        }
    }
    
    // Determine where the selectable tiles are. 
    [self findSelectableTiles];
}
-(void)findSelectableTiles {
    NSUInteger highestSelectableRow = [[GameState sharedInstance].chain highestUnsolvedIndex];
    NSUInteger lowestSelectableRow = [[GameState sharedInstance].chain lowestUnsolvedIndex];
    
    self.selectableTiles = [NSMutableArray arrayWithCapacity:2];
    if (highestSelectableRow != -1 && lowestSelectableRow != -1) {
        
        // The first unplayed tile in each selectable row is selectable
        for (int i = 0; i < [[[GameState sharedInstance].chain wordAtIndex:highestSelectableRow] length]; i++) {
            Tile *tile = [self tileForRow:highestSelectableRow col:i];
            
            if (tile.tileState == TileStateSelectable || tile.tileState == TileStateInitialized) {
                tile.tileState = TileStateSelectable;
                [selectableTiles addObject:tile];
                break;
            }
        }
        
        // Only do the lowest row if its not the same as the highest row
        if (highestSelectableRow != lowestSelectableRow) {
            for (int i = 0; i < [[[GameState sharedInstance].chain wordAtIndex:lowestSelectableRow] length]; i++) {
                Tile *tile = [self tileForRow:lowestSelectableRow col:i];

                if (tile.tileState == TileStateSelectable || tile.tileState == TileStateInitialized) {
                    tile.tileState = TileStateSelectable;
                    [selectableTiles addObject:tile];
                    break;
                }
            }
        }

    }
}
         
-(Tile*)tileForRow:(NSUInteger)row col:(NSUInteger)c {
    return grid[row][c];
}

-(void)playTile:(Tile *)tile {
    [tile play];
    
    lastPlayedTile = tile;
    [self promptForGuess:tile];
}

-(void)promptForGuess:(Tile*)tile {

    [self zoomToRow:tile];
    
    
    if (!guessView) {
        self.guessView = (GuessView*)[[[NSBundle mainBundle] loadNibNamed:@"GuessView" owner:self options:nil] objectAtIndex:0];
        guessView.delegate = self;
    }
    
    
    if (!hiddenTextField) {
        self.hiddenTextField = [[UITextField alloc] initWithFrame:CGRectZero];
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

    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    
    [self zoomOut];
    // Check the guess
    if ([[GameState sharedInstance].chain guess:g forWordAtIndex:lastPlayedTile.row]) {
        // TODO: User guessed right
    }
    
    // Update game state
    [[GameState sharedInstance] save];
    [self updateTileStates];
}

-(NSString*)visibleTextForRow:(NSUInteger)row {
    NSString *word = [[GameState sharedInstance].chain wordAtIndex:row];
    
    int count = 0;
    for (int i = 0; i < [word length]; i++) {
        Tile *tile = grid[row][i];
        if (tile.tileState == TileStatePlayed) count++;
    }
    return [[word substringToIndex:count] uppercaseString];
}
                          
-(void)dealloc {
    [super dealloc];
    [selectableTiles release];
    [guessView release];
    [hiddenTextField release];
}
                                 

@end
