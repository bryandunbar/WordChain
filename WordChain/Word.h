//
//  Word.h
//  WordChain
//
//  Created by Clay Tinnell on 8/26/11.
//  Copyright (c) 2011 Great American Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChainWord;

@interface Word : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * wordOne;
@property (nonatomic, retain) NSString * wordTwo;
@property (nonatomic, retain) NSSet *chainWords;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addChainWordsObject:(ChainWord *)value;
- (void)removeChainWordsObject:(ChainWord *)value;
- (void)addChainWords:(NSSet *)values;
- (void)removeChainWords:(NSSet *)values;
@end
