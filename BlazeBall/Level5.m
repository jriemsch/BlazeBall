//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Level5.h"
#import "GameController.h"

@implementation Level5

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"jump_3"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"jump_3"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"jump_3_2"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_3_2"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_3"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"speed_3_2"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"blocks_3"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"blocks_2"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"blocks_1"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"warp_jump"];
    [game addLaneModel:@"down_6_2"];
    [game addLaneModel:@"down_6"];
    [game addLaneModel:@"big_hole_6"];
    [game addLaneModel:@"single_jump"];            
    [game addLaneModel:@"big_hole_2"];            
    [game addLaneModel:@"down_6_2"];
    [game addLaneModel:@"down_6"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"long_speed_5"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"long_speed_5"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"up_6"];
    [game addLaneModel:@"slow_fast_1"];
    [game addLaneModel:@"slow_fast_1"];
    [game addLaneModel:@"down_6_2"];
    [game addLaneModel:@"down_6_2"];
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:30 andJumps:2];
    }
    else {
        [game defineTargetTime:40 andJumps:7];
    }
}

@end
