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
    if ((self = [super initWithColor:ccc4(0, 0, 0, 255)])) {
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
    // eventually this will go away
    BaseGame *gameData = [GameState sharedInstance].gameData;
    //gameData.timer = 60;

    isTimerInitialized = TRUE;
    float scale = 1;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //[self setContentSize:CGSizeMake(winSize.width / 3, winSize.height)];
    [self setContentSize:CGSizeMake(winSize.width / 6, winSize.height * .25)];
    //[self setContentSize:CGSizeMake(30, 30)];
    self.position = ccp(winSize.width - self.contentSize.width, winSize.height - (winSize.height * .35));
    CGSize hudSize = self.contentSize;
    
    self.timerLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",gameData.timer] fntFile:[self fontName]];    
    self.timerLabel.anchorPoint = ccp(0,1);
    self.timerLabel.position = ccp(kTimerLabelPadding, hudSize.height - kTimerLabelPadding);
    [self addChild:self.timerLabel];
    
    self.timerLabel.scale = scale;
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
