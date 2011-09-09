//
//  BaseGame.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Board.h"
#import "Constants.h"

#define kTimerDefault 60

@interface BaseGame : NSObject <NSCoding, GameData> {

    // What round is currently being played
    int round;
    
    // The countdown timer for round
    int timer;

    /** The Board **/
    Board *board;
 
}

@property (nonatomic,assign) int round;
@property (nonatomic,assign) int timer;
@property (nonatomic,retain) Board *board;


-(BOOL)isGameOverWithSender:(id)sender;
-(void)reset;
+(BaseGame*)newGame;

-(void)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx;
-(void)turnTimeExpired;

@end
