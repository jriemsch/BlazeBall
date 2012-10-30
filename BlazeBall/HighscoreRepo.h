//  Created by Jens Riemschneider on 10/6/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>

@interface HighscoreRepo : NSObject {
    BOOL _loaded;
    NSMutableDictionary *_scoresByLevel;
}

- (BOOL)checkForLevel:(int)level with:(int)score;
- (int)getForLevel:(int)level;

@end
