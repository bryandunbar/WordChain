//
//  GuessScene.h
//  WordChain
//
//  Created by Clay Tinnell on 8/31/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "CCScene.h"
#import "GuessLayer.h"
#import "Board.h"

@interface GuessScene : CCScene {
    GuessLayer *guessLayer;
}
+(id)nodeWithGuessLocation:(BoardLocation *)location;

@end
