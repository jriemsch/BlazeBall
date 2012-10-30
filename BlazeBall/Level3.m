//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Level3.h"
#import "GameController.h"

@implementation Level3

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"speed_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"speed_3_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_3_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"slow_jump_embed"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"slow_jump_embed"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2_1"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2_1"];
    [game addLaneModel:@"empty_large_hole_2"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_3"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"speed_3_2"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"jump_3_2"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"speed_3"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:25 andJumps:2];
    }
    else {
        [game defineTargetTime:40 andJumps:5];
    }
    [game defineSpeedFieldStrength:3.6 factor:1.6];
}

@end
