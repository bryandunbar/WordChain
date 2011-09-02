//
//  TwoPlayerGame.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseGame.h"
#import "Constants.h"
#import "Board.h"

typedef enum {
    PlayerOne,
    PlayerTwo
} PlayerType;

@interface TwoPlayerGame : BaseGame <NSCoding> {
    NSString *player1;
    NSString *player2;
    
    PlayerType whoseTurn;
    
    int player1Score;
    int player2Score;
    
}

@property (nonatomic,retain) NSString *player1;
@property (nonatomic,retain) NSString *player2;
@property (nonatomic,assign) PlayerType whoseTurn;
@property (nonatomic,assign) int player1Score;
@property (nonatomic,assign) int player2Score;

+(TwoPlayerGame*)currentGame;

@end
