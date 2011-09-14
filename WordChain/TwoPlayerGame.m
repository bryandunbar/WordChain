//
//  TwoPlayerGame.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "TwoPlayerGame.h"
#import "GameState.h"

@interface TwoPlayerGame()
-(void)scoreWordAtIndex:(NSUInteger)idx;
@end

@implementation TwoPlayerGame
@synthesize player1, player2, whoseTurn, player1Score, player2Score;
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)reset {
    [super reset];
    self.whoseTurn = PlayerOne;
    self.timer = kTimerDefault;    
    self.player1Score = 0;
    self.player2Score = 0;
    self.player1 = @"Player 1";
    self.player2 = @"Player 2";
    self.nextChain = 0;
}

// Convenience method for grabbing the shared game state as a two player game
+(TwoPlayerGame*)currentGame {
    BaseGame *baseGame = [GameState sharedInstance].gameData;
    
    // Should be a TwoPlayerGame object at this point
    NSAssert([baseGame isKindOfClass:[TwoPlayerGame class]], @"The GameData should be a TwoPlayerGame");
    
    return (TwoPlayerGame*)baseGame;
    
}

+(BaseGame*)newGame {
    return [[[TwoPlayerGame alloc] init] autorelease];
}

#pragma mark -
#pragma mark Game Logic
-(void)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx {
    
    BOOL guessedRight = [board.chain guess:g forWordAtIndex:idx];
    if (!guessedRight) {
        // Next player's turn
        self.whoseTurn = whoseTurn == PlayerOne ? PlayerTwo : PlayerOne;
        self.timer = kTimerDefault;    
    } else {
        [self scoreWordAtIndex:idx];
        
        // Have all the words been solved?
        if ([board.chain isChainSolved]) {
            round++;
            [board newChain];
            self.timer = kTimerDefault;
        }
    }
    [self updateGameData];
}

-(void)turnTimeExpired {
    self.whoseTurn = whoseTurn == PlayerOne ? PlayerTwo : PlayerOne;
    self.timer = kTimerDefault;    
    [self updateGameData];
}

-(BOOL)isGameOverWithSender:(id)sender {
    
    BOOL b = round > 5;
    if (b) {
        
        // Determine the winner
        PlayerType winner = -1;
        if (player1Score > player2Score) {
            winner = PlayerOne;
        } else if (player1Score == player2Score) {
            winner = whoseTurn; // Whoever answered last one wins
        } else {
            winner = PlayerTwo;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" 
                                                        message:[NSString stringWithFormat:@"%@ won!", (winner == PlayerOne) ? player1 : player2] delegate:sender cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
    return b;
}

-(void)scoreWordAtIndex:(NSUInteger)idx {
    // How many letters left in word
    NSUInteger lettersLeftInWord = [board unsolvedCharactersForRow:idx];
    
    //               Word     +         Bonus
    int score = (100 * round) + (100 * lettersLeftInWord);
    
    if (self.whoseTurn == PlayerOne)
        player1Score += score;
    else
        player2Score += score;
}

#pragma mark -
#pragma mark GameData Protocol
-(void)updateGameData {
    [board updateGameData];
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:player1 forKey:@"Player1"];
    [encoder encodeObject:player2 forKey:@"Player2"];
    [encoder encodeInt:whoseTurn forKey:@"WhoseTurn"];
    [encoder encodeInt:player1Score forKey:@"Player1Score"];
    [encoder encodeInt:player2Score forKey:@"Player2Score"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {                
        self.player1 = [decoder decodeObjectForKey:@"Player1"];
        self.player2 = [decoder decodeObjectForKey:@"Player2"];
        self.whoseTurn = [decoder decodeIntForKey:@"WhoseTurn"];
        self.player1Score = [decoder decodeIntForKey:@"Player1Score"];
        self.player2Score = [decoder decodeIntForKey:@"Player2Score"];
    }
    return self;
}



@end
