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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_ipad.plist"];
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_ipad.png"];
        } else {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_iphone.plist"];
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_iphone.png"];
        }
        [self addChild:spriteSheet z:0];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        
        // Create the board, inset it a bit
        BoardLayer *boardLayer = [BoardLayer node];
        boardLayer.contentSize = CGSizeMake((screenSize.width * 2 / 3),screenSize.height);
        boardLayer.position = ccp(0,0);
        [self addChild:boardLayer];
        //[self addChild:board z:0 tag:kBoardTag];
        
        [self scheduleUpdate];
    }
    
    return self;
}

#pragma mark Update Method
-(void) update:(ccTime)deltaTime {
}

@end
