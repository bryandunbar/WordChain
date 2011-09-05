//
//  BaseGame.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "BaseGame.h"

@implementation BaseGame
@synthesize board, round, timer;
- (id)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

-(void)dealloc {
    [super dealloc];
    [board release];
}
-(void)reset {
    self.round = 1;
    self.board = [[Board alloc] init];
}

+(BaseGame*)newGame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


-(void)guess:(NSString*)g forWordAtIndex:(NSUInteger)idx {
    [board.chain guess:g forWordAtIndex:idx];
    [self updateGameData];
}
-(void)turnTimeExpired {
    
}
-(BOOL)isGameOver {
    return NO;
}
#pragma mark -
#pragma mark 
-(void)updateGameData {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:round forKey:@"Round"];
    [encoder encodeInt:timer forKey:@"Timer"];
    [encoder encodeObject:board forKey:@"Board"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {                
        self.round = [decoder decodeIntForKey:@"Round"];
        self.timer = [decoder decodeIntForKey:@"Timer"];
        self.board = [decoder decodeObjectForKey:@"Board"];
    }
    return self;
}

@end
