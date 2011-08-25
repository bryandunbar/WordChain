//
//  GameplayLayer.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GameplayLayer.h"

@implementation GameplayLayer

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        // Load the main Texture Atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Letters.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"Letters.png"];
        [self addChild:spriteSheet z:0];
        
        
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        // Create the board
        Board *board = [Board layerWithColor:ccc4(255, 255, 255, 255) width:(screenSize.width * 2 / 3) height:screenSize.height];
        [board newChain];
        [self addChild:board z:0 tag:kBoardTag];
        
        [self scheduleUpdate];
    }
    
    return self;
}

#pragma mark Update Method
-(void) update:(ccTime)deltaTime {
}

@end
