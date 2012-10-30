//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Level7.h"
#import "GameController.h"

@implementation Level7

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"slow_fast_embed"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"warp"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"warp"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"all_jump_1"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"jump_2"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_blocks_3"];
    [game addLaneModel:@"cyan_blocks_3"];
    [game addLaneModel:@"cyan_holes_3"];
    [game addLaneModel:@"cyan_holes_3"];
    [game addLaneModel:@"cyan_6"];
    [game addLaneModel:@"cyan_6"];
    
    if (arcade) {
        [game defineTargetTime:30 andJumps:3];
    }
    else {
        [game defineTargetTime:40 andJumps:7];
    }
}

@end
