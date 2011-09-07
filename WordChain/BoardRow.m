//
//  BoardRow.m
//  WordChain
//
//  Created by Bryan Dunbar on 9/6/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "BoardRow.h"
#import "Tile.h"
#import "GameState.h"
#import "BoardLayer.h"

@interface BoardRow()
-(Tile*)tileAtLocation:(BoardLocation *)boardLocation;
-(BOOL)selectTileForTouch:(CGPoint)touchLocation;
@end

@implementation BoardRow
@synthesize sprite,row,state,tiles;

-(id)init {
    if ((self = [super init])) {
        self.sprite = [[[CCSprite alloc] initWithSpriteFrameName:@"unsolved_row.png"] autorelease];
        sprite.anchorPoint = ccp(0,1);
        row = 0;
        [self addChild:sprite];
    }
    return self;
}

-(void)setTiles:(NSMutableArray *)tiles {
    
    for (int i = 0; i < [tiles count]; i++) {
        
        int tag = kTileStartingTag + i;
        
        // Remove if it's there already
        if ([self getChildByTag:tag])
            [self removeChildByTag:tag cleanup:YES];
        
        // Add it back
        Tile *tile = [tiles objectAtIndex:i];
        tile.position = ccp((i * tile.boundingBox.size.width), 0);
        [self addChild:tile z:5 tag:tag];
        
        
    }
}
        
-(void)setState:(BoardRowState)newState {
    // Store the new state
    self->state = newState;
    
    // Set the frame based on this
    if (newState == BoardRowUnsolved) {
        [sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"unsolved_row.png"]];
    } else if (newState == BoardRowSolved) {
        [sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solved_row.png"]];
    }    
}

#pragma mark -
#pragma mark CCNode overrides
-(CGSize)contentSize {
    return sprite.contentSize;
}

-(CGRect)boundingBox {
    return sprite.boundingBox;
}

#pragma mark CCRGBAProtocol
-(ccColor3B)color {
    return sprite.color;
}
-(void)setColor:(ccColor3B)color {
    sprite.color = color;
}
-(GLubyte)opacity {
    return sprite.opacity;
}
-(void)setOpacity:(GLubyte)opacity {
    sprite.opacity = opacity;
}

-(void)dealloc {
    [super dealloc];
    [sprite release];
}



@end
