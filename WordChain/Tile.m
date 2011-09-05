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
-(NSString*)frameName;
@end

@implementation Tile
@synthesize tileState, letter, row, col;

+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c {

    Tile *tile = [[[Tile alloc] initWithSpriteFrameName:@"back.png"] autorelease];
    tile.letter = letter;
    tile.row = r;
    tile.col = c;
    tile.anchorPoint = CGPointMake(0, 1);
    
    tile.tileState = (letter == nil ? TileStateUnused : TileStateInitialized);
    
    // TODO: Make sprites the right size in the images
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        tile.scale = 0.45;
    } else if ([[CCDirector sharedDirector] enableRetinaDisplay:YES]){
        tile.scale = 0.40;
    } else {
        tile.scale = 0.20;
    }
    
    return tile;
}

-(void)setTileState:(TileState)newState {

    // Store the new state
    self->tileState = newState;
    
    // Set the frame based on this
    if (newState == TileStatePlayed) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self frameName]]];
        self.opacity = 255;
    } else if (newState == TileStateUnused) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back.png"]];
    } else if (newState == TileStateSelectable) {
        self.opacity = 100;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back.png"]];
    } else if (newState == TileStateInitialized) {
        // We are allowing the reuse of tiles for better memory
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"back.png"]];
    }
}

-(NSString*)frameName {
   return [NSString stringWithFormat:@"%@.png", (self.letter == nil ? @"back" : self.letter)];
}

-(void)dealloc {
    [super dealloc];
    [letter release];
}
-(CGRect) rect {
    CGSize s = [self.texture contentSizeInPixels];
    return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
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

@end
