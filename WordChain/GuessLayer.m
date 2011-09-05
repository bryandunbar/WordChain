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
-(int)fontSize;

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
    
     // Add a tile at every position
    for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
                    
        // Get the tilestate from the model
        TileState state = [board tileStateAtLocation:[BoardLocation locationWithRow:guessLocation.row col:col]];
        
        Tile *tile = [Tile tileWithLetter:[board.chain letterForWord:guessLocation.row atIndex:col] row:guessLocation.row col:col];
        tile.tileState = state;
        
        // Position the tile 
        tile.position = ccp([tile boundingBox].size.width * col + position_x, position_y);
        [self addChild:tile];
    }
    
    // Add A Label if this is the last letter
    if ([gameData.board isLastLetterForWord:guessLocation]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelTTF *lastLetterLabel = [CCLabelTTF labelWithString:@"Last Letter" fontName:@"Marker Felt" fontSize:[self fontSize]];
        lastLetterLabel.position = ccp((winSize.width - lastLetterLabel.boundingBox.size.width )/ 2, position_y - dummyTileForSize.boundingBox.size.height);
        lastLetterLabel.anchorPoint = ccp(0,1.5);
        [self addChild:lastLetterLabel];
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
    //guessView.textField.text = [self visibleTextForRow:tile.row];
    [hiddenTextField becomeFirstResponder];
    [guessView.textField becomeFirstResponder];
 
}

-(void)popScene {
    // Hide the keyboard
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    [board updateGameData];
    
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    [[CCDirector sharedDirector]popScene];    
}

-(void)didGuess:(GuessView*)gv guess:(NSString *)g {
    
    // Get the model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    
/*    // Hide the keyboard
    [guessView.textField resignFirstResponder];
    [hiddenTextField resignFirstResponder];
    [[CCDirector sharedDirector]popScene];*/

    // Check the guess
    [gameData guess:g forWordAtIndex:self.guessLocation.row];
    
    // Did they answer it right?
    if ([gameData.board.chain isWordSolved:self.guessLocation.row]) {
    
        CGSize size = [self contentSize];
        CCLabelBMFont * feedTxt = [CCLabelBMFont labelWithString:RAND_SUPERLATIVE fntFile:@"feedbackFont.fnt"];
        feedTxt.scale = 5;
        [self addChild:feedTxt z:50];
        
        [feedTxt setPosition:ccp(size.width / 2, size.height - 60)];
        [feedTxt setColor:ccRED];
        [feedTxt runAction:[CCSequence actions:[CCFadeIn
                                                actionWithDuration:.5],
                            [CCDelayTime actionWithDuration:.25],[CCFadeOut
                                                                  actionWithDuration:.5],
                            [CCCallFuncN actionWithTarget:self selector:@
                             selector(removeSprite:)],
                            nil]];
    }
    else {
        [self popScene];
    }
    
//    if (gameData.isGameOver) {
//        [[GameManager sharedGameManager] runSceneWithID:SceneTypeMainMenu];
//    }
    
}

-(void)removeSprite:(CCNode *)n {
    [self removeChild:n cleanup:YES];
    [self popScene];
    
}

-(NSString*)visibleTextForRow:(NSUInteger)row {
    
    // Get Model
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    return [board solvedTextForRow:row];
}
 
 -(int)fontSize {
     int fontSize = -1;
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         return 40;
     else
         return 13;
 }
@end
