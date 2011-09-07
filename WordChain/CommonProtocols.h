//
//  CommonProtocols.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#ifndef WordChain_CommonProtocols_h
#define WordChain_CommonProtocols_h
@class Board;

typedef enum {
    BoardRowUnsolved,
    BoardRowSolved
} BoardRowState;

typedef enum {
    TileStateInitialized,
    TileStateSelectable,
    TileStatePlayed,
    TileStateSolved,
    TileStateUnused
} TileState;

typedef enum {
    GameObjectTypeTile
} GameObjectType;

typedef enum {
    SceneTypeNoSceneInitialized=0,
    SceneTypeMainMenu=1,
    SceneTypeMainGameScene=101,
    SceneTypeGuess=102
} SceneTypes;

typedef enum {
    GameModeNoGame,
    GameModeSinglePlayer,
    GameModeTwoPlayer
} GameModes;


@protocol GameData <NSObject>
-(void)updateGameData;
@end
#endif
