//  Created by Jens Riemschneider on 9/27/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"

@class SceneObject;
@class ModelRegistry;

@interface UIScene : NSObject {
    NSMutableArray* _objects;
    ModelRegistry* _modelRegistry;
}

- (id)initWithRegistry:(ModelRegistry *)modelRegistry;

- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos;
- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos with:(float *)color;
- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos with:(float *)color hidden:(BOOL)hidden;
- (SceneObject *)addWidgetToFront:(NSString *)widgetId at:(CGRect)pos with:(float *)color;

- (NSArray *)addDigits:(int)numberOfDigits value:(int)value at:(CGRect)pos;
- (NSArray *)addDigits:(int)numberOfDigits value:(int)value at:(CGRect)pos with:(float *)color;
- (NSArray *)addText:(NSString *)text at:(CGRect)pos;
- (NSArray *)addText:(NSString *)text at:(CGRect)pos with:(float *)color;

- (void)changeWidget:(SceneObject *)sceneObj to:(NSString *)widgetId;
- (void)moveWidget:(SceneObject *)sceneObj to:(CGRect)pos;
- (void)moveWidget:(SceneObject *)sceneObj by:(CGSize)diff;
- (void)setDigits:(NSArray *)digitObjs to:(int)number;

- (BOOL)fadeIn:(NSArray *)objs by:(float)value;
- (BOOL)fadeOut:(NSArray *)objs by:(float)value;

- (void)hide:(NSArray *)objs;
- (void)show:(NSArray *)objs;

- (void)changeColor:(NSArray *)objs to:(float *)color;

- (BOOL)rectContainsPoint:(CGRect *)rect point:(CGPoint)pt;


@property (nonatomic, retain) NSMutableArray* objects;


@end
