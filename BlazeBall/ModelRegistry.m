//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "ModelRegistry.h"
#import "FrameHierachy.h"
#import "Model.h"
#import "Frame.h"
#import "TextureCache.h"

@implementation ModelRegistry

- (id)init {
    self = [super init];
    if (self) {
        _models = [[NSMutableDictionary alloc] init];
        _frames = [[NSMutableDictionary alloc] init];
        _cache = [[TextureCache alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_models release];
    [_frames release];
    [_cache release];
    [super dealloc];
}

- (void)registerModel:(NSString *)modelId withType:(Class)type {
    if ([_models objectForKey:modelId]) {
        return;
    }
    
    FrameHierachy *frames = [FrameHierachy fromFile:modelId];
    Model *model = [[type alloc] initWithFrameHierarchy:frames withCache:_cache];
    [_models setObject:model forKey:modelId];
    [_frames setObject:frames forKey:modelId];
    [model release];
}

- (id)getById:(NSString *)modelId {
    return [_models objectForKey:modelId];
}

- (CATransform3D)getEndTransform:(NSString *)modelId {
    FrameHierachy *frames = [_frames objectForKey:modelId];
    Frame *frame = [frames.root.children objectAtIndex:1];
    return frame.transform;
}

@end
