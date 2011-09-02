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

@interface BaseGame : NSObject <NSCoding, GameData> {

    // What round is currently being played
    int round;

    /** The Board **/
    Board *board;

}

@property (nonatomic,assign) int round;
@property (nonatomic,retain) Board *board;


-(void)reset;
+(BaseGame*)newGame;

-(BOOL)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx;

@end
