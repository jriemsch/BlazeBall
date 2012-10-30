//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@interface TextureCache : NSObject {
    NSMutableDictionary *_cache;
}

- (GLuint)loadTexture:(NSString *)fileName;

@end
