//
//  GameScene.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "GameplayLayer.h"
#import "HudLayer.h"
#import "SinglePlayerHud.h"
#import "TwoPlayerHud.h"
#import "TimerLayer.h"

@interface GameScene : CCScene {
    
}

+(HudLayer*)hudLayer;
+(TimerLayer*)timerLayer;

@end
