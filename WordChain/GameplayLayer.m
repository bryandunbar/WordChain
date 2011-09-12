//
//  GameplayLayer.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GameplayLayer.h"
#import "GameConfig.h"
@implementation GameplayLayer

- (id)init
{
    self = [super initWithColor:ccc4(255, 0, 0, 255)];
    if (self != nil) {
        
        
        // Load the main Texture Atlas
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_ipad.plist"];
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_ipad.png"];
        } else {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_iphone.plist"];
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_iphone.png"];
        }
        [self addChild:spriteSheet z:0];
        
        // Create the board
        BoardLayer *boardLayer = [BoardLayer node];
        [self addChild:boardLayer z:0 tag:kTagBoard];
        
    }
    
    return self;
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [[self getChildByTag:kTagBoard] setContentSize:contentSize];
}

@end
