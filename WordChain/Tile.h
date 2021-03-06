//
//  Tile.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"

#define kTagTileSprite 100
#define kTagLetter 101

#define kAnimationInterval 0.05

@interface Tile : CCNode {
    
    CCSprite *sprite;
    CCLabelBMFont *label;
    
    
    TileState tileState;
    NSString *letter;
    NSUInteger row; // Row in the board
    NSUInteger col; // Column in the board
    
    TileState stateBeforeAnimation;
}

@property (nonatomic,assign) CCSprite *sprite;
@property (nonatomic,assign) CCLabelBMFont *label;
@property (nonatomic,assign) TileState tileState;
@property (nonatomic,assign) NSUInteger row;
@property (nonatomic,assign) NSUInteger col;
@property (nonatomic,retain) NSString *letter;
-(CGRect)rect;
+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c;
-(void)play;
-(NSString*)fontName;

-(void)startAnimating;
-(void)startAnimatingWithDelay:(ccTime)delay;
-(void)stopAnimating;
-(void)stopAnimatingWithDelay:(ccTime)delay;
@end
