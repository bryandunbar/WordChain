//
//  GameManager.m
//  WordChain
//
//  Created by Clay Tinnell on 8/29/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//

#import "GameManager.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "GameState.h"
#import "CommonProtocols.h"

@implementation GameManager
static GameManager* _sharedGameManager = nil;                      

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])                            
    {
        if(!_sharedGameManager)                                    
            [[self alloc] init]; 
        return _sharedGameManager;                                 
    }
    return nil; 
}

+(id)alloc 
{
    @synchronized ([GameManager class])                            
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");                                          // 6
        _sharedGameManager = [super alloc];
        return _sharedGameManager;                                 
    }
    return nil;  
}

-(id)init {                                                        
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        currentScene = SceneTypeNoSceneInitialized;
    }
    return self;
}

#pragma mark -
#pragma mark Startup
-(void)startup {
    // Check the game mode to determine where we need to go
    GameModes gameMode = [GameState sharedInstance].gameMode;
    
    switch (gameMode) {
        case GameModeNoGame:
            [self runSceneWithID:SceneTypeMainMenu];
            break;
        case GameModeSinglePlayer:
            // TODO: Implement
            break;
        case GameModeTwoPlayer:
            [self runSceneWithID:SceneTypeMainGameScene];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Scene Management
-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case SceneTypeMainMenu: 
            sceneToRun = [MainMenuScene node];
            break;
        case SceneTypeMainGameScene:
            sceneToRun = [GameScene node];
            break;
        case SceneTypeGuess:
            break;
             
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    // Menu Scenes have a value of < 100
    if (sceneID < 100) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { 
            CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels; 
            if (screenSize.width == 960.0f) {
                // iPhone 4 Retina
                [sceneToRun setScaleX:0.9375f];
                [sceneToRun setScaleY:0.8333f];
                CCLOG(@"GameMgr:Scaling for iPhone 4 (retina)");
                
            } else {
                [sceneToRun setScaleX:0.4688f];
                [sceneToRun setScaleY:0.4166f];
                CCLOG(@"GameMgr:Scaling for iPhone 3GS or older (non-retina)");
                
            }
        }
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }    
}   


#pragma mark -
#pragma mark New Game Methods
-(void)newTwoPlayerGame {
    [[GameState sharedInstance] newTwoPlayerGame];
    [self runSceneWithID:SceneTypeMainGameScene];
}


@end
