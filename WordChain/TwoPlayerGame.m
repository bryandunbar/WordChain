//
//  TwoPlayerGame.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "TwoPlayerGame.h"
#import "GameState.h"

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
    self.player1Score = 0;
    self.player2Score = 0;
    self.player1 = @"Player 1";
    self.player2 = @"Player 2";
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
#pragma mark Game Logic Overrides
-(BOOL)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx {
    BOOL guessedRight = [super guess:g forWordAtIndex:idx];
    
    if (!guessedRight) {
        // Next player's turn
        self.whoseTurn = whoseTurn == PlayerOne ? PlayerTwo : PlayerOne;
    }
    
    return guessedRight;
}

#pragma mark -
#pragma mark GameData Procol
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
