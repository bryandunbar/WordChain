//
//  GameplayLayer.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "CCLayer.h"
#import "BoardLayer.h"

#define kTagBoard 1

@interface GameplayLayer : CCLayerColor {
    CCSpriteBatchNode *spriteSheet;
}

@end
