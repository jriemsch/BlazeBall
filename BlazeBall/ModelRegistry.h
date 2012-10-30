//  Created by Jens Riemschneider on 9/26/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class Model;
@class TextureCache;

@interface ModelRegistry : NSObject {
    NSMutableDictionary *_models;
    NSMutableDictionary *_frames;
    TextureCache *_cache;
}

- (void)registerModel:(NSString *)modeId withType:(Class)type;
- (id)getById:(NSString *)modelId;
- (CATransform3D)getEndTransform:(NSString *)modelId;

@end
