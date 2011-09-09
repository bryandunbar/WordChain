//
//  Chain.m
//  WordChain
//
//  Created by Bryan Dunbar on 8/25/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "Chain.h"
#import "AppDelegate.h"
#import "ChainWord.h"
#import "Word.h"

@interface Chain ()
@property (nonatomic,retain) NSArray *words;
@property (nonatomic,retain) NSMutableArray *solvedIndices;
@end

@implementation Chain
@synthesize words, solvedIndices, moc=_moc;

- (id)init
{
    self = [super init];
    if (self) {
       // self.words = [NSArray arrayWithObjects:@"final", @"four", @"square", @"dance", @"party", @"time", nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
    
        // First and last start as solved
        self.words = [self wordsForLevel:4];
        self.solvedIndices = [NSMutableArray arrayWithCapacity:[self.words count]];
//        [self solveWordAtIndex:0];
//        [self solveWordAtIndex:[self.words count] - 1];
        NSLog(@"words = %@",self.words);
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
    if((self = [super init]))
    {
        [self setWords:(NSArray *)[coder decodeObjectForKey: @"words"]];
        [self setSolvedIndices:(NSMutableArray *)[coder decodeObjectForKey: @"solvedIndices"]];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
    }
    return self;
}

-(int)length {
    return [words count];
}
-(BOOL)guess:(NSString *)g forWordAtIndex:(NSUInteger)idx {
    NSString *word = [self wordAtIndex:idx];
    if ([word caseInsensitiveCompare:g] == NSOrderedSame) {
        [self solveWordAtIndex:idx];
        return YES;
    }
    return NO;
}
-(NSString*)wordAtIndex:(NSUInteger)idx {
    return [words objectAtIndex:idx];
}
-(NSString*)letterForWord:(NSUInteger)wordIdx atIndex:(NSUInteger)idx {
    NSString *word = [self wordAtIndex:wordIdx];
    
    if (idx < [word length]) {
        return [[NSString stringWithFormat:@"%C", [word characterAtIndex:idx]] uppercaseString];
    } else {
        return nil;
    }
}
-(BOOL)isWordSolved:(NSUInteger)idx {
    return [self.solvedIndices containsObject:[NSNumber numberWithInt:idx]];
}
-(void)solveWordAtIndex:(NSUInteger)idx {
    if (![self isWordSolved:idx]) {
        [self.solvedIndices addObject:[NSNumber numberWithInt:idx]];
    }
}
-(BOOL)isChainSolved {
    return [self.words count] == [self.solvedIndices count];
}
-(NSUInteger)lowestUnsolvedIndex {
    
    if ([self isChainSolved]) return -1;
    for (NSUInteger i = 0; i < [words count]; i++) {
        if (![self isWordSolved:i]) {
            return i;
        }
    }
    return -1; // This code should never be reached
}
-(NSUInteger)highestUnsolvedIndex {

    if ([self isChainSolved]) return -1;
    for (NSUInteger i = [words count] - 1; i >=0; i--) {
        if (![self isWordSolved:i]) {
            return i;
        }
    }
    return -1; // This code should never be reached
}

#pragma mark -
#pragma mark Chain Loading Stuff

-(int)minRetrieveCountForAllChains {
    // Randomization logic: get minimum retrieve count (words that haven't been played yet)

    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];    
    [request setResultType:NSDictionaryResultType];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"retrieveCount"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"min:"
                                                                  arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"minRetrieveCount"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSInteger16AttributeType];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    NSError *error;
    
    NSArray *objects = [self.moc executeFetchRequest:request error:&error];
    if (objects == nil || [objects count] < 1) {
        // Handle the error.
        return 0;
    }
    else {
        NSLog(@"Minimum retrieve count: %d", [[[objects objectAtIndex:0] valueForKey:@"minRetrieveCount"] intValue]);
        return [[[objects objectAtIndex:0] valueForKey:@"minRetrieveCount"] intValue];
    }
}

