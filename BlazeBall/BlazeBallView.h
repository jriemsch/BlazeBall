//  Created by Jens Riemschneider on 9/18/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@protocol Controller;
@class ModelRegistry;
@class HighscoreRepo;

typedef enum {
    MODE_LEVEL_SELECTION,
    MODE_LEVEL
} GameMode;

@interface BlazeBallView : UIView <UIAccelerometerDelegate> {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    CGFloat _scale;
    CGFloat _width;
    CGFloat _height;
    CGFloat _aspect;
    BOOL _multiSample;
    
    GLuint _resolveFrameBuffer;
    GLuint _sampleFramebuffer;
    GLuint _colorRenderBuffer;
    
    GLuint _sceneShaderProgram;
    GLuint _uiSceneShaderProgram;
    GLuint _skyShaderProgram;

    GLuint _posLoc;
    GLuint _texCoordLoc;
    GLuint _normalLoc;
    GLuint _projLoc;
    GLuint _viewLoc;
    GLuint _modelLoc;
    GLuint _textureLoc;
    GLuint _lightPosLoc;
    
    GLuint _uiPosLoc;
    GLuint _uiTexCoordLoc;
    GLuint _uiModelLoc;
    GLuint _uiTextureLoc;
    GLuint _uiColorLoc;
    
    GLuint _skyPosLoc;
    GLuint _skyTexCoordLoc;
    GLuint _skyTextureLoc;
    
    int _level;
    int _bronzeScore;
    int _silverScore;
    int _goldScore;
    BOOL _arcade;
    int _scoreFromLastLevel;
    double _bonusTime;
    int _bonusJump;

    HighscoreRepo *_highscoreRepo;
    ModelRegistry *_modelRegistry;
    id <Controller> _controller;
    GameMode _currentMode;
    
    BOOL _stopped;
}

- (void)switchMode:(GameMode)mode;

@property (nonatomic) int level;
@property (nonatomic, readonly, retain) HighscoreRepo *highscoreRepo;
@property (nonatomic) int bronzeScore;
@property (nonatomic) int silverScore;
@property (nonatomic) int goldScore;
@property (nonatomic) BOOL arcade;
@property (nonatomic) int scoreFromLastLevel;
@property (nonatomic) double bonusTime;
@property (nonatomic) int bonusJump;
@property (nonatomic) BOOL stopMusic;
@property (nonatomic) BOOL stopped;


@end
