//
//  BoardLayer.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "Tile.h"
#import "Chain.h"
#import "GuessView.h"
#import "Board.h"
#import "TimerLayer.h"
#import "GuessScene.h"

#define kRowFadeDuration 0.5
//#define kRowAnimationDuration 0.35
#define kRowAnimationDuration 0.25
#define kRowEaseFactor 1.35
//#define kRowAnimationMoveDelayFactor 0.45
#define kRowAnimationMoveDelayFactor 0.4
#define kRowTagStart 1000

@interface BoardLayer : CCLayerColor <CCTargetedTouchDelegate, TimerLayerDelegate, GuessSceneDelegate> {
    Tile *lastPlayedTile;
    
    NSMutableArray *animatingRows;
}

-(void)guessDidComplete;
-(void)gameDidComplete;
    
-(void)layoutBoard;
-(Tile*)tileAtLocation:(BoardLocation*)boardLocation;
-(void)playTile:(Tile*)tile;
-(void)handleTimerExpired;
@end
