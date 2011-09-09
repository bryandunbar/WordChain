//
//  GuessScene.m
//  WordChain
//
//  Created by Clay Tinnell on 8/31/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GuessScene.h"

@implementation GuessScene
@synthesize delegate=_delegate;

-(id)initWithGuessLocation:(BoardLocation *)location {
    self = [super init];
    if (self != nil) {
        guessLayer = [GuessLayer nodeWithGuessLocation:location];
        [self addChild:guessLayer];
    }
    return self;
}

+(id)nodeWithGuessLocation:(BoardLocation *)location {
    return [[[self alloc] initWithGuessLocation:location] autorelease];
}

@end
