//
//  GuessLayer.m
//  WordChain
//
//  Created by Clay Tinnell on 8/31/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GuessLayer.h"
#import "BaseGame.h"
#import "Board.h"
#import "CCDirector.h"
#import "GameState.h"
#import "Tile.h"
#import "GuessScene.h"

@interface GuessLayer ()
-(void)promptForGuess;
-(void)didGuess:(GuessView*)gv guess:(NSString*)g;
-(NSString*)visibleTextForRow:(NSUInteger)row;

@property (nonatomic,retain) GuessView *guessView;
@property (nonatomic,retain) UITextField *hiddenTextField;
@property (nonatomic,retain) BoardLocation *guessLocation;

@end

@implementation GuessLayer
@synthesize guessView, hiddenTextField, guessLocation;

- (id)initWithGuessLocation:(BoardLocation *)location 
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.guessLocation = location;
        [self promptForGuess];
    }
    
    return self;
}

+(id)nodeWithGuessLocation:(BoardLocation *)location {
    return [[[self alloc] initWithGuessLocation:location] autorelease];
}

#pragma mark -
#pragma mark Board Rendering
-(void)layoutGuessTiles {
    int position_x = 75;
    int position_y = 5;
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    NSLog(@"guess location row = %d",guessLocation.row);
    
    // Add a tile at every position
    for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
                    
        // Get the tilestate from the model
        TileState state = [board tileStateAtLocation:[BoardLocation locationWithRow:guessLocation.row col:col]];
        
        Tile *tile = [Tile tileWithLetter:[board.chain letterForWord:guessLocation.row atIndex:col] row:guessLocation.row col:col];
        tile.tileState = state;
        
        // Position the tile (Starting at the top left of the board)
        tile.position = ccp([tile boundingBox].size.width * col + position_x, self.contentSize.height - [tile boundingBox].size.height + position_y);
        [self addChild:tile];
    }
}

-(void)promptForGuess {
        
    if (!guessView) {
        self.guessView = (GuessView*)[[[NSBundle mainBundle] loadNibNamed:@"GuessView" owner:self options:nil] objectAtIndex:0];
        guessView.delegate = self;
    }
    
    [self layoutGuessTiles];
    if (!hiddenTextField) {
        self.hiddenTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [[[[CCDirector sharedDirector] openGLView] window] addSubview:hiddenTextField];
        hiddenTextField.inputAccessoryView = guessView;
    }
    self.guessView.textField.text = [self visibleTextForRow:self.guessLocation.row];
    // Set the text and show the keyboard
    //guessView.textField.text = [self visibleTextForRow:tile.row];
    [hiddenTextField becomeFirstResponder];
    [guessView.textField becomeFirstResponder];
}

-(void)didGuess:(GuessView*)gv guess:(NSString *)g {
    
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    [[CCDirector sharedDirector]popScene];
    // Check the guess
    if ([board.chain guess:g forWordAtIndex:self.guessLocation.row]) {
        // TODO: User guessed right
    }
    
    // Update game model
    [gameData updateGameData];
}
-(NSString*)visibleTextForRow:(NSUInteger)row {
    
    // Get Model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    return [board solvedTextForRow:row];
}
@end
