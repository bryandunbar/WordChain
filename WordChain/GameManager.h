//
//  GameManager.h
//  WordChain
//
//  Created by Clay Tinnell on 8/29/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonProtocols.h"

@interface GameManager : NSObject {
    SceneTypes currentScene;   
}

+(GameManager*)sharedGameManager;

-(void)runSceneWithID:(SceneTypes)sceneID;

@end
