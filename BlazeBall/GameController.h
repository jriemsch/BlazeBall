//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import <Foundation/Foundation.h>
#import "Controller.h"

@class Scene;
@class UIScene;
@class SceneObject;
@class AudioRegistry;
@class BlazeBallView;
@class ModelRegistry;
@class AVAudioPlayer;

@interface GameController : NSObject <Controller> {
    BlazeBallView *_view;
    ModelRegistry *_modelRegistry;
    Scene *_scene;
    UIScene *_uiScene;
    
    BOOL _joystickViaAccel;

    SceneObject* _joystick;
    SceneObject* _joystickFrame;
    CGRect _joystickFramePos;
    CGRect _joystickPos;
    CGRect _fireButtonPos;
    CGPoint _currentJoystickMovement;
    
    float _accelCalibY;
    float _accelCalibSum;
    float _accelMin;
    float _accelMax;
    int _accelCalibCnt;
    BOOL _accelCalibrated;
    float _accelCalibExpectedDeviation;
    
    NSArray *_scoreDigits;
    NSArray *_timeDigits;
    NSArray *_jumpDigits;
    NSArray *_timeBonusDigits;
    NSArray *_jumpBonusDigits;
    NSArray *_totalDigits;
    NSArray *_jumpBonusLabels;
    NSArray *_timeBonusLabels;
    NSArray *_highscoreLabels;
    NSArray *_medal;
    
    double _targetTime;
    int _targetJumps;
    int _usedJumps;
    
    int _bonusTime;
    BOOL _completed;
    int _bonusJump;
    BOOL _countingTimeBonus;
    BOOL _countingJumpBonus;
    BOOL _highscoreCheck;
    BOOL _fadeHighscoreIn;
    BOOL _blendHighscoreToWhite;
    BOOL _blendHighscoreToNormal;
    int _highscoreFlashCnt;
    BOOL _showMedal;
    float _lastBonusLeftOver;
    double _waitTimeAfterBonus;
    BOOL _waitingAfterBonus;
    BOOL _readyForNextLevel;
    
    UITouch* _joystickTouch;
    
    SceneObject* _ball;
    SceneObject* _shadow;
    
    float _lastJump;
    
    BOOL _started;
    BOOL _ended;
    double _startTime;
    double _endTime;
    double _lastTime;
    double _underLaneTime;
    float _currentPos[3];
    int _currentLane;
    float _currentDir[3];
    float _targetDir[3];
    float _currentRotation[2];
    BOOL _onLane;
    BOOL _underLane;
    BOOL _cannotGetBackOnLane;
    double _playerWantedToJumpAt;
    float _referenceHeight;
    float _speedFactor;
    float _lastKnownGoodX;
    BOOL _jumpFromField;
    float _jumpStrength;
    float _speedFieldStrength;
    float _speedFieldFactor;
    BOOL _jumpWithoutSound;
    int _numberOfBounces;
    int _bounces;
    double _warpStart;
    BOOL _invertLeftRight;
    
    float _jumpFieldStrength;
    float _warpFieldSpeedFactor;
    float _holeFieldHeightCorrection;
    
    float _cnt;
    
    AVAudioPlayer *_backgroundMusic;
    AudioRegistry *_audioRegistry;
    double _lastSpeedSound;
    double _lastSlowSound;
    
    int _score;
    int _time;
    BOOL _gameOver;
}

- (void)addLaneModel:(NSString *)modelId;
- (void)defineTargetTime:(double)time andJumps:(int)jumps;
- (void)defineJumpStrengthOfField:(float)strength;
- (void)defineSpeedFieldStrength:(float)strength factor:(float)factor;
- (void)defineWarpFieldSpeedFactor:(float)factor;
- (void)defineHoleFieldHeightCorrection:(float)correction;

@end
