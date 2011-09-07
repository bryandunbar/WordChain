//
//  Constants.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#ifndef WordChain_Constants_h
#define WordChain_Constants_h

#import "CommonProtocols.h"


// Layer Tags
#define kGameLayerTag 1000
#define kHudLayerTag 1001
#define kTimerLayerTag 1002

#define BOARD_GRID_COLUMNS 10
#define BOARD_GRID_ROWS 6

static NSString *superlatives[] = {@"Awesome!", @"Way to Go!", @"Excellent!", @"Nice Work!", @"Groovy!"};
#define RAND_SUPERLATIVE superlatives[random() % 5]
#endif
