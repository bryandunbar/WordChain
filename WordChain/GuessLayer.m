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
#import "TimerLayer.h"
#import "BoardRow.h"

@interface GuessLayer ()
-(void)promptForGuess;
-(void)didGuess:(GuessView*)gv guess:(NSString*)g;
-(NSString*)visibleTextForRow:(NSUInteger)row;
-(int)fontSize;


-(void)animateGuess:(BOOL)solved;
-(void)guessAnimationDidFinish:(CCNode*)node solved:(BOOL)didSolve;

-(void)showGuessFeedback:(BOOL)solved;
-(void)guessFeedbackAnimationDidFinish:(CCNode*)node;

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
        
        // Show the timer
        timerLayer = [TimerLayer node];
        timerLayer.delegate = self;
        [self addChild:timerLayer z:0 tag:kTimerLayerTag];
        [timerLayer startTimer];
    }
    
    return self;
}

+(id)nodeWithGuessLocation:(BoardLocation *)location {
    return [[[self alloc] initWithGuessLocation:location] autorelease];
}

#pragma mark -
#pragma mark Guess Word Rendering
-(void)layoutGameWords{
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    CCLabelTTF *label;
    int ypadding = 0;
    NSString *labelText;
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        if ([gameData.board.chain isWordSolved:row]) {
            labelText = [gameData.board.chain wordAtIndex:row];
        }
        else if(row == self.guessLocation.row) {
            labelText = @"  ";            
        }
        else {
            labelText = @"___";
            for (int col = 0; col<=[[gameData.board.chain wordAtIndex:row] length]; col++) {
                if ([gameData.board tileStateAtLocation:[BoardLocation locationWithRow:row col:col]] == TileStatePlayed) {
                    //append
                    if (col==0) {
                        labelText = [gameData.board.chain letterForWord:row atIndex:col];
                    }
                    else {
                        labelText = [labelText stringByAppendingString:[gameData.board.chain letterForWord:row atIndex:col]];
                    }
                }
                else {
                    break;
                }
            }
        }
        
        label = [CCLabelTTF labelWithString:[labelText lowercaseString] fontName:@"Marker Felt" fontSize:[self fontSize]]; 
        [label setColor:ccc3(255, 255, 255)];
        label.anchorPoint = ccp(0,0.5);
        int ypos = self.contentSize.height - 20 - (row * [label boundingBox].size.height + 0) - ypadding;
        ypadding += 3;
        [label setPosition:ccp(5,ypos)];
        
        [self addChild:label];    
        
    }

}

-(void)layoutGuessTiles {
    
    // Calculate the starting x and y
    CGSize winSize = [CCDirector sharedDirector].winSize;
    Tile *dummyTileForSize = [Tile tileWithLetter:@"A" row:0 col:0];
    float wordLength = dummyTileForSize.boundingBox.size.width * BOARD_GRID_COLUMNS;
    
    
    int position_x = (winSize.width - wordLength) / 2;
    int position_y = self.contentSize.height - dummyTileForSize.boundingBox.size.height + 5;
    
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    // Create a board row and position it
    BoardRow *boardRow = [BoardRow node];
    boardRow.position = ccp(position_x, position_y);
    
     // Add a tile at every position
    CCArray *tileArray = [CCArray arrayWithCapacity:BOARD_GRID_COLUMNS];
    for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
                    
        // Get the tilestate from the model
        TileState state = [board tileStateAtLocation:[BoardLocation locationWithRow:self.guessLocation.row col:col]];
        
        Tile *tile = [Tile tileWithLetter:[board.chain letterForWord:self.guessLocation.row atIndex:col] row:guessLocation.row col:col];
        tile.tileState = state == TileStateSelectable ? TileStateInitialized : state; // Don't use the selectable state here
        
        [tileArray addObject:tile];
    }
    // Set the tiles in the board row
    boardRow.tiles = tileArray;

    [self addChild:boardRow z:0 tag:kTagBoardRow];
    
    // Add A Label if this is the last letter
    if ([gameData.board isLastLetterForWord:guessLocation]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelTTF *lastLetterLabel = [CCLabelTTF labelWithString:@"Last Letter" fontName:@"Marker Felt" fontSize:[self fontSize]];
        lastLetterLabel.position = ccp((winSize.width - lastLetterLabel.boundingBox.size.width )/ 2, position_y - dummyTileForSize.boundingBox.size.height);
        lastLetterLabel.anchorPoint = ccp(0,1.5);
        [self addChild:lastLetterLabel];
        
        // Animate the tile as well
        [[boardRow tileAtIndex:self.guessLocation.col] startAnimating];
    }                             
    

}

