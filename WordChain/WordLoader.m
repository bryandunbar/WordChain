//
//  WordLoader.m
//  WordChain
//
//  Created by Clay Tinnell on 8/26/11.
//  Copyright 2011 Great American Insurance. All rights reserved.
//

#import "WordLoader.h"
#import "Word.h"
#import "ChainWord.h"
#import "sqlite3.h"

@implementation WordLoader
@synthesize moc=_moc;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _chainCounter = 0;
    }
    
    return self;
}

- (void)loadWords {
    // this method will load all words and will establish the chains for level 0
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
    NSString *fileData = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
    NSArray *arrayData = [fileData componentsSeparatedByString:@"\r"];
    for (NSString *wordGroup in arrayData) {
        _chainCounter++;
        NSArray *words = [wordGroup componentsSeparatedByString:@" "];
        if ([words count] == 2) {
            NSString *wordOne = [[words objectAtIndex:0] lowercaseString];
            NSString *wordTwo = [[words objectAtIndex:1] lowercaseString];
            if ([wordOne length] <= 10 && [wordTwo length] <=10 && [wordOne length] >= 2 && [wordTwo length] >= 2) {
                Word * word = (Word *)[NSEntityDescription insertNewObjectForEntityForName:@"Word" 
                                                                    inManagedObjectContext:self.moc];
                word.id = [NSNumber numberWithInt:_chainCounter];
                word.wordOne = wordOne;
                word.wordTwo = wordTwo;
                
                if (![self.moc save:&error]) {
                    // Handle the error.
                    NSLog(@"Error Adding Word");
                    NSLog(@"Error: %@",error);
                }
                else {
                    // load the initial chains for level 0
                    ChainWord * chainWord = (ChainWord *)[NSEntityDescription insertNewObjectForEntityForName:@"ChainWord" 
                                                                                       inManagedObjectContext:self.moc];
                    chainWord.chain = word.id;
                    chainWord.level = [NSNumber numberWithInt:0];
                    chainWord.word = word;
                    chainWord.retrieveCount = [NSNumber numberWithInt:0];
                    if (![self.moc save:&error]) {
                        // Handle the error.
                        NSLog(@"Error Adding chainWord");
                        NSLog(@"Error: %@",error);
                    }
                }
            }

        }
    }
}

- (NSArray *)matchingWordsForWord:(Word *)word {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" 
											  inManagedObjectContext:self.moc]; 
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
    [request setEntity:entity];
	NSPredicate *predicate;
    NSArray *matchingWords;
    
    //step 1: grab the next set of words for each word
    predicate = [NSPredicate predicateWithFormat:
                 [NSString stringWithFormat:@"wordOne == '%@'",  word.wordTwo]];
    [request setPredicate:predicate];
    matchingWords = [self.moc executeFetchRequest:request error:&error];
    [request release];
    return matchingWords;
}


- (bool)isWord:(Word *)word inChain:(ChainWord *)chain inLevel:(int)lvl {
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                inManagedObjectContext:self.moc]; 
    NSPredicate *predicate;
	[request setEntity:chainEntity];
    if (lvl < 999) {
        predicate = [NSPredicate predicateWithFormat:
                                  [NSString stringWithFormat:@"chain == %d and level == %d",[chain.chain intValue], lvl]];

    }
    else {
        predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"chain == %d and word.id == %d",[chain.chain intValue], [word.id intValue]]];
    }
    [request setPredicate:predicate];
    NSArray *dups = [self.moc executeFetchRequest:request error:&error];
    [request release];
    if (dups) {
        return ([dups count] > 0);
    }
    else {
        return NO;
    }
    
}

- (bool)isWord:(Word *)word inChain:(ChainWord *)chain {
    return [self isWord:word inChain:chain inLevel:999];
}

- (bool)isChain:(ChainWord *)chain FullAtLevel:(int)lvl {
    return [self isWord:nil inChain:chain inLevel:lvl];
}

- (void)branchChainFromChain:(NSNumber *)chain Level:(int)lvl Word:(Word *)mw {
    //save the current level
    _chainCounter++; //create a new chain
    
    ChainWord * newChainWord = (ChainWord *)[NSEntityDescription insertNewObjectForEntityForName:@"ChainWord" 
                                                        inManagedObjectContext:self.moc];
    newChainWord.chain = [NSNumber numberWithInt:_chainCounter];
    newChainWord.level = [NSNumber numberWithInt:lvl];
    newChainWord.word = mw;
    newChainWord.retrieveCount = [NSNumber numberWithInt:0];
    if (![self.moc save:&error]) {
        // Handle the error.
        NSLog(@"Error Adding chainWord");
        NSLog(@"Error: %@",error);
    }

    //go back and get the previous levels to backfill the chain
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"chain == %d and level < %d",[chain intValue], lvl]];
    [request setPredicate:predicate];
    NSArray *chainWords = [self.moc executeFetchRequest:request error:&error];
    for (ChainWord *cw in chainWords) {
        newChainWord = (ChainWord *)[NSEntityDescription insertNewObjectForEntityForName:@"ChainWord" 
                                                                              inManagedObjectContext:self.moc];
        newChainWord.chain = [NSNumber numberWithInt:_chainCounter]; //new chain
        newChainWord.level = cw.level; //use this level
        newChainWord.word = cw.word; //use this word
        newChainWord.retrieveCount = [NSNumber numberWithInt:0];
        if (![self.moc save:&error]) {
            // Handle the error.
            NSLog(@"Error Adding chainWord");
            NSLog(@"Error: %@",error);
        }
    }
    [request release];
}

