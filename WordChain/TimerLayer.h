//
//  TimerLayer.h
//  WordChain
//
//  Created by Clay Tinnell on 9/5/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kTimerLabelPadding 10

@protocol TimerLayerDelegate <NSObject>

-(void)handleTimerExpired;

@end

@interface TimerLayer : CCLayer {
    bool isTimerInitialized;
    CCLabelBMFont *_timerLabel;
    id<TimerLayerDelegate> _delegate;
}

-(void)updateTimer;
-(void)createTimer;
-(NSString*)fontName;
-(void)startTimer;
-(void)stopTimer;
@property (nonatomic, retain) CCLabelBMFont *timerLabel;
@property (nonatomic, retain) id<TimerLayerDelegate> delegate;
@end
