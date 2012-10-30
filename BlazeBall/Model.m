//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Model.h"
#import "Frame.h"
#import "FrameHierachy.h"
#import "TextureCache.h"

@implementation Model

@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;
@synthesize texture = _texture;
@synthesize triangleCount = _triangleCount;

- (id)initWithFrameHierarchy:(FrameHierachy *)frames withCache:(TextureCache *)cache {
    self = [super init];
    if (self) {
        Frame* frame = [frames.root.children objectAtIndex:0];
        
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * frame.meshSize, frame.mesh, GL_STATIC_DRAW);
        free(frame.mesh);
        frame.mesh = nil;
        
        GLuint indexBuffer;
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * 3 * frame.triangleCount, frame.triangles, GL_STATIC_DRAW);
        free(frame.triangles);
        frame.triangles = nil;
        
        GLuint texture = [cache loadTexture:frame.texture];

        _vertexBuffer = vertexBuffer;
        _indexBuffer = indexBuffer;
        _texture = texture;
        _triangleCount = frame.triangleCount;
    }
    
    return self;
}

@end
