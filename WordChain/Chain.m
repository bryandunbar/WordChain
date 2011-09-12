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
#import "sqlite3.h"

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
    
        // Grab the words
        self.words = [self wordsForLevel:4];
        
        
        self.solvedIndices = [NSMutableArray arrayWithCapacity:[self.words count]];
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
    NSExpression *minExpression = [NSExpression expressionForFunction:@"min:"
                                                                  arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"minRetrieveCount"];
    [expressionDescription setExpression:minExpression];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent: @"WordChain.sqlite"];
    sqlite3 *database;
    sqlite3_stmt *update_statement;
    
    NSString *sqlString = [NSString stringWithFormat:@"update zchainword set zretrievecount = zretrievecount + 1 where zchain in (select distinct zchain from zword zw join zchainword cw on cw.zword = zw.z_pk where zid in (%@))", [wordsToUpdate componentsJoinedByString:@","]];
    const char *sql = [sqlString UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) == SQLITE_OK) {
            int status = sqlite3_step(update_statement);
            if (status == SQLITE_DONE) {
                //NSLog(@"sqlString:%@",sqlString);
            }
            else {
                NSLog(@"Failed to update for query: %@", sqlString);  
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
                NSLog(@"status = %d",status);
            }
            sqlite3_finalize(update_statement);
            sqlite3_close(database);
        }
        else {
            NSLog(@"Failed to prepare the update statement for query: %@", sqlString);           
        }
    }
    else {
        NSLog(@"Failed to connect to sqlite database at path: %@", databasePath);
    }
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
        index++;
    }

    // This update does not need to run right away
    dispatch_queue_t queue = dispatch_queue_create("com.coolios.queue.chain", 0ul);
    dispatch_async(queue, ^{
        [self markWordsAsRetrieved:wordsToUpdate];
    });
    
    [request release];
    return wordsToPlay;
}

- (int)randomChainForLevel:(int)lvl withRetrieveCount:(int)retrieveCount {
    // replaces chainCandidatesForLevel and randomChainFromChains
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    NSDictionary * entityProperties = [chainEntity propertiesByName];
    NSPropertyDescription * chainProperty = [entityProperties objectForKey:@"chain"];
    [request setReturnsDistinctResults:YES];
    NSArray * tempPropertyArray = [NSArray arrayWithObject:chainProperty];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"level == %d and retrieveCount = %d",lvl, retrieveCount]];
    [request setPredicate:predicate];
    NSError *error;
    NSUInteger numChains = [self.moc countForFetchRequest:request error:&error];    
    NSUInteger offset = numChains - (arc4random() % numChains);
    NSLog(@"Chain Candidates = %d",numChains);
    [request setFetchOffset:offset];
    [request setFetchLimit:1];
    [request setPropertiesToFetch:tempPropertyArray];

    NSArray* chains = [self.moc executeFetchRequest:request error:&error];
    ChainWord * chainWord = (ChainWord *)[chains objectAtIndex:0];
    return [chainWord.chain intValue];
}

-(NSArray *)wordsForLevel:(int)lvl {
    int chainToSelect = [self randomChainForLevel:lvl withRetrieveCount:[self minRetrieveCountForAllChains]];
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
