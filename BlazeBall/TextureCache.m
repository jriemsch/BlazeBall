//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "TextureCache.h"

@implementation TextureCache

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_cache release];
    [super dealloc];
}

- (GLuint)loadTexture:(NSString *)fileName {
    NSNumber *texture = [_cache objectForKey:fileName];
    if (texture) {
        return [texture unsignedIntValue];
    }
    
    CGImageRef image = [UIImage imageNamed:fileName].CGImage;
    if (!image) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGColorSpaceRef space = CGImageGetColorSpace(image);
    
    GLubyte *data = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, width * 4, space, kCGImageAlphaPremultipliedLast);    
    CGContextDrawImage(ctx, rect, image);
    CGContextRelease(ctx);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    free(data);
    
    [_cache setObject:[NSNumber numberWithUnsignedInt:texName] forKey:fileName];
    
    return texName;    
}



@end
