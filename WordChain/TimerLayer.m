//
//  TimerLayer.m
//  WordChain
//
//  Created by Clay Tinnell on 9/5/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//

#import "TimerLayer.h"
#import "GameState.h"

@implementation TimerLayer
@synthesize timerLabel=_timerLabel, delegate=_delegate;

-(id)init {
    if ((self = [super init])) {
        isTimerInitialized = NO;
        [self updateTimer];
    }
    return self;
}

-(void) setTimerLabelText {

    BaseGame *gameData = [GameState sharedInstance].gameData;
    [self.timerLabel setString:[NSString stringWithFormat:@"%d",gameData.timer]];    

}

-(void)updateTimer {
    if (!isTimerInitialized) {
        [self createTimer];
    }
    // update timer label
    [self setTimerLabelText];

}

-(void)startTimer {
    self.visible = YES;
    [self schedule: @selector(decrementTimer:) interval:1];
}
-(void)stopTimer {
    self.visible = NO;
    [self unschedule:@selector(decrementTimer:)];
}

-(void)createTimer {

    self.timerLabel = [CCLabelBMFont labelWithString:@"60" fntFile:[self fontName]];    
    [self addChild:self.timerLabel];
    self.contentSize = self.timerLabel.contentSize;
    
    isTimerInitialized = YES;

}

-(CGRect)boundingBox {
    return self.timerLabel.boundingBox;
}

-(void) decrementTimer: (ccTime) dt {
    BaseGame *gameData = [GameState sharedInstance].gameData;

    [gameData setTimer:(gameData.timer - 1)];
    [self updateTimer];
    if (gameData.timer == 0) {
        [self.delegate handleTimerExpired];
    }
    
}

-(NSString*)fontName {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"Arial-hd.fnt";
    } else {
        return @"Arial.fnt";
    }
}


@end
