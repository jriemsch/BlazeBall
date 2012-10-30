//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Level9.h"
#import "GameController.h"

@implementation Level9

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];

    [game addLaneModel:@"left_16"];
    [game addLaneModel:@"speed_slow_lane_right_8"];
    [game addLaneModel:@"speed_slow_lane_left_8"];
    [game addLaneModel:@"right_16"];
    [game addLaneModel:@"speed_slow_lane_left_8"];
    [game addLaneModel:@"speed_slow_lane_right_8"];
    [game addLaneModel:@"right_16"];
    [game addLaneModel:@"slow_lane_left_8"];
    [game addLaneModel:@"slow_lane_right_8"];
    [game addLaneModel:@"left_16"];
    [game addLaneModel:@"slow_lane_right_8"];
    [game addLaneModel:@"slow_lane_left_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"slow_lane_right_8"];
    [game addLaneModel:@"speed_slow_lane_right_8"];
    [game addLaneModel:@"slow_lane_left_8"];
    [game addLaneModel:@"speed_slow_lane_left_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"jump_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"slow_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"jump_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"all_slow_1"];
    [game addLaneModel:@"all_slow_1"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"slow_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"left_16"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"all_slow_1"];
    [game addLaneModel:@"all_slow_1"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"empty_2"];
    [game addLaneModel:@"slow_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"right_16"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_block"];
    [game addLaneModel:@"all_slow_1"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_block"];
    [game addLaneModel:@"jump_block"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_slow_lane_left_8"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"slow_block"];
    [game addLaneModel:@"all_jump_1"];
    [game addLaneModel:@"slow_block"];
 
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:40 andJumps:5];
    }
    else {
        [game defineTargetTime:60 andJumps:15];
    }
    [game defineWarpFieldSpeedFactor: 1.5];
}

@end
