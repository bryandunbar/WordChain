//
//  GameScene.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GameScene.h"
#import "GameState.h"

@implementation GameScene

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // Gameplay Layer
        GameplayLayer *gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:5 tag:kGameLayerTag];
        
        // Hud Layer
        GameModes gameMode = [GameState sharedInstance].gameMode;
        HudLayer *hudLayer = nil;
        switch (gameMode) {
            case GameModeSinglePlayer:
                
                break;
            case GameModeTwoPlayer:
                hudLayer = [TwoPlayerHud node];
            default:
                break;
        }
        
        [self addChild:hudLayer z:5 tag:kHudLayerTag];
        
    }
    return self;
}

+(HudLayer*)hudLayer {
    return (HudLayer*) [[CCDirector sharedDirector].runningScene getChildByTag:kHudLayerTag];
}
+(TimerLayer*)timerLayer {
    HudLayer *hud = [GameScene hudLayer];
    return (TimerLayer *)[hud getChildByTag:kTimerLayerTag];
}

@end
