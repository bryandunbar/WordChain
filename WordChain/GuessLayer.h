//
//  GuessLayer.h
//  WordChain
//
//  Created by Clay Tinnell on 8/31/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "CCLayer.h"
#import "GuessView.h"
#import "Board.h"
#import "TimerLayer.h"

#define kTagBoardRow 1000

@interface GuessLayer : CCLayer <GuessViewDelegate, TimerLayerDelegate> {
    GuessView *guessView;
    UITextField *hiddenTextField;
    BoardLocation *guessLocation;
}
+(id)nodeWithGuessLocation:(BoardLocation *)location;
-(void)handleTimerExpired;

@end
