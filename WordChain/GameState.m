//
//  GameState.m
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/9/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState
@synthesize completedLevel1;
@synthesize completedLevel2;
@synthesize completedLevel3;
@synthesize completedLevel4;
@synthesize completedLevel5;
@synthesize timesFell;

static GameState *sharedInstance = nil;

+(GameState*)sharedInstance {
	@synchronized([GameState class]) 
	{
	    if(!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if (!sharedInstance) {
                [[self alloc] init]; 
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

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:completedLevel1 forKey:@"CompletedLevel1"];
    [encoder encodeBool:completedLevel2 forKey:@"CompletedLevel2"];
    [encoder encodeBool:completedLevel3 forKey:@"CompletedLevel3"];
    [encoder encodeBool:completedLevel4 forKey:@"CompletedLevel4"];
    [encoder encodeBool:completedLevel5 forKey:@"CompletedLevel5"];
    [encoder encodeInt:timesFell forKey:@"TimesFell"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {                
        completedLevel1 = [decoder 
                           decodeBoolForKey:@"CompletedLevel1"];
        completedLevel2 = [decoder 
                           decodeBoolForKey:@"CompletedLevel2"];
        completedLevel3 = [decoder 
                           decodeBoolForKey:@"CompletedLevel3"];
        completedLevel4 = [decoder 
                           decodeBoolForKey:@"CompletedLevel4"];
        completedLevel5 = [decoder 
                           decodeBoolForKey:@"CompletedLevel5"];
        timesFell = [decoder decodeIntForKey:@"TimesFell"];
    }
    return self;
}

@end
