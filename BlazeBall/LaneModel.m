//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "LaneModel.h"
#import "FrameHierachy.h"
#import "Frame.h"

@implementation LaneModel

- (id)initWithFrameHierarchy:(FrameHierachy *)frames withCache:(TextureCache *)cache {
    Frame* frame = [frames.root.children objectAtIndex:0];
    NSArray *grid = [frame createWalkGrid:20 from:&_minZ to:&_maxZ];
    
    self = [super initWithFrameHierarchy:frames withCache:cache];
    if (self) {
        _grid = grid;
    }
    else {
        [grid release];
    }
    
    return self;
}

- (void)dealloc {
    [_grid release];
    [super dealloc];
}

- (TileInfo)getPosInfo:(float *)posXZ {
    TileInfo info;
    info.beforeOrAfterLane = NO;
    info.found = NO;
    
    if (posXZ[1] < _minZ || posXZ[1] > _maxZ) {
        info.beforeOrAfterLane = YES;
        return info;
    }

    int cell = -posXZ[1] / 20;
    if (cell < 0 || cell >= [_grid count]) {
        NSLog(@"Invalid grid setup");
        info.beforeOrAfterLane = YES;
        return info;
    }
    
    NSArray *gridLine = [_grid objectAtIndex:cell];
    for (FloorTriangle *tri in gridLine) {
        info = [tri getPosInfo:posXZ];
        if (info.found) {
            return info;
        }
    }
    
    return info;
}

@end
