//
//  ChainWord.h
//  WordChain
//
//  Created by Clay Tinnell on 8/26/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChainWord : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * chain;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * retrieveCount;
@property (nonatomic, retain) NSManagedObject *word;

@end
