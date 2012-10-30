//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Level10.h"
#import "GameController.h"

@implementation Level10

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"path_jump"];
    [game addLaneModel:@"path_jump_1"];
    [game addLaneModel:@"path_jump"];
    [game addLaneModel:@"path_jump_1"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"path_jump_2"];
    [game addLaneModel:@"path_jump_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"path_jump_3"];
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:30 andJumps:0];
    }
    else {
        [game defineTargetTime:40 andJumps:0];
    }
    [game defineJumpStrengthOfField:6.32];
    [game defineSpeedFieldStrength:2.32 factor:1.3];
}

@end
