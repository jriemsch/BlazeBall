//  Created by Jens Riemschneider on 9/24/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "Frame.h"
#import "FloorTriangle.h"

@implementation Frame

@synthesize name = _name;
@synthesize transform = _transform;
@synthesize meshSize = _meshSize;
@synthesize mesh = _mesh;
@synthesize triangleCount = _triangleCount;
@synthesize triangles = _triangles;
@synthesize texture = _texture;
@synthesize children = _children;

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        [_name retain];
        _children = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_name release];
    [_texture release];
    [_children release];
    if (_triangles) {
        free(_triangles);
    }
    if (_mesh) {
        free(_mesh);
    }
    [super dealloc];
}

- (TileType)detectTileTypeFromTexture:(float*)tex {
    int u = tex[0] * 4;
    int v = tex[1] * 4;
    if (v == 0) {
        switch (u) {
            case 0: case 1: return TILE_TYPE_NOT_TIMED;
            case 2: case 3: return TILE_TYPE_NORMAL;
        }
    }
    if (v == 1) {
        switch (u) {
            case 0: return TILE_TYPE_SPEED;
            case 1: return TILE_TYPE_SLOW;
            case 2: return TILE_TYPE_BLOCK;
            case 3: return TILE_TYPE_JUMP;
        }
    }
    if (v == 2) {
        switch (u) {
            case 0: return TILE_TYPE_INVERT;
            case 1: return TILE_TYPE_INVERT;
            case 2: return TILE_TYPE_WARP;
            case 3: return TILE_TYPE_HOLE;
        }
    }
    if (v == 3) {
        switch (u) {
            case 1: return TILE_TYPE_SLOW_GLAS;
        }
    }
    return TILE_TYPE_NORMAL;
}

- (BOOL)isSame:(float)f1 as:(float)f2 {
    return f1 > f2 - 0.0001 && f1 < f2 + 0.0001;
}

- (BOOL)isSame:(float *)pt1 as:(float *)pt2 and:(float *)pt3 coord:(int)coord {
    return [self isSame:pt1[coord] as:pt2[coord]] && [self isSame:pt1[coord] as:pt3[coord]];
}

- (NSArray *)createWalkGrid:(float)cellSize from:(float *)from to:(float *)to {
    NSMutableArray *grid = [[NSMutableArray alloc] init];

    for (int idx = 0; idx < _triangleCount; ++idx) {
        short t1 = _triangles[idx * 3];
        short t2 = _triangles[idx * 3 + 1];
        short t3 = _triangles[idx * 3 + 2];
        
        float* pt1 = _mesh[t1].pos;
        float* pt2 = _mesh[t2].pos;
        float* pt3 = _mesh[t3].pos;
        
        *from = MIN(MIN(MIN(*from, pt1[2]), pt2[2]), pt3[2]);
        *to = MAX(MAX(MAX(*to, pt1[2]), pt2[2]), pt3[2]);
        
        if (![self isSame:pt1 as:pt2 and:pt3 coord:0] && ![self isSame:pt1 as:pt2 and:pt3 coord:2]) {
            int ri1 = -pt1[2] / cellSize;
            int ri2 = -pt2[2] / cellSize;
            int ri3 = -pt3[2] / cellSize;
            
            int minRi = MIN(ri1, MIN(ri2, ri3));
            int maxRi = MAX(ri1, MAX(ri2, ri3));
            
            TileType tileType = [self detectTileTypeFromTexture:_mesh[t1].tex];
            
            for (int ri = minRi; ri <= maxRi; ++ri) {
                if (ri >= [grid count]) {
                    for (int i = [grid count]; i <= ri; ++i) {
                        [grid addObject:[NSMutableArray arrayWithCapacity:0]];
                    }
                }
                
                NSMutableArray *gridLine = [grid objectAtIndex:ri];
                [gridLine addObject:[FloorTriangle fromPt1:pt1 pt2:pt2 pt3:pt3 tileType:tileType]];
            }
        }
    }
    return grid;
}

@end
