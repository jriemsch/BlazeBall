//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"
#import "FloorTriangle.h"

@class SceneObject;
@class ModelRegistry;

@interface Scene : NSObject {
    NSMutableArray* _objects;
    NSMutableArray* _lanes;
    CATransform3D _currentLaneTransform;
    ModelRegistry* _modelRegistry;
    CATransform3D _view;
    SceneObject * _skyObj;
}

- (id)initWithRegistry:(ModelRegistry *)modelRegistry;

- (SceneObject *)addModel:(NSString *)modelId withTransform:(CATransform3D)transform;
- (SceneObject *)addLaneModel:(NSString *)modelId;
- (TileInfo)getPosInfo:(float *)posXZ :(int)laneIdx;
- (SceneObject *)setSkyModel:(NSString *)modelId;

@property (nonatomic, retain) NSMutableArray* objects;
@property (nonatomic) CATransform3D view;
@property (nonatomic, retain) SceneObject *skyObj;

@end
