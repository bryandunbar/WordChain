//
//  BoardLayer.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "Tile.h"
#import "Chain.h"
#import "GuessView.h"
#import "Board.h"

@interface BoardLayer : CCLayer <CCTargetedTouchDelegate, GuessViewDelegate> {
    
    @private
    UITextField *hiddenTextField; // Hidden textfield that forces the keyboard to show up
    GuessView *guessView; // The accessory view where the user enter's their guess
    
    Tile *lastPlayedTile;
}
    
-(void)layoutBoard;
-(Tile*)tileAtLocation:(BoardLocation*)boardLocation;
-(void)playTile:(Tile*)tile;
@end
