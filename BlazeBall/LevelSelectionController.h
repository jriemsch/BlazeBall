//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"

@class Scene;
@class UIScene;
@class SceneObject;
@class BlazeBallView;
@class ModelRegistry;
@class AVAudioPlayer;
@class AudioRegistry;

@interface LevelSelectionController : NSObject <Controller> {
    BlazeBallView *_view;
    ModelRegistry *_modelRegistry;
    AudioRegistry *_audioRegistry;

    Scene *_scene;
    UIScene *_uiScene;
    
    NSArray *_levelButtons;
    NSArray *_labels;
    NSArray *_arcadeLabels;
    NSArray *_trialLabels;
    SceneObject *_arcadeButton;
    SceneObject *_trialButton;
    NSArray *_arcadeHighscoreDigits;
    NSArray *_helpers;
    int _currentHelper;
    BOOL _fadeHelperOut;
    SceneObject *_notesOnButton;
    SceneObject *_notesOffButton;
    
    CGRect _arcadeButtonPos;
    CGRect _trialButtonPos;
    CGRect _notesButtonPos;

    float _aspect;
    
    UIPanGestureRecognizer *_panning;
    UITapGestureRecognizer *_tapping;
    
    float _currentPos;
    float _currentDrag;
    float _currentVelocity;
    float _minPos;
    
    float _prevPos;
    float _buttonSpacing;
    
    double _lastTime;
    
    SceneObject* _pressedButton;
    int _pressedButtonState;
    BOOL _switchController;
    BOOL _fadeButtonsIn;
    
    int _levelArrangement[10];

    AVAudioPlayer *_backgroundMusic;
    
    int _bronzeScores[10];
    int _silverScores[10];
    int _goldScores[10];
    
    BOOL _arcade;
    BOOL _prevArcadeState;
}

@end
