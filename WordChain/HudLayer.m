//
//  HudLayer.m
//  WordChain
//
//  Created by Bryan Dunbar on 9/1/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "HudLayer.h"

@interface HudLayer()

-(void)createHud;
-(void)doUpdateHud;

@end

@implementation HudLayer

-(id)init {
    if ((self = [super initWithColor:ccc4(0, 0, 0, 255)])) {
        
        isHudInitialized = NO;
        [self updateHud];
    }
    return self;
}

-(void)updateHud {
    if (!isHudInitialized) {
        [self createHud];
    }
    [self doUpdateHud];
}

-(void)createHud {
    
}
-(void)doUpdateHud {
    [self doesNotRecognizeSelector:_cmd];
}
@end
