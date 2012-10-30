//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
    TILE_TYPE_NOT_TIMED,
    TILE_TYPE_NORMAL,
    TILE_TYPE_JUMP,
    TILE_TYPE_SPEED,
    TILE_TYPE_SLOW,
    TILE_TYPE_BLOCK,
    TILE_TYPE_HOLE,
    TILE_TYPE_WARP,
    TILE_TYPE_INVERT,
    TILE_TYPE_SLOW_GLAS
} TileType;

typedef struct {
    BOOL found;
    float height;
    TileType tileType;
    BOOL beforeOrAfterLane;
} TileInfo;

@interface FloorTriangle : NSObject {
    float _pt1[3];
    float _pt2[3];
    float _pt3[3];
    
    float _minX;
    float _maxX;
    float _minZ;
    float _maxZ;
    
    TileType _tileType;
}

- (TileInfo)getPosInfo:(float*)posXZ;

+ (id)fromPt1:(float*)pt1 pt2:(float*)pt2 pt3:(float*)pt3 tileType:(TileType)tileType;


@end
