//
//  GameScene.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // Gameplay Layer
        GameplayLayer *gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:5];
        
    }
    return self;
}

@end
