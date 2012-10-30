//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Level2.h"
#import "GameController.h"

@implementation Level2

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"lane_easy_going_1"];
    [game addLaneModel:@"lane_easy_going_2"];
    [game addLaneModel:@"lane_easy_going_3"];
    [game addLaneModel:@"lane_easy_going_4"];
    [game addLaneModel:@"lane_easy_going_5"];
    [game addLaneModel:@"lane_easy_going_6"];
    
    if (arcade) {
        [game defineTargetTime:20 andJumps:2];
    }
    else {
        [game defineTargetTime:30 andJumps:5];
    }
}

@end
