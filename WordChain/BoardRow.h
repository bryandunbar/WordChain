//
//  BoardRow.h
//  WordChain
//
//  Created by Bryan Dunbar on 9/6/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "Tile.h"

#define kPaddingBetweenTiles 5
#define kTileTopPadding 4
#define kTileStartingTag 100

#define kAnimationDelay 0.04

typedef void(^BoardRowAnimationCompletionBlock)(void);

@interface BoardRow : CCLayer <CCRGBAProtocol> {
    CCSprite *sprite;
    int row;
    
    BoardRowState state;
    
    @private
    BOOL solved; // Holds this state during animations
    BoardRowAnimationCompletionBlock rowAnimationCompletionBlock;
}

@property (nonatomic,retain) CCSprite *sprite;
@property (nonatomic,assign) CCArray *tiles;
@property (nonatomic,assign) BoardRowState state;
@property (nonatomic,assign) int row;
@property (nonatomic,copy) BoardRowAnimationCompletionBlock rowAnimationCompletionBlock; // COPY IS IMPORTANT

-(Tile*)tileAtIndex:(NSUInteger)idx;


-(void)animateRowToIndex:(NSUInteger)idx solved:(BOOL)solved completion:(BoardRowAnimationCompletionBlock)block;
@end
