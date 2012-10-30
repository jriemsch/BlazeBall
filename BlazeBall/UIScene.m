//  Created by Jens Riemschneider on 9/27/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "UIScene.h"
#import "Model.h"
#import "ModelRegistry.h"
#import "SceneObject.h"

@implementation UIScene

@synthesize objects = _objects;

- (id)initWithRegistry:(ModelRegistry *)modelRegistry {
    self = [super init];
    if (self) {
        _modelRegistry = modelRegistry;
        [_modelRegistry retain];
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_objects release];
    [_modelRegistry release];
    [super dealloc];
}

- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos with:(float *)color hidden:(BOOL)hidden {
    SceneObject *obj = [[SceneObject alloc] init];
    obj.model = [_modelRegistry getById:widgetId];
    obj.color = color;
    obj.hidden = hidden;
    [self moveWidget:obj to:pos];
    [self.objects addObject:obj];
    [obj release];
    return obj;
}

- (SceneObject *)addWidgetToFront:(NSString *)widgetId at:(CGRect)pos with:(float *)color {
    SceneObject *obj = [[SceneObject alloc] init];
    obj.model = [_modelRegistry getById:widgetId];
    obj.color = color;
    obj.hidden = NO;
    [self moveWidget:obj to:pos];
    [self.objects insertObject:obj atIndex:0];
    [obj release];
    return obj;
}

- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos with:(float *)color {
    return [self addWidget:widgetId at:pos with:color hidden:NO];
}

- (SceneObject *)addWidget:(NSString *)widgetId at:(CGRect)pos {
    float white[] = { 1, 1, 1, 1 };
    return [self addWidget:widgetId at:pos with:white hidden:NO];
}

- (void)changeWidget:(SceneObject *)sceneObj to:(NSString *)widgetId {
    sceneObj.model = [_modelRegistry getById:widgetId];
}

- (void)moveWidget:(SceneObject *)sceneObj to:(CGRect)pos {
    float scaleX = pos.size.width;
    float scaleY = pos.size.height;
    CATransform3D scale = CATransform3DMakeScale(scaleX, scaleY, 1);
    
    float moveX = pos.origin.x;
    float moveY = pos.origin.y;
    CATransform3D move = CATransform3DMakeTranslation(moveX, moveY, 0);
    
    CATransform3D rotation = CATransform3DMakeRotation(-M_PI / 2, 0, 0, 1);
    
    sceneObj.transform = CATransform3DConcat(CATransform3DConcat(scale, move), rotation);
}

- (void)moveWidget:(SceneObject *)sceneObj by:(CGSize)diff {
    CATransform3D transform = sceneObj.transform;
    float x = sceneObj.transform.m42;
    float y = sceneObj.transform.m41;
    transform.m41 = y + diff.height;
    transform.m42 = x - diff.width;
    sceneObj.transform = transform;
}

- (void)setDigits:(NSArray *)digitObjs to:(int)number {
    int value = number;
    for (SceneObject *obj in digitObjs) {
        int digit = value % 10;
        [self changeWidget:obj to:[NSString stringWithFormat:@"%d", digit]];
        value /= 10;
    }
}

- (NSArray *)addDigits:(int)numberOfDigits value:(int)value at:(CGRect)pos {
    float white[] = { 1, 1, 1, 1 };
    return [self addDigits:numberOfDigits value:value at:pos with:white];
}

- (NSArray *)addDigits:(int)numberOfDigits value:(int)value at:(CGRect)pos with:(float *)color {
    NSMutableArray *digits = [[NSMutableArray alloc] init];
    pos.origin.x += numberOfDigits * pos.size.width;
    for (int idx = numberOfDigits - 1; idx >= 0; --idx) {
        [digits addObject:[self addWidget:@"0" at:pos with:color]];
        pos.origin.x -= pos.size.width;
    }
    [self setDigits:digits to:value];
    return digits;
}

- (NSArray *)addText:(NSString *)text at:(CGRect)pos {
    float white[] = { 1, 1, 1, 1 };
    return [self addText:text at:pos with:white];
}

- (NSArray *)addText:(NSString *)text at:(CGRect)pos with:(float *)color {
    NSMutableArray *digits = [[NSMutableArray alloc] init];
    int len = [text length];
    for (int idx = 0; idx < len; ++idx) {
        NSString *widgetId = [text substringWithRange:NSMakeRange(idx, 1)];
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[text characterAtIndex:idx]]) {
            widgetId = [NSString stringWithFormat:@"u%@", [widgetId lowercaseString]];
        }
        [digits addObject:[self addWidget:widgetId at:pos with:color]];
        pos.origin.x += pos.size.width - 0.01;
    }
    return digits;
}

- (BOOL)fadeIn:(NSArray *)objs by:(float)value {
    BOOL done = YES;
    for (SceneObject *obj in objs) {
        obj.alpha = MIN(1, obj.alpha + value);
        if (obj.alpha < 1) {
            done = NO;
        }
    }
    return done;
}

- (BOOL)fadeOut:(NSArray *)objs by:(float)value {
    BOOL done = YES;
    for (SceneObject *obj in objs) {
        obj.alpha = MAX(0, obj.alpha - value);
        if (obj.alpha > 0) {
            done = NO;
        }
    }
    return done;
}

- (void)hide:(NSArray *)objs {
    for (SceneObject *obj in objs) { obj.hidden = YES; }
}

- (void)show:(NSArray *)objs {
    for (SceneObject *obj in objs) { obj.hidden = NO; }
}

- (void)changeColor:(NSArray *)objs to:(float *)color {
    for (SceneObject *obj in objs) { obj.color = color; }
}

- (BOOL)rectContainsPoint:(CGRect *)rect point:(CGPoint)pt {
    float halfWidth = rect->size.width / 2;
    float halfHeight = rect->size.height / 2;
    CGRect dispRect = CGRectMake(rect->origin.x - halfWidth, rect->origin.y - halfHeight, rect->size.width, rect->size.height);
    return CGRectContainsPoint(dispRect, pt);
}

@end
