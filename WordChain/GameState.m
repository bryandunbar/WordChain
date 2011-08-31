//
//  GameState.m
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/9/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"

@interface GameState()
@property (nonatomic,retain) TwoPlayerGame *twoPlayerGame;
-(void)setGameData:(id)gameData;
@end


@implementation GameState
@synthesize gameMode;
@synthesize twoPlayerGame;

static GameState *sharedInstance = nil;

+(GameState*)sharedInstance {
	@synchronized([GameState class]) 
	{
	    if(!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if (!sharedInstance) {
                [[self alloc] init]; 
                sharedInstance.gameMode = GameModeNoGame;
            }
        }
	    return sharedInstance; 
	}
	return nil; 
}

+(id)alloc 
{
	@synchronized ([GameState class])
	{
		NSAssert(sharedInstance == nil, @"Attempted to allocate a \
                 second instance of the GameState singleton"); 
		sharedInstance = [super alloc];
		return sharedInstance; 
	}
	return nil;  
}

- (void)save {
    saveData(self, @"GameState");
}

#pragma mark -
#pragma mark New Game State Methods
-(void)newTwoPlayerGame {
    self.gameMode = GameModeTwoPlayer;
    self.twoPlayerGame = [TwoPlayerGame newGame];
}

#pragma mark -
#pragma mark GameData Getter/Setter
-(id)gameData {

    // TODO: Handle other game modes
    switch (gameMode) {
        case GameModeTwoPlayer:
            return self.twoPlayerGame;
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}
-(void)setGameData:(id)gameData {
    switch (gameMode) {
        case GameModeTwoPlayer:
            self.twoPlayerGame = gameData;
            break;
            
        default:
            break;
    }
}


  
  

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:gameMode forKey:@"GameMode"];
    [encoder encodeObject:self.gameData forKey:@"GameData"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {                
        gameMode = [decoder decodeIntForKey:@"GameMode"];
        self.gameData = [decoder decodeObjectForKey:@"GameData"];
        
    }
    
    return self;
}


-(void)dealloc {
    [super dealloc];
    [twoPlayerGame release];
}
@end
