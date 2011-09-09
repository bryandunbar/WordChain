//
//  GuessView.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/26/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "GuessView.h"

@implementation GuessView
@synthesize textField, button, delegate;

-(void)dealloc {
    [super dealloc];
    [textField release];
    [button release];
}

-(void)guessClicked:(id)sender {
    [delegate didGuess:self guess:textField.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)tf {
    [delegate didGuess:self guess:tf.text];
    return YES;
}
@end
