//
//  GuessLayer.h
//  WordChain
//
//  Created by Clay Tinnell on 8/31/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "CCLayer.h"
#import "GuessView.h"
#import "Board.h"
@interface GuessLayer : CCLayer <GuessViewDelegate> {
    GuessView *guessView;
    UITextField *hiddenTextField;
    BoardLocation *guessLocation;
}
+(id)nodeWithGuessLocation:(BoardLocation *)location;

@end