- (void)loadChainsForLevel:(int)lvl {
    // change to start with the previous level to establish word list...
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
											  inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    int count=1;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                 [NSString stringWithFormat:@"level == %d",lvl-1]];
    [request setPredicate:predicate];
    
    // load all words
    NSArray *initialWords = [self.moc executeFetchRequest:request error:&error];
    NSArray *matchingWords;
    
    for (ChainWord *iw in initialWords) {
        matchingWords = [[self matchingWordsForWord:(Word *)iw.word] retain];
        for (Word *mw in matchingWords) {
            if ([self isWord:mw inChain:iw] ) {
                // nothing to do
            }
            else if ([self isChain:iw FullAtLevel:lvl]) {
                [self branchChainFromChain:iw.chain Level:lvl Word:mw];                
            }
            else {
                count++;
                ChainWord * newChainWord = (ChainWord *)[NSEntityDescription insertNewObjectForEntityForName:@"ChainWord" 
                                                                                   inManagedObjectContext:self.moc];
                newChainWord.chain = iw.chain;
                newChainWord.level = [NSNumber numberWithInt:lvl];
                newChainWord.word = mw;
                newChainWord.retrieveCount = [NSNumber numberWithInt:0];
                
                if (![self.moc save:&error]) {
                    // Handle the error.
                    NSLog(@"Error Adding chainWord");
                    NSLog(@"Error: %@",error);
                }
            }
        }
        [matchingWords release];
    }    
    
    [request release];
}

-(bool) shouldLoadWords {
    // change to start with the previous level to establish word list...
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *chainEntity = [NSEntityDescription entityForName:@"ChainWord" 
                                                   inManagedObjectContext:self.moc]; 
	[request setEntity:chainEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"chain == %d",3423]];
    [request setPredicate:predicate];
    
    // load all words
    NSArray *checkWords = [self.moc executeFetchRequest:request error:&error];
    [request release];
    return ([checkWords count] < 1);
}

-(void)createIndexes {
    NSLog(@"start creating indexes...");
    NSString *databasePath = [[NSBundle mainBundle] 
                                  pathForResource:@"WordChain" ofType:@"sqlite"];

    sqlite3 *database;
    sqlite3_stmt *update_statement;
    
    NSString *index1String = @"CREATE INDEX idx_chain on zchainword (zchain)";
    const char *sql1 = [index1String UTF8String];
    NSString *index2String = @"CREATE INDEX idx_level_retrievecount on zchainword (zretrievecount, zlevel)";
    const char *sql2 = [index2String UTF8String];
    NSString *sql3String = @"VACUUM";
    const char *sql3 = [sql3String UTF8String];
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_exec(database,sql1, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"Index 1 Created");
        }
        else {
            NSLog(@"Failed to add index 1: %@", index1String);  
            NSLog(@"Error: failed to create index 1 with message '%s'.", sqlite3_errmsg(database));
        }
        if (sqlite3_exec(database,sql2, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"Index 2 Created");
        }
        else {
            NSLog(@"Failed to add index 2: %@", index2String);  
            NSLog(@"Error: failed to create index 2 with message '%s'.", sqlite3_errmsg(database));
        }
        
        if (sqlite3_exec(database,sql3, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"VACUUM COMPLETED");
        }
        else {
            NSLog(@"Failed to complete vacuum: %@", sql3String);  
            NSLog(@"Error: failed to complete vacuum with message '%s'.", sqlite3_errmsg(database));
        }
        
        sqlite3_finalize(update_statement);
        sqlite3_close(database);
    }
    else {
        NSLog(@"Failed to connect to sqlite database at path: %@", databasePath);
    }
}

- (void)loadChains {
    if ([self shouldLoadWords]) {
        NSLog(@"Loading: Level %d...",0);
        [self loadWords];
        for (int x=1; x<5 ; x++) {
            NSLog(@"Loading: Level %d...",x);
            [self loadChainsForLevel:x];
        }
        [self createIndexes];
    }
}

@end