-(void)markWordsAsRetrieved:(NSArray *) wordsToUpdate {
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word.id IN %@",wordsToUpdate];
    [request setPredicate:predicate];        
    
    NSError *error;
    
    NSArray *chainWords = [self.moc executeFetchRequest:request error:&error]; 
    for (ChainWord *cw in chainWords) {        
        //Randomization: up the chain's retrieve count by 1
        [cw setRetrieveCount:[NSNumber numberWithInt:([cw.retrieveCount intValue] + 1)] ];
        if (![self.moc save:&error]) {
            // Handle the error.
            NSLog(@"Error Updating chainWord");
            NSLog(@"Error: %@",error);
        }
    }
    
    [request release];
    
}

-(NSArray *)wordsFromChain:(int)chain {
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"chain == %d",chain]];
    [request setPredicate:predicate];        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    [sortDescriptor release];
    
    NSError *error;
    
    NSArray *chainWords = [self.moc executeFetchRequest:request error:&error]; 
    int index = 0;
    NSMutableArray *wordsToPlay = [NSMutableArray arrayWithCapacity:6];
    NSMutableArray *wordsToUpdate = [NSMutableArray arrayWithCapacity:6];
    for (ChainWord *cw in chainWords) {
        Word * w = (Word *)cw.word;
        if (index == 0) {
            [wordsToPlay addObject:w.wordOne];
        }
        [wordsToPlay addObject:w.wordTwo];
        [wordsToUpdate addObject:w.id];
        
        //Randomization: up the chain's retrieve count by 1
        [cw setRetrieveCount:[NSNumber numberWithInt:([cw.retrieveCount intValue] + 1)] ];
        if (![self.moc save:&error]) {
            // Handle the error.
            NSLog(@"Error Adding chainWord");
            NSLog(@"Error: %@",error);
        }
        index++;
    }
    [self markWordsAsRetrieved:wordsToUpdate];
    
    [request release];
    return wordsToPlay;
}

-(int)randomChainFromChains:(NSArray *)chains {
    int randomIndex =  arc4random() % [chains count];
    ChainWord * chainWord = (ChainWord *)[chains objectAtIndex:randomIndex];
    return [chainWord.chain intValue];
}

-(NSArray *)chainCandidatesForLevel:(int)lvl withRetrieveCount:(int)retrieveCount{
    // return a list of distinct chains in order to randomize them
    // it is ordered by retrieveCount to lessen the duplicate plays
    // not setting this yet though...
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"level == %d and retrieveCount = %d",lvl, retrieveCount]];
    [request setPredicate:predicate];
    
    // this will lessen the likelihood of repeating results
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"retrieveCount" ascending:YES];
    
    NSDictionary * entityProperties = [chainEntity propertiesByName];
    NSPropertyDescription * chainProperty = [entityProperties objectForKey:@"chain"];
    NSPropertyDescription * countProperty = [entityProperties objectForKey:@"retrieveCount"];
    NSArray * tempPropertyArray = [NSArray arrayWithObjects:chainProperty, countProperty, nil];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:tempPropertyArray];
    
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    [sortDescriptor release];
    
    NSError *error;
    return [[[self.moc executeFetchRequest:request error:&error] copy] autorelease];   
}

-(NSArray *)wordsForLevel:(int)lvl {
    NSArray *chainCandidates = [self chainCandidatesForLevel:lvl withRetrieveCount:[self minRetrieveCountForAllChains]];
    NSLog(@"Total Chain Candidates = %d",[chainCandidates count]);
    int chainToSelect = [self randomChainFromChains:chainCandidates];
    return [self wordsFromChain:chainToSelect];
}

- (void)encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: [self words] forKey: @"words"];
    [coder encodeObject: [self solvedIndices] forKey: @"solvedIndices"];
}

-(void)dealloc {
    [super dealloc];
    [words release];
    [solvedIndices release];
}

@end
