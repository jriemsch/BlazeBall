//  Created by Jens Riemschneider on 9/24/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"


typedef struct {
    float pos[3];
    float normal[3];
    float tex[2];
} Vertex;

@interface Frame : NSObject {
    int _meshSize;
    int _triangleCount;
    Vertex* _mesh;
    short* _triangles;
}

- (id)initWithName:(NSString *)name;
- (NSArray *)createWalkGrid:(float)cellSize from:(float *)from to:(float *)to;

@property (nonatomic, retain) NSString *name;
@property (nonatomic) CATransform3D transform;
@property (nonatomic) int meshSize;
@property (nonatomic) Vertex *mesh;
@property (nonatomic) int triangleCount;
@property (nonatomic) short *triangles;
@property (nonatomic, retain) NSString *texture;
@property (nonatomic, retain) NSMutableArray *children;

@end
