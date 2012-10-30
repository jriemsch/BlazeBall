//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@class FrameHierachy;
@class TextureCache;

@interface Model : NSObject {
    int _triangleCount;
}

- (id)initWithFrameHierarchy:(FrameHierachy *)frames withCache:(TextureCache *)cache;

@property (nonatomic) GLuint vertexBuffer;
@property (nonatomic) GLuint indexBuffer;
@property (nonatomic) GLuint texture;
@property (nonatomic) int triangleCount;

@end
