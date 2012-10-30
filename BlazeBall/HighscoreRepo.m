//  Created by Jens Riemschneider on 10/6/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "HighscoreRepo.h"

@implementation HighscoreRepo

- (void)dealloc {
    [_scoresByLevel release];
    [super dealloc];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:@"highscore.plist"];
}

- (void)load {
    [_scoresByLevel release];
    _scoresByLevel = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
    if (!_scoresByLevel) {
        _scoresByLevel = [[NSMutableDictionary alloc] init];
    }
    else {
        [_scoresByLevel retain];
    }
    _loaded = YES;
}

- (void)save {
    NSString *path = [self dataFilePath];
    if (![_scoresByLevel writeToFile:path atomically:NO]) {
        NSLog(@"Failed to write highscore file to %@", path);
    }
}

- (BOOL)checkForLevel:(int)level with:(int)score {
    if (!_loaded) {
        [self load];
    }
    
    NSString *levelStr = [NSString stringWithFormat:@"%i", level];
    int highscore = [[_scoresByLevel objectForKey:levelStr] intValue];
    if (abs(score) <= highscore) {
        return NO;
    }
    
    [_scoresByLevel setObject:[NSString stringWithFormat:@"%i", score] forKey:levelStr];
    [self save];

    return YES;
}

- (int)getForLevel:(int)level {
    if (!_loaded) {
        [self load];
    }
    
    NSString *levelStr = [NSString stringWithFormat:@"%i", level];
    int highscore = [[_scoresByLevel objectForKey:levelStr] intValue];
    return highscore;
}

@end
