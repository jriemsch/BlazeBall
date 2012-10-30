//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "SceneObject.h"
#import "Model.h"

@implementation SceneObject

@synthesize model = _model;
@synthesize transform = _transform;
@synthesize hidden = _hidden;


- (float *)color { return _color; }
- (void)setColor:(float *)color {
    _color[0] = color[0];
    _color[1] = color[1];
    _color[2] = color[2];
    _color[3] = color[3];
}

- (float)alpha { return _color[3]; }
- (void)setAlpha:(float)alpha { _color[3] = alpha; }

@end
