//
//  Board.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Chain.h"


@interface BoardLocation : NSObject{
    NSUInteger row;
    NSUInteger col;
}
@property (nonatomic,assign) NSUInteger row;
@property (nonatomic,assign) NSUInteger col;

-(id)initWithRow:(NSUInteger)row col:(NSUInteger)c;
+(id)locationWithRow:(NSUInteger)row col:(NSUInteger)c;
@end


@interface Board : NSObject <NSCoding, GameData> {

    TileState grid[BOARD_GRID_ROWS][BOARD_GRID_COLUMNS];
    
    /** At any given point only certain tiles will be "selectable" */
    NSMutableArray *selectableTiles; 

    /** The Current Chain being worked **/
    Chain *chain;
    
}

@property (nonatomic,retain) Chain *chain;
@property (nonatomic,retain) NSMutableArray *selectableTiles;
-(TileState)tileStateAtLocation:(BoardLocation*)boardLocation;
-(void)setTileState:(TileState)state forLocation:(BoardLocation*)boardLocation;

-(NSString*)solvedTextForRow:(NSUInteger)row;
-(NSUInteger)unsolvedCharactersForRow:(NSUInteger)row;


-(void)newChain;

@end
