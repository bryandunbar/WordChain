//
//  GameState.h
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/9/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding> {
    BOOL completedLevel1;
    BOOL completedLevel2;
    BOOL completedLevel3;
    BOOL completedLevel4;
    BOOL completedLevel5;
    int timesFell;
}

+ (GameState *) sharedInstance;
- (void)save;

@property (assign) BOOL completedLevel1;
@property (assign) BOOL completedLevel2;
@property (assign) BOOL completedLevel3;
@property (assign) BOOL completedLevel4;
@property (assign) BOOL completedLevel5;
@property (assign) int timesFell;

@end
