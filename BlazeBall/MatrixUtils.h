//  Created by Jens Riemschneider on 9/24/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#pragma once

#include "QuartzCore/QuartzCore.h"

CATransform3D CATransform3DMakeProjection(CGFloat fov, CGFloat aspect, CGFloat znear, CGFloat zfar);
void CATransform3DConcatVector(CATransform3D *transform, float *vector);
