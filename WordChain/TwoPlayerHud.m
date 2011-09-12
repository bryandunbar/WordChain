//
//  TwoPlayerHud.m
//  WordChain
//
//  Created by Bryan Dunbar on 9/1/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "TwoPlayerHud.h"
#import "TwoPlayerGame.h"
#import "GameConfig.h"

#define ACTIVE_PLAYER_COLOR ccc3(255, 0, 0)
#define INACTIVE_PLAYER_COLOR ccc3(200, 200, 200)

@implementation TwoPlayerHud
@synthesize player1Label, player1Score, player2Label, player2Score, round, timerLayer;

-(void)createHud {
    
    // Create the labels
    self.player1Label = [CCLabelBMFont labelWithString:@"Player1" fntFile:[self fontName]];
    [self addChild:player1Label];
    
    self.player1Score = [CCLabelBMFont labelWithString:@"Player2" fntFile:[self fontName]];
    [self addChild:player1Score];
    
    self.player2Label = [CCLabelBMFont labelWithString:@"0" fntFile:[self fontName]];
    [self addChild:player2Label];
    
    self.player2Score = [CCLabelBMFont labelWithString:@"0" fntFile:[self fontName]];
    [self addChild:player2Score];
    
    self.round = [CCLabelBMFont labelWithString:@"Round 1" fntFile:[self fontName]];
    [self addChild:round];
        
    
    // Create the timer
    self.timerLayer = [TimerLayer node];
    [self addChild:timerLayer z:10 tag:kTimerLayerTag];
    
    // Position everything
    [self layoutHud];
    isHudInitialized = YES;
    
}

// Position everything
-(void)layoutHud {
    CGSize hudSize = self.contentSize;
    float scale = 0.5;
    
    player1Label.anchorPoint = ccp(0,1);
    player1Label.position = ccp(kHudLabelPadding, hudSize.height - kHudLabelPadding);
    
    player1Score.anchorPoint = ccp(1,1);
    player1Score.position = ccp(hudSize.width - kHudLabelPadding,player1Label.position.y);

    player2Label.anchorPoint = ccp(0,1);
    player2Label.position = ccp(kHudLabelPadding, hudSize.height - kHudLabelPadding - (player2Label.contentSize.height * scale));
    
    player2Score.anchorPoint = ccp(1,1);
    player2Score.position = ccp(hudSize.width - kHudLabelPadding,player2Label.position.y);

    round.anchorPoint = ccp(0,0);
    round.position = ccp(kHudLabelPadding, kHudLabelPadding);

    
    if (ORIENTATION == kCCDeviceOrientationPortrait) {
        // Put the timer in the bottom right
        timerLayer.position = ccp(hudSize.width - timerLayer.contentSize.width, timerLayer.contentSize.height / 2);
    } else {
        // Put in in the middle
        timerLayer.position = ccp(hudSize.width / 2, hudSize.height / 2);
    }
    
    // TODO: Get the font sizes right
    player1Label.scale = player1Score.scale = player2Label.scale = player2Score.scale = round.scale = scale;


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
}
@end
