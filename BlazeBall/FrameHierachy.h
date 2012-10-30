//  Created by Jens Riemschneider on 9/24/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@class Frame;

@interface FrameHierachy : NSObject {
    Frame *_root;
}

+ (id)fromFile:(NSString*) fileName;

@property (nonatomic, retain) Frame *root;

@end

