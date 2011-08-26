//
//  GuessView.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/26/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuessView;
@protocol GuessViewDelegate <NSObject>

-(void)didGuess:(GuessView*)gv guess:(NSString*)g;

@end

@interface GuessView : UIView {
    UITextField *textField;
    UIButton *button;
    
    id<GuessViewDelegate> delegate;
}

@property (nonatomic,retain) IBOutlet UITextField *textField;
@property (nonatomic,retain) IBOutlet UIButton *button;
@property (nonatomic,assign) id<GuessViewDelegate> delegate;

-(IBAction)guessClicked:(id)sender;
@end
