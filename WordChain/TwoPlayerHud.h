//
//  TwoPlayerHud.h
//  WordChain
//
//  Created by Bryan Dunbar on 9/1/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HudLayer.h"
#import "cocos2d.h"
#import "TimerLayer.h"

@interface TwoPlayerHud : HudLayer {
    CCLabelBMFont *player1Label;
    CCLabelBMFont *player2Label;
    CCLabelBMFont *player1Score;
    CCLabelBMFont *player2Score;
    CCLabelBMFont *round;
    TimerLayer *timerLayer;
}

@property (nonatomic,assign) CCLabelBMFont *player1Score;
@property (nonatomic,assign) CCLabelBMFont *player2Score;
@property (nonatomic,assign) CCLabelBMFont *player1Label;
@property (nonatomic,assign) CCLabelBMFont *player2Label;
@property (nonatomic,assign) CCLabelBMFont *round;
@property (nonatomic,assign) TimerLayer *timerLayer;


@end
