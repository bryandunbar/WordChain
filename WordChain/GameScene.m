//
//  GameScene.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GameScene.h"
#import "GameState.h"
#import "GameConfig.h"

@implementation GameScene

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // Gameplay Layer
        GameplayLayer *gameplayLayer = [GameplayLayer node];
        
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
        
        // Size and position the nodes
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        if (ORIENTATION == kCCDeviceOrientationPortrait) {
            gameplayLayer.contentSize = CGSizeMake(screenSize.width, screenSize.width);
            gameplayLayer.position = ccp(0, screenSize.height - gameplayLayer.contentSize.height);
            
            hudLayer.contentSize = CGSizeMake(screenSize.width, screenSize.height - gameplayLayer.contentSize.height);
            hudLayer.position = ccp(0,0);
        } else {
            gameplayLayer.contentSize = CGSizeMake(screenSize.height,screenSize.height);
            gameplayLayer.position = ccp(0,0);
            
            hudLayer.contentSize = CGSizeMake(screenSize.width - gameplayLayer.contentSize.width, screenSize.height);
            hudLayer.position = ccp(gameplayLayer.contentSize.width,0);

        }
        
         // Add the nodes
        [self addChild:gameplayLayer z:0 tag:kGameLayerTag];
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