-(void)promptForGuess {
        
    if (!guessView) {
        self.guessView = (GuessView*)[[[NSBundle mainBundle] loadNibNamed:@"GuessView" owner:self options:nil] objectAtIndex:0];
        guessView.delegate = self;
    }
    [self layoutGameWords];

    
    [self layoutGuessTiles];
    if (!hiddenTextField) {
        self.hiddenTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [[[[CCDirector sharedDirector] openGLView] window] addSubview:hiddenTextField];
        hiddenTextField.inputAccessoryView = guessView;
    }
    self.guessView.textField.text = [self visibleTextForRow:self.guessLocation.row];
    // Set the text and show the keyboard
    [hiddenTextField becomeFirstResponder];
    [guessView.textField becomeFirstResponder];
}

-(void)prepareSceneForPop {
    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];

    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    [board updateGameData];    
}

-(void)didCompleteGuess {
    [self prepareSceneForPop];
    GuessScene *guessScene = (GuessScene*)self.parent;
    [guessScene.delegate guessDidComplete];            
}

-(void)didCompleteGame {
    GuessScene *guessScene = (GuessScene*)self.parent;
    [guessScene.delegate gameDidComplete];            
}

-(void)didGuess:(GuessView*)gv guess:(NSString *)g {

    // Don't allow a second guess
    guessView.button.enabled = NO;
    guessView.textField.enabled = NO;

    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    
    // Check the guess
    [gameData guess:g forWordAtIndex:self.guessLocation.row];
    
    // Did they answer it right?
    if ([gameData.board.chain isWordSolved:self.guessLocation.row]) {
        [self animateGuess:YES];
    }
    else {
        if ([gameData isGameOverWithSender:self]) {
            //do nothing
            [timerLayer stopTimer];
            [self prepareSceneForPop]; //well... almost nothing
        }
        else {
            [self animateGuess:NO];
        }
    }
}


#pragma mark - 
#pragma mark - Animation
-(void)animateGuess:(BOOL)solved {
    
    BaseGame *gameData = [GameState sharedInstance].gameData;
    BoardRow *boardRow = (BoardRow*)[self getChildByTag:kTagBoardRow];
    BOOL isLastLetter = [gameData.board isLastLetterForWord:guessLocation];
    
    // First stop the last tile from animating
    if (isLastLetter) {
        [[boardRow tileAtIndex:self.guessLocation.col] stopAnimating];
    }
    
    // Tell the row to animate
    int min = isLastLetter ? guessLocation.col : guessLocation.col + 1;
    [boardRow animateRowToIndex:min solved:solved completion:^{
            [self guessAnimationDidFinish:nil solved:solved];
    }];
    
}

-(void)guessAnimationDidFinish:(CCNode *)n solved:(BOOL)didSolve{
    if (n) [self removeChild:n cleanup:YES]; 
    [self showGuessFeedback:didSolve];
}

-(void)showGuessFeedback:(BOOL)solved {
    
    NSString *text = solved ? RAND_SUPERLATIVE : RAND_NOT_SUPERLATIVE;
    ccColor3B color = solved ? ccGREEN : ccRED;
    
    CGSize size = [self contentSize];
    CCLabelBMFont * feedTxt = [CCLabelBMFont labelWithString:text fntFile:@"Arial.fnt"];
    feedTxt.opacity = 0;
    [self addChild:feedTxt z:50];
    
    [feedTxt setPosition:ccp(size.width / 2, size.height - feedTxt.contentSize.height)];
    [feedTxt setColor:color];
    [feedTxt runAction:[CCSequence actions:[CCFadeIn
                                            actionWithDuration:.25],
                        [CCDelayTime actionWithDuration:1.0],[CCFadeOut
                                                              actionWithDuration:.25],
                        [CCCallFuncN actionWithTarget:self selector:@
                         selector(guessFeedbackAnimationDidFinish:)],
                        nil]];
}
-(void)guessFeedbackAnimationDidFinish:(CCNode *)node {
    
    if (node) [self removeChild:node cleanup:YES];
    [self didCompleteGuess];
}

#pragma mark -

-(NSString*)visibleTextForRow:(NSUInteger)row {
    
    // Get Model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    return [board solvedTextForRow:row];
}
 
 -(int)fontSize {
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         return 40;
     else
         return 13;
 }

-(void)handleTimerExpired {
    [self didGuess:nil guess:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self didCompleteGame];
}


@end
