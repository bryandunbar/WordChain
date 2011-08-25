//
//  Tile.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"



@interface Tile : CCSprite {
    TileState tileState;
    NSString *letter;
    NSUInteger row; // Row in the board
    NSUInteger col; // Column in the board
}

@property (readwrite) TileState tileState;
@property (readwrite) NSUInteger row;
@property (readwrite) NSUInteger col;
@property (nonatomic,retain) NSString *letter;
+(id)tileWithLetter:(NSString*)letter row:(NSUInteger)r col:(NSUInteger)c;
@end
