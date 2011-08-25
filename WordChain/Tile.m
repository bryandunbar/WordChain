//
//  Tile.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Tile.h"



@implementation Tile
@synthesize tileState, letter, row, col;

+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c {

    // TODO: This will change
    NSString *fileName = [NSString stringWithFormat:@"%@.png", (letter == nil ? @"back" : letter)];
    Tile *tile = [[Tile alloc] initWithSpriteFrameName:fileName];
    tile.letter = letter;
    tile.row = r;
    tile.col = c;
    tile.anchorPoint = CGPointMake(0, 1);
    
    tile.tileState = (letter == nil ? TileStateUnused : TileStateInitialized);
    
    // TODO: Make sprites the right size in the images
    tile.scale = 0.20;
    
    return tile;
}

-(void)dealloc {
    [super dealloc];
    [letter release];
}

@end
