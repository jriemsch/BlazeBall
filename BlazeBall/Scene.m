//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "Scene.h"
#import "Model.h"
#import "LaneModel.h"
#import "SceneObject.h"
#import "ModelRegistry.h"
#import "MatrixUtils.h"

@implementation Scene

@synthesize objects = _objects;
@synthesize view = _view;
@synthesize skyObj = _skyObj;

- (id)initWithRegistry:(ModelRegistry *)modelRegistry {
    self = [super init];
    if (self) {
        _modelRegistry = modelRegistry;
        [_modelRegistry retain];

        _objects = [[NSMutableArray alloc] init];
        _lanes = [[NSMutableArray alloc] init];
        _currentLaneTransform = CATransform3DMakeTranslation(0, 0, 0);
    }
    return self;
}

- (void)dealloc {
    [_objects release];
    [_lanes release];
    [_modelRegistry release];
    [super dealloc];
}

- (SceneObject *)addModel:(NSString *)modelId withTransform:(CATransform3D)transform {
    SceneObject *obj = [[SceneObject alloc] init];
    obj.model = [_modelRegistry getById:modelId];
    obj.transform = transform;
    [self.objects addObject:obj];
    [obj release];
    return obj;
}

- (SceneObject *)addLaneModel:(NSString *)modelId {
    SceneObject *obj = [self addModel:modelId withTransform:_currentLaneTransform];
    CATransform3D endTransform = [_modelRegistry getEndTransform:modelId];
    _currentLaneTransform = CATransform3DConcat(endTransform, _currentLaneTransform);
    [_lanes addObject:obj];
    return obj;
}

- (SceneObject *)setSkyModel:(NSString *)modelId {
    SceneObject *obj = [[SceneObject alloc] init];
    obj.model = [_modelRegistry getById:modelId];
    self.skyObj = obj;
    return obj;
}

- (TileInfo)getPosInfo:(float *)posXZ :(int)laneIdx {
    TileInfo info;
    info.beforeOrAfterLane = NO;
    info.found = NO;
    if (laneIdx >= [_lanes count]) {
        return info;
    }
    
    SceneObject *lane = [_lanes objectAtIndex:laneIdx];
    CATransform3D transform = lane.transform;
    CATransform3D inverted = CATransform3DInvert(transform);
    float vector[] = { posXZ[0], 0, posXZ[1] };
    CATransform3DConcatVector(&inverted, vector);
    float posXZInLane[] = { vector[0], vector[2] };
    info = [[lane model] getPosInfo:posXZInLane];
    if (!info.found) {
        return info;
    }
    vector[1] = info.height;
    CATransform3DConcatVector(&transform, vector);
    info.height = vector[1];
    return info;
}

@end
