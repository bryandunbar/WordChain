//
//  BoardRow.h
//  WordChain
//
//  Created by Bryan Dunbar on 9/6/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

#define kPaddingBetweenTiles 5
#define kTileTopPadding 4
#define kTileStartingTag 100

@interface BoardRow : CCLayer <CCRGBAProtocol> {
    CCSprite *sprite;
    int row;
    
    BoardRowState state;
}

@property (nonatomic,retain) CCSprite *sprite;
@property (nonatomic,assign) NSMutableArray *tiles;
@property (nonatomic,assign) BoardRowState state;
@property (nonatomic,assign) int row;
@end
