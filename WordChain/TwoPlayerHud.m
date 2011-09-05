//
//  TwoPlayerHud.m
//  WordChain
//
//  Created by Bryan Dunbar on 9/1/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "TwoPlayerHud.h"
#import "TwoPlayerGame.h"
#import "TimerLayer.h"

#define ACTIVE_PLAYER_COLOR ccc3(255, 0, 0)
#define INACTIVE_PLAYER_COLOR ccc3(255, 255, 255)

@implementation TwoPlayerHud
@synthesize player1Label, player1Score, player2Label, player2Score, round;

-(void)createHud {
    
    
    float scale = 0.5;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self setContentSize:CGSizeMake(winSize.width / 3, winSize.height)];
    self.position = ccp(winSize.width - self.contentSize.width, 0);
    CGSize hudSize = self.contentSize;
    
    self.player1Label = [CCLabelBMFont labelWithString:@"Player1" fntFile:[self fontName]];
    player1Label.anchorPoint = ccp(0,1);
    player1Label.position = ccp(kHudLabelPadding, hudSize.height - kHudLabelPadding);
    [self addChild:player1Label];
    
    self.player1Score = [CCLabelBMFont labelWithString:@"Player2" fntFile:[self fontName]];
    player1Score.anchorPoint = ccp(1,1);
    player1Score.position = ccp(hudSize.width - kHudLabelPadding,hudSize.height - kHudLabelPadding);
    [self addChild:player1Score];
    
    self.player2Label = [CCLabelBMFont labelWithString:@"0" fntFile:[self fontName]];
    player2Label.anchorPoint = ccp(0,1);
    player2Label.position = ccp(kHudLabelPadding, hudSize.height - kHudLabelPadding - (player2Label.contentSize.height * scale));
    [self addChild:player2Label];
    
    self.player2Score = [CCLabelBMFont labelWithString:@"0" fntFile:[self fontName]];
    player2Score.anchorPoint = ccp(1,1);
    player2Score.position = ccp(hudSize.width - kHudLabelPadding,hudSize.height - kHudLabelPadding - (player2Score.contentSize.height * scale));
    [self addChild:player2Score];
    
    self.round = [CCLabelBMFont labelWithString:@"Round 1" fntFile:[self fontName]];
    round.anchorPoint = ccp(0,0);
    round.position = ccp(kHudLabelPadding, kHudLabelPadding);
    [self addChild:round];
        
    TimerLayer *timerLayer = [TimerLayer node];
    [self addChild:timerLayer z:10 tag:kTimerLayerTag];
    
    timerLayer.anchorPoint = ccp(1,1);
    timerLayer.position = ccp(hudSize.width - (hudSize.width * .75),hudSize.height - (hudSize.height * .4));

    // TODO: Get the font sizes right
    player1Label.scale = player1Score.scale = player2Label.scale = player2Score.scale = round.scale = scale;

    isHudInitialized = YES;
    
}

-(void)doUpdateHud {
    TwoPlayerGame *gameData = [TwoPlayerGame currentGame];
    
    // Update labels
    [player1Label setString:gameData.player1];
    [player1Score setString:[NSString stringWithFormat:@"%d", gameData.player1Score]];
    [player2Label setString:gameData.player2];
    [player2Score setString:[NSString stringWithFormat:@"%d", gameData.player2Score]];
    [round setString:[NSString stringWithFormat:@"Round %d", gameData.round]];
    
    // Set color of the score labels based on whose turn it is
    ccColor3B player1LabelColor = gameData.whoseTurn == PlayerOne ? ACTIVE_PLAYER_COLOR : INACTIVE_PLAYER_COLOR;
    ccColor3B player2LabelColor = gameData.whoseTurn == PlayerTwo ? ACTIVE_PLAYER_COLOR : INACTIVE_PLAYER_COLOR;
    
    [player1Label setColor:player1LabelColor];
    [player1Score setColor:player1LabelColor];
    
    [player2Label setColor:player2LabelColor];
    [player2Score setColor:player2LabelColor];
}

-(void)dealloc {
    [super dealloc];
    [player1Score release];
    [player2Score release];
    [player1Label release];
    [player2Label release];
    [round release];
}
@end
