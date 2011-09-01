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
}

+(BaseGame*)newGame {
    return [[[TwoPlayerGame alloc] init] autorelease];
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
    [encoder encodeObject:player1 forKey:@"Player2"];
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
