//
//  Tile.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Tile.h"
#import "GameState.h"
@interface Tile()
-(void)updateLabelWithRandomLetter:(ccTime)delta;
@end

@implementation Tile
@synthesize tileState, letter, row, col;
@synthesize sprite, label;

-(id)init {
    if ((self = [super init])) {
        // Create the sprite
        self.sprite = [[[CCSprite alloc] initWithSpriteFrameName:@"unsolved_tile.png"] autorelease];
        self.sprite.anchorPoint = CGPointMake(0, 1);
        self.sprite.position = ccp(3,0);
        [self addChild:self.sprite z:0 tag:kTagTileSprite];
         
         // Create the label
        self.label = [CCLabelBMFont labelWithString:@"A" fntFile:[self fontName]];
        self.label.position = ccp(self.sprite.boundingBox.size.width / 2,
                                  self.sprite.boundingBox.size.height / 2); // Place in the middle of the tile
        self.label.visible = NO;
        [self.sprite addChild:self.label z:5 tag:kTagLetter];
    }
    return self;
    
}
+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c {

    Tile *tile = [Tile node];
    tile.letter = letter;
    tile.row = r;
    tile.col = c;
    tile.tileState = (letter == nil ? TileStateUnused : TileStateInitialized);
    
    return tile;
}

-(void)setTileState:(TileState)newState {

    // Store the new state
    self->tileState = newState;
    
    // Grav the letter
    CCNode *letterNode = [self getChildByTag:kTagLetter];
    
    // Set the frame based on this
    if (newState == TileStateSolved) {
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solved_tile.png"]];
        self.label.visible = YES;
    }else if (newState == TileStatePlayed) {
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"unsolved_tile.png"]];
        self.label.visible = YES;
    } else if (newState == TileStateUnused) {
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"unsolved_tile.png"]];
        self.label.visible = NO;
    } else if (newState == TileStateSelectable) {
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"unsolved_tile_selectable.png"]];
        letterNode.visible = NO;
    } else if (newState == TileStateInitialized) {
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"unsolved_tile.png"]];
        self.label.visible = NO;
    } else if (newState == TileStateAnimating) {
        self.label.visible = YES;
    }
}

-(void)setLetter:(NSString *)newLetter {
    [letter release];
    letter = [newLetter retain];
    [self.label setString:newLetter];
}

#pragma mark -
#pragma mark Animation
-(void)startAnimating {
    
    [self stopAllActions];
    
    // Save the previous state
    stateBeforeAnimation = self.tileState;
    self.tileState = TileStateAnimating;
    
    // Schedule updates
    [self schedule:@selector(updateLabelWithRandomLetter:) interval:kAnimationInterval];
    
    
}
-(void)startAnimatingWithDelay:(ccTime)delay {
    [self stopAllActions];
    
    if (delay > 0) {
        id delayAction = [CCDelayTime actionWithDuration:delay];
        id callFunc = [CCCallFunc actionWithTarget:self selector:@selector(startAnimating)];
        [self runAction:[CCSequence actions:delayAction, callFunc, nil]];
    } else {
        [self startAnimating];
    }
}
-(void)stopAnimating {
    if (tileState != TileStateAnimating) return;
    
    
    // Restore the tile state
    [self stopAllActions];
    self.tileState = stateBeforeAnimation;
    
    // Unschedule
    [self unschedule:@selector(updateLabelWithRandomLetter:)];
    
    // Replace the original letter
    [self.label setString:self.letter];
}
-(void)updateLabelWithRandomLetter:(ccTime)delta {
    static NSString *LETTER_STRING = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    [self.label setString:[LETTER_STRING substringWithRange:[LETTER_STRING rangeOfComposedCharacterSequenceAtIndex:arc4random() % [LETTER_STRING length]]]];

}
                                    
                                    

#pragma mark -
-(void)dealloc {
    [super dealloc];
    [letter release];
}
-(CGRect) rect {
    CGSize s = [self.sprite.texture contentSizeInPixels];
    return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}
-(CGRect)boundingBox {
    return sprite.boundingBox;
}

-(void)play {
    
    BaseGame *gameData = [GameState sharedInstance].gameData;
    Board *board = gameData.board;
    
    // Is this the last tile in the chain? If so don't solve it
    
    if (![board isLastLetterForWord:[BoardLocation locationWithRow:self.row col:self.col]]) {
    
        // TODO: Animate this
        self.tileState = TileStatePlayed;

        // Update the model
        [board setTileState:self.tileState forLocation:[BoardLocation locationWithRow:self.row col:self.col]];
    }
}

-(NSString*)fontName {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"Arial-hd.fnt";
    } else {
        return @"Arial.fnt";
    }
}

@end
