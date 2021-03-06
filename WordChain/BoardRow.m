//
//  BoardRow.m
//  WordChain
//
//  Created by Bryan Dunbar on 9/6/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "BoardRow.h"
#import "GameState.h"
#import "BoardLayer.h"

@interface BoardRow()
-(Tile*)tileAtLocation:(BoardLocation *)boardLocation;
-(BOOL)selectTileForTouch:(CGPoint)touchLocation;
@end

@implementation BoardRow
@synthesize sprite,row,state,tiles;
@synthesize rowAnimationCompletionBlock;

-(id)init {
    if ((self = [super init])) {
        self.sprite = [[[CCSprite alloc] initWithSpriteFrameName:@"unsolved_row.png"] autorelease];
        sprite.anchorPoint = ccp(0,1);
        row = 0;
        [self addChild:sprite];
    }
    return self;
}

-(CCArray*)tiles {
    CCArray *arr = [CCArray arrayWithCapacity:BOARD_GRID_COLUMNS];
    for (int i = 0; i < BOARD_GRID_COLUMNS; i++) {
        [arr addObject:[self getChildByTag:kTileStartingTag + i]];
    }
    return arr;
}
-(void)setTiles:(CCArray*)tileArray {
    
    for (int i = 0; i < [tileArray count]; i++) {
        
        int tag = kTileStartingTag + i;
        
        // Remove if it's there already
        if ([self getChildByTag:tag])
            [self removeChildByTag:tag cleanup:YES];
        
        // Add it back
        Tile *tile = [tileArray objectAtIndex:i];
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

-(Tile*)tileAtIndex:(NSUInteger)idx {
    return (Tile*)[self getChildByTag:kTileStartingTag + idx];
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


#pragma mark -
#pragma mark Animation
-(void)animateRowToIndex:(NSUInteger)idx solved:(BOOL)isSolved completion:(BoardRowAnimationCompletionBlock)block {
  
    // Store the ivars for solved and the completion block, they will be used later
    self.rowAnimationCompletionBlock = block;
    solved = isSolved;
    
    // Animate the letters in from the right and then out again, up to the index given    
    for (int i = idx; i < BOARD_GRID_COLUMNS; i++) {
        Tile *tile = [self tileAtIndex:i];
        
        id delayAction = [CCDelayTime actionWithDuration:kAnimationDelay * (BOARD_GRID_COLUMNS - i) ];
        id callFunc = [CCCallFuncND actionWithTarget:tile selector:@selector(startAnimating) data:tile];
        [self runAction:[CCSequence actions:delayAction, callFunc, nil]];
    }
    
    [self schedule:@selector(rowAnimationStartUpdate:) interval:0.1];
}

-(void)rowAnimationStartUpdate:(ccTime)delta {
    
    // Keep waiting until all are done
    for (int i = 0; i < BOARD_GRID_COLUMNS; i++) {
        Tile *tile = [self tileAtIndex:i];
        
        if (tile.tileState == TileStatePlayed) continue; // Don't worry about played ones
        if (tile.tileState != TileStateAnimating) return; // Not all animating yet
    }
    
    // All are animating, so reverse the process
    [self unscheduleAllSelectors];
    
    for (int i = 0; i < BOARD_GRID_COLUMNS; i++) {
        Tile *tile = [self tileAtIndex:i];
            id delayAction = [CCDelayTime actionWithDuration:kAnimationDelay * i ];
            id callFunc = [CCCallFuncND actionWithTarget:self selector:@selector(stopAnimating:data:) data:tile];
            [self runAction:[CCSequence actions:delayAction, callFunc, nil]];
    }
    
    // Now need to wait for all to be done
    [self schedule:@selector(rowAnimationStopUpdate:) interval:0.1];
}
-(void)rowAnimationStopUpdate:(ccTime)delta {
    // Keep waiting until all are done
    for (int i = 0; i < BOARD_GRID_COLUMNS; i++) {
        Tile *tile = [self tileAtIndex:i];
        if (tile.tileState == TileStateAnimating) return; // Not all animating yet
    }

    [self unscheduleAllSelectors];
    
    // Call the completion handler
    if (self.rowAnimationCompletionBlock != nil)
        rowAnimationCompletionBlock();

}
-(void)stopAnimating:(id)sender data:(void*)d {
    
    Tile *tile = (Tile*)d;
    
    [tile stopAnimating];
    if (solved) {
        tile.tileState = TileStateSolved;
    }
    
}

#pragma mark -
-(void)dealloc {
    [super dealloc];
    [sprite release];
    [rowAnimationCompletionBlock release];
}



@end
