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

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self layoutHud];
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
-(NSString*)fontName {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"Arial-hd.fnt";
    } else {
        return @"Arial.fnt";
    }
}
-(void)layoutHud {
    
}
@end
