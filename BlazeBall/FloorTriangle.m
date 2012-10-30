//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "FloorTriangle.h"

@implementation FloorTriangle

+ (id)fromPt1:(float*)pt1 pt2:(float*)pt2 pt3:(float*)pt3 tileType:(TileType)tileType {
    FloorTriangle *tri = [[FloorTriangle alloc] init];
    if (!tri) {
        return nil;
    }
    tri->_pt1[0] = pt1[0];
    tri->_pt1[1] = pt1[1];
    tri->_pt1[2] = pt1[2];
    tri->_pt2[0] = pt2[0];
    tri->_pt2[1] = pt2[1];
    tri->_pt2[2] = pt2[2];
    tri->_pt3[0] = pt3[0];
    tri->_pt3[1] = pt3[1];
    tri->_pt3[2] = pt3[2];
    
    tri->_minX = MIN(pt1[0], MIN(pt2[0], pt3[0]));
    tri->_maxX = MAX(pt1[0], MAX(pt2[0], pt3[0]));
    tri->_minZ = MIN(pt1[2], MIN(pt2[2], pt3[2]));
    tri->_maxZ = MAX(pt1[2], MAX(pt2[2], pt3[2]));
    
    tri->_tileType = tileType;
    
    return [tri autorelease];
}

- (TileInfo)getPosInfo:(float*)posXZ {
    TileInfo info;
    info.found = NO;
    info.beforeOrAfterLane = NO;
    
    float x = posXZ[0];
    float z = posXZ[1];
    
    if (x < _minX || x > _maxX || z < _minZ || z > _maxZ) {
        return info;
    }
    
    float v0x = _pt1[0];
    float v0z = _pt1[2];
    
    float v1x = _pt2[0] - v0x;
    float v1z = _pt2[2] - v0z;
    
    float v2x = _pt3[0] - v0x;
    float v2z = _pt3[2] - v0z;
    
    float detvv2 = x * v2z - z * v2x;
    float detv0v2 = v0x * v2z - v0z * v2x;
    float detv1v2 = v1x * v2z - v1z * v2x;
    
    if (detv1v2 == 0) {
        return info;
    }
    
    float u = (detvv2 - detv0v2) / detv1v2;
    if (u < 0 || u > 1) {
        return info;
    }

    float detvv1 = x * v1z - z * v1x;
    float detv0v1 = v0x * v1z - v0z * v1x;
    float v = -(detvv1 - detv0v1) / detv1v2;
    if (v < 0 || u + v > 1) {
        return info;
    }

    info.found = YES;
    info.height = _pt1[1] + u * (_pt2[1] - _pt1[1]) + v * (_pt3[1] - _pt1[1]);
    info.tileType = _tileType;
    return info;
}

@end
