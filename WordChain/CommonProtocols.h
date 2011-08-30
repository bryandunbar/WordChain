//
//  CommonProtocols.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#ifndef WordChain_CommonProtocols_h
#define WordChain_CommonProtocols_h


typedef enum {
    TileStateInitialized,
    TileStateSelectable,
    TileStatePlayed,
    TileStateUnused
} TileState;

typedef enum {
    GameObjectTypeTile
} GameObjectType;

typedef enum {
    kNoSceneInitialized=0,
    kMainMenuScene=1,
    kGameLevel1=101,
    kGuess=102
} SceneTypes;

#endif
