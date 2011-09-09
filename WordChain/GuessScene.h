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

@protocol GuessSceneDelegate <NSObject> 
-(void)guessDidComplete;
-(void)gameDidComplete;
@end

@interface GuessScene : CCScene {
    GuessLayer *guessLayer;
    id<GuessSceneDelegate> _delegate;
}
+(id)nodeWithGuessLocation:(BoardLocation *)location;

@property (nonatomic, retain) id<GuessSceneDelegate> delegate;

@end
