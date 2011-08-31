//
//  GCDatabase.m
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/9/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "GCDatabase.h"

NSString * pathForFile(NSString *filename) {
    // 1
    NSArray *paths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                        NSUserDomainMask,
                                        YES);
    // 2
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 3
    return [documentsDirectory 
            stringByAppendingPathComponent:filename];
}

id loadData(NSString * filename) {
    // 4
    NSString *filePath = pathForFile(filename);
    // 5
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { 
        // 6
        NSData *data = [[[NSData alloc] 
                         initWithContentsOfFile:filePath] autorelease];
        // 7
        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] 
                                          initForReadingWithData:data] autorelease];
        // 8
        id retval = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
        return retval;
    }
    return nil;
}

void saveData(id theData, NSString *filename) {
    
    NSLog(@"----> Saving GameState to file: %@", filename);
    // 9
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    // 10
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc]                           
                                  initForWritingWithMutableData:data] autorelease];  
    // 11
    [archiver encodeObject:theData forKey:@"Data"];
    [archiver finishEncoding];
    // 12
    [data writeToFile:pathForFile(filename) atomically:YES];
}
