//
//  Tile.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Tile.h"

@interface Tile()
-(NSString*)frameName;
@end

@implementation Tile
@synthesize tileState, letter, row, col;

+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c {

    // TODO: This will change
    Tile *tile = [[Tile alloc] initWithSpriteFrameName:@"back.png"];
    tile.letter = letter;
    tile.row = r;
    tile.col = c;
    tile.anchorPoint = CGPointMake(0, 1);
    
    tile.tileState = (letter == nil ? TileStateUnused : TileStateInitialized);
    
    // TODO: Make sprites the right size in the images
    tile.scale = 0.20;
    
    return tile;
}

-(void)setTileState:(TileState)newState {
    self->tileState = newState;
    
    // Set the frame based on this
    if (newState == TileStatePlayed) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self frameName]]];
    } else if (newState == TileStateUnused) {
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

-(void)draw {
    if (tileState == TileStateSelectable) {
        [self setOpacity:100]; // TODO: This is kind of a lame selectable state, but oh well
    }
    [super draw];
}

@end