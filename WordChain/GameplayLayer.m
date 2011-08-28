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

        // Wrap the board in a wrapper layer that is 2/3 screen size
        //CCLayer *boardWrapper = [CCLayer node];
        CCLayer *boardWrapper = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
        [self addChild:boardWrapper];
        boardWrapper.contentSize = CGSizeMake((screenSize.width * 2 / 3),screenSize.height);
        
        // Create the board, inset it a bit
        int boardWidth = boardWrapper.contentSize.width - 10;
        int boardHeight = boardWrapper.contentSize.height - 10;
        Board *board = [Board node];
        board.contentSize = CGSizeMake(boardWidth, boardHeight);
        board.position = ccp(10,0);
        [boardWrapper addChild:board];
        [board newChain];
        //[self addChild:board z:0 tag:kBoardTag];
        
        [self scheduleUpdate];
    }
    
    return self;
}

#pragma mark Update Method
-(void) update:(ccTime)deltaTime {
}

@end
