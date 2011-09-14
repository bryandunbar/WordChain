//
//  Board.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Board.h"
#import "Constants.h"
#import "GameState.h"

#pragma mark -
#pragma mark BoardLocation
@implementation BoardLocation
@synthesize row,col;

-(id)initWithRow:(NSUInteger)row col:(NSUInteger)c {
    if (self = [super init]) {
        self.row = row;
        self.col = c;
    }
    return self;
}
+(id)locationWithRow:(NSUInteger)row col:(NSUInteger)c {
    return [[[BoardLocation alloc] initWithRow:row col:c] autorelease];
}
@end


#pragma mark -
#pragma mark Board
@interface Board()
-(void)findSelectableTiles;
-(void)updateTileStates;
-(void)updateTileStates:(BOOL)newChain;

@end

@implementation Board
@synthesize chain, selectableTiles,isNew;
- (id)init
{
    self = [super init];
    if (self) {
        [self newChain];
    }
    
    return self;
}

-(void)newChain {
    
    // Instatiate a new chain and initialize the board
    isNew = YES;
    NSDate *methodStart = [NSDate date];
    
    self.chain = [[Chain alloc] init];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];    
    NSLog(@"NEW CHAIN TIME: %f",executionTime);

    [self updateTileStates]; 
}

-(void)dealloc {
    [super dealloc];
    [chain release];
    [selectableTiles release];
}

-(NSUInteger)unsolvedCharactersForRow:(NSUInteger)row {
    // Grab the word at this index
    NSString *word = [self.chain wordAtIndex:row];
    
    // Count the number of "Played" tiles in the row, then substract from length
    int count = 0;
    for (int i = 0; i < [word length]; i++) {
        TileState tileState = grid[row][i];
        if (tileState == TileStatePlayed) count++;
    }
    return [word length] - count;
}
-(NSString*)solvedTextForRow:(NSUInteger)row {
    
    // Grab the word at this index
    NSString *word = [self.chain wordAtIndex:row];
    
    // Count the number of "Played" tiles in the row, then substring
    int count = 0;
    for (int i = 0; i < [word length]; i++) {
        TileState tileState = grid[row][i];
        if (tileState == TileStatePlayed) count++;
    }
    return [[word substringToIndex:count] uppercaseString];
}

-(TileState)tileStateAtLocation:(BoardLocation*)boardLocation {
    return grid[boardLocation.row][boardLocation.col];
}
-(NSString*)letterAtLocation:(BoardLocation *)boardLocation {
    return [self.chain letterForWord:boardLocation.row atIndex:boardLocation.col];
}
-(BOOL)isLastLetterForWord:(BoardLocation*)boardLocation {
    NSString *word = [self.chain wordAtIndex:boardLocation.row];
    return (boardLocation.col == [word length] - 1);
}
-(void)setTileState:(TileState)state forLocation:(BoardLocation*)boardLocation {
    grid[boardLocation.row][boardLocation.col] = state;
}
-(void)updateTileStates {
    [self updateTileStates:isNew];
}

-(void)updateTileStates:(BOOL)newChain {
    for (int row = 0; row < BOARD_GRID_ROWS; row++) {
        for (int col = 0; col < BOARD_GRID_COLUMNS; col++) {
            
            // Check for solved
            if ([self.chain isWordSolved:row]) {
                grid[row][col] = TileStateSolved;
            } else if (newChain) {
                grid[row][col] = TileStateInitialized;
            }
        }
    }
    
    // Determine where the selectable tiles are. 
    if (newChain) {
        self.selectableTiles = nil;
    } else {
        [self findSelectableTiles];
    }
}
    
-(void)findSelectableTiles {
    NSUInteger highestSelectableRow = [self.chain highestUnsolvedIndex];
    NSUInteger lowestSelectableRow = [self.chain lowestUnsolvedIndex];
    
    self.selectableTiles = [NSMutableArray arrayWithCapacity:2];
    if (highestSelectableRow != -1 && lowestSelectableRow != -1) {
        
        // The first unplayed tile in each selectable row is selectable
        for (int i = 0; i < [[self.chain wordAtIndex:highestSelectableRow] length]; i++) {
            TileState tileState = [self tileStateAtLocation:[BoardLocation locationWithRow:highestSelectableRow col:i]];
            
            if (tileState == TileStateSelectable || tileState == TileStateInitialized) {
                grid[highestSelectableRow][i] = TileStateSelectable;
                [selectableTiles addObject:[BoardLocation locationWithRow:highestSelectableRow col:i]];
                break;
            }
        }
        
        // Only do the lowest row if its not the same as the highest row
        if (highestSelectableRow != lowestSelectableRow) {
            for (int i = 0; i < [[self.chain wordAtIndex:lowestSelectableRow] length]; i++) {
                TileState tileState = [self tileStateAtLocation:[BoardLocation locationWithRow:lowestSelectableRow col:i]];
                
                if (tileState == TileStateSelectable || tileState == TileStateInitialized) {
                    grid[lowestSelectableRow][i] = TileStateSelectable;
                    [selectableTiles addObject:[BoardLocation locationWithRow:lowestSelectableRow col:i]];

                    break;
                }
            }
        }
        
    }
}

#pragma mark -
#pragma mark GameData
-(void)updateGameData {
    [self updateTileStates];    
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:chain forKey:@"Chain"];
    [encoder encodeObject:[NSData dataWithBytes:(void*)grid length:BOARD_GRID_ROWS*BOARD_GRID_COLUMNS*sizeof(TileState)] forKey:@"Grid"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {                
        self.chain = [decoder decodeObjectForKey:@"Chain"];

        // Decode the grid
        NSData *data = [decoder decodeObjectForKey:@"Grid"];
        TileState *temporary = (TileState*)[data bytes];
        for(int i = 0; i < BOARD_GRID_ROWS; ++i)
            for(int j = 0; j < BOARD_GRID_COLUMNS; ++j)
                grid[i][j] = temporary[i*BOARD_GRID_COLUMNS + j];
        
        // Set tile states up
        [self updateGameData];
    }
    return self;
}



@end
