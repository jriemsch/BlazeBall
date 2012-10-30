//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Model.h"
#import "FloorTriangle.h"

@interface LaneModel : Model {
    NSArray *_grid;
    float _minZ;
    float _maxZ;
}

- (id)initWithFrameHierarchy:(FrameHierachy *)frames withCache:(TextureCache *)cache;
- (TileInfo)getPosInfo:(float *)posXZ;

@end
