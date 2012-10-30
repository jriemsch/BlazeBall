//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"


@interface SceneObject : NSObject {
    id _model;
    CATransform3D _transform;
    float _color[4];
    BOOL _hidden;
}

@property (nonatomic, retain) id model;
@property (nonatomic) CATransform3D transform;
@property (nonatomic) float *color;
@property (nonatomic) BOOL hidden;
@property (nonatomic) float alpha;

@end
