//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>

@class Scene;
@class UIScene;
@class ModelRegistry;
@class BlazeBallView;

@protocol Controller <NSObject>

- (id)initWithView:(BlazeBallView *)view andRegistry:(ModelRegistry *)modelRegistry;
- (void)update:(double)currentTime;
- (void)touchBegan:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp;
- (void)touchMove:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp;
- (void)touchEnd:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp;
- (void)touchCancelled:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp;
- (void)accelerate:(UIAcceleration *)acceleration;

@property (readonly)Scene *scene;
@property (readonly)UIScene *uiScene;

@end
