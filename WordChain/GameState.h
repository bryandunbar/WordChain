//
//  GameState.h
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "TwoPlayerGame.h"
#import "Chain.h"

@interface GameState : NSObject <NSCoding> {
    GameModes gameMode;
    
    /** The Model Object for a TwoPlayer Game **/
    @private
    TwoPlayerGame *twoPlayerGame;
}

@property (nonatomic,assign) GameModes gameMode;
@property (nonatomic,readonly) BaseGame *gameData;

+ (GameState *) sharedInstance;
- (void)save;

-(void)newTwoPlayerGame;

@end
