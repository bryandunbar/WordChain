//
//  MainMenuLayer.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/30/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameManager.h"

@interface MainMenuLayer ()
-(void)displayMainMenu;
-(void)twoPlayerGameClick;
@end
@implementation MainMenuLayer


-(id)init {
    self = [super init];
    if (self != nil) {
        [self displayMainMenu];
    }
    return self;
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize; 

    // Main Menu
    CCMenuItemFont *twoPlayerGame = [CCMenuItemFont 
                                     itemFromString:@"Two Player Game" target:self selector:@selector(twoPlayerGameClick)];
    mainMenu = [CCMenu 
                menuWithItems:twoPlayerGame,nil];
    [mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [mainMenu setPosition:
     ccp(screenSize.width * 2.0f,
         screenSize.height / 2.0f)];
    id moveAction = 
    [CCMoveTo actionWithDuration:1.2f 
                        position:ccp(screenSize.width * 0.85f,
                                     screenSize.height/2.0f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    id sequenceAction = [CCSequence actions:moveEffect,nil];
    [mainMenu runAction:sequenceAction];
    [self addChild:mainMenu z:0];
}

-(void)twoPlayerGameClick {
    [[GameManager sharedGameManager] newTwoPlayerGame];
}

@end
