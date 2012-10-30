//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Level6.h"
#import "GameController.h"

@implementation Level6

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"right_6"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"all_speed_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"all_speed_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"all_speed_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"left_6"];
    [game addLaneModel:@"all_speed_2"];
    [game addLaneModel:@"single_jump"];
    [game addLaneModel:@"big_hole_2"];
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:30 andJumps:4];
    }
    else {
        [game defineTargetTime:40 andJumps:12];
    }
}

@end
