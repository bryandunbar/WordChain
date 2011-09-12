//
//  HudLayer.h
//  WordChain
//
//  Created by Bryan Dunbar on 9/1/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kHudLabelPadding 10

@interface HudLayer : CCLayerColor {
    
    BOOL isHudInitialized;
    
}

-(void)updateHud;
-(void)layoutHud;
-(NSString*)fontName;


@end
