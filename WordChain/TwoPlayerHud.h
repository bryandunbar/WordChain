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

@interface TwoPlayerHud : HudLayer {
    CCLabelBMFont *player1Label;
    CCLabelBMFont *player2Label;
    CCLabelBMFont *player1Score;
    CCLabelBMFont *player2Score;
    CCLabelBMFont *round;
}

@property (nonatomic,retain) CCLabelBMFont *player1Score;
@property (nonatomic,retain) CCLabelBMFont *player2Score;
@property (nonatomic,retain) CCLabelBMFont *player1Label;
@property (nonatomic,retain) CCLabelBMFont *player2Label;
@property (nonatomic,retain) CCLabelBMFont *round;


@end
