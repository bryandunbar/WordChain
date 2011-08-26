//
//  Board.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Board.h"

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
@synthesize chain, selectableTiles;
@synthesize guessView, hiddenTextField;

#pragma mark -
#pragma mark Initialization
-(id)initWithColor:(ccColor4B)color {
    if (self = [super initWithColor:color]) {
        // Register for touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}
-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h {
    if (self = [super initWithColor:color width:w height:h]) {
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
    
    self.selectableTiles = [NSMutableArray arrayWithCapacity:2];
    if (highestSelectableRow != -1 && lowestSelectableRow != -1) {
        
        // The first unplayed tile in each selectable row is selectable
        for (int i = 0; i < [[chain wordAtIndex:highestSelectableRow] length]; i++) {
            Tile *tile = [self tileForRow:highestSelectableRow col:i];
            
            if (tile.tileState == TileStateSelectable || tile.tileState == TileStateInitialized) {
                tile.tileState = TileStateSelectable;
                [selectableTiles addObject:tile];
                break;
            }
        }
        
        // Only do the lowest row if its not the same as the highest row
        if (highestSelectableRow != lowestSelectableRow) {
            for (int i = 0; i < [[chain wordAtIndex:lowestSelectableRow] length]; i++) {
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
-(void)didGuess:(GuessView*)gv guess:(NSString *)g {

    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    
    // Check the guess
    if ([chain guess:g forWordAtIndex:lastPlayedTile.row]) {
        // User guessed right
    }
    
    // Update game state
    [self updateTileStates];
}
-(NSString*)visibleTextForRow:(NSUInteger)row {
    NSString *word = [chain wordAtIndex:row];
    
    int count = 0;
    for (int i = 0; i < [word length]; i++) {
        Tile *tile = grid[row][i];
        if (tile.tileState == TileStatePlayed) count++;
    }
    return [word substringToIndex:count];
}
                          
-(void)dealloc {
    [super dealloc];
    [chain release];
    [selectableTiles release];
    [guessView release];
    [hiddenTextField release];
}
                                 

@end
