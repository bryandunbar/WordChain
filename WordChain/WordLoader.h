//
//  WordLoader.h
//  WordChain
//
//  Created by Clay Tinnell on 8/26/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordLoader : NSObject {
    NSManagedObjectContext *_moc;
    int _chainCounter;

@private
    NSError *error; 
}

@property (nonatomic, retain) NSManagedObjectContext *moc;

- (void)loadChains;
@end
