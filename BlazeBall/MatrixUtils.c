//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#include "MatrixUtils.h"

CATransform3D CATransform3DMakeProjection(CGFloat fov, CGFloat aspect, CGFloat znear, CGFloat zfar) {
    
    CGFloat xymax = znear * tan(fov * M_PI / 360);
    CGFloat ymin = -xymax;
    CGFloat xmin = -xymax;
    
    CGFloat width = xymax - xmin;
    CGFloat height = xymax - ymin;
    
    CGFloat depth = zfar - znear;
    CGFloat q = -(zfar + znear) / depth;
    CGFloat qn = -2 * (zfar * znear) / depth;
    
    CGFloat w = 2 * znear / width;
    w = w / aspect;
    CGFloat h = 2 * znear / height;
    
    CATransform3D m;
    m.m11  = 0;
    m.m12  = -h;
    m.m13  = 0;
    m.m14  = 0;
    
    m.m21  = w;
    m.m22  = 0;
    m.m23  = 0;
    m.m24  = 0;
    
    m.m31  = 0;
    m.m32  = 0;
    m.m33 = q;
    m.m34 = -1;
    
    m.m41 = 0;
    m.m42 = 0;
    m.m43 = qn;
    m.m44 = 0;
    
    return m;
}

void CATransform3DConcatVector(CATransform3D *transform, float *vector) {
    float x = vector[0];
    float y = vector[1];
    float z = vector[2];
    vector[0] = transform->m11 * x + transform->m21 * y + transform->m31 * z + transform->m41;
    vector[1] = transform->m12 * x + transform->m22 * y + transform->m32 * z + transform->m42;
    vector[2] = transform->m13 * x + transform->m23 * y + transform->m33 * z + transform->m43;
}
