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
        // TODO: Sprites for other devices
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_ipad.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_ipad.png"];
        [self addChild:spriteSheet z:0];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        // Wrap the board in a wrapper layer that is 2/3 screen size
        //CCLayer *boardWrapper = [CCLayer node];
        CCLayer *boardWrapper = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
        [self addChild:boardWrapper];
        boardWrapper.contentSize = CGSizeMake((screenSize.width * 2 / 3),screenSize.height);
        
        // Create the board, inset it a bit
        int boardWidth = boardWrapper.contentSize.width - 5;
        int boardHeight = boardWrapper.contentSize.height - 5;
        BoardLayer *boardLayer = [BoardLayer node];
        boardLayer.contentSize = CGSizeMake(boardWidth, boardHeight);
        boardLayer.position = ccp(0,0);
        [boardWrapper addChild:boardLayer];
        //[self addChild:board z:0 tag:kBoardTag];
        
        [self scheduleUpdate];
    }
    
    return self;
}

#pragma mark Update Method
-(void) update:(ccTime)deltaTime {
}

@end
