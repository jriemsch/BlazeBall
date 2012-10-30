//  Created by Jens Riemschneider on 10/5/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Level4.h"
#import "GameController.h"

@implementation Level4

+ (void)setupLevel:(GameController *)game arcade:(BOOL)arcade {
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"holes_2"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"blocks_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"blocks_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"jump_large_hole_2"];
    [game addLaneModel:@"jump_large_hole_2_2"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"empty_4"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"narrow_6"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"broad_6"];
    [game addLaneModel:@"holes_3"];
    [game addLaneModel:@"empty_8"];
    [game addLaneModel:@"empty_8"];
    
    if (arcade) {
        [game defineTargetTime:35 andJumps:2];
    }
    else {
        [game defineTargetTime:50 andJumps:5];
    }
}

@end
