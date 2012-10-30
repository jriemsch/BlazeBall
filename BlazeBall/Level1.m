//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Level1.h"
#import "GameController.h"

@implementation Level1

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];

    [game addLaneModel:@"all_jump_1"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_large_hole_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"all_speed_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"speed_hole_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"slow_fast_1"];
    [game addLaneModel:@"slow_fast_1"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"blocks_3"];
    [game addLaneModel:@"blocks_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"jump_blocks_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"speed_holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"warp_jump_2"];
    [game addLaneModel:@"big_hole_6"];
    [game addLaneModel:@"empty_large_hole_2"];
    [game addLaneModel:@"warp_jump_2"];
    [game addLaneModel:@"big_hole_6"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"all_jump_1"];
    [game addLaneModel:@"big_hole_2"];
    
    [game addLaneModel:@"empty_8"];

    if (arcade) {
        [game defineTargetTime:30 andJumps:2];
    }
    else {
        [game defineTargetTime:40 andJumps:8];
    }
}

@end
