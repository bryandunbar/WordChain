//
//  BaseGame.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "BaseGame.h"

@implementation BaseGame
@synthesize board, round;
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
    [encoder encodeObject:board forKey:@"Board"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {                
        self.round = [decoder decodeIntForKey:@"Round"];
        self.board = [decoder decodeObjectForKey:@"Board"];
    }
    return self;
}

@end
