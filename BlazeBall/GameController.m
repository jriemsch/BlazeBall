//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "GameController.h"
#import "MatrixUtils.h"
#import "LaneModel.h"
#import "Model.h"
#import "Frame.h"
#import "Scene.h"
#import "SceneObject.h"
#import "UIScene.h"
#import "AudioRegistry.h"
#import "BlazeBallView.h"
#import "ModelRegistry.h"
#import "HighscoreRepo.h"
#import "Level1.h"
#import "Level2.h"
#import "Level3.h"
#import "Level4.h"
#import "Level5.h"
#import "Level6.h"
#import "Level7.h"
#import "Level8.h"
#import "Level9.h"
#import "Level10.h"
#import "AVFoundation/AVAudioPlayer.h"

@implementation GameController

@synthesize uiScene = _uiScene;
@synthesize scene = _scene;

- (void)cullScene {
    int idx = 0;
    for (SceneObject *obj in _scene.objects) {
        float diff = obj.transform.m43 - _currentPos[2];
        obj.hidden = diff < -300 || (diff > 10 && idx != _currentLane);
        ++idx;
    }
}

- (void)updateView {
    CATransform3D move = CATransform3DMakeTranslation(-_currentPos[0], -_referenceHeight - 3, -_currentPos[2] - 5);
    CATransform3D rotate = CATransform3DMakeRotation(0.3, 1, 0, 0);
    _scene.view = CATransform3DConcat(move, rotate);
}

- (void)frameCounting:(double)currentTime {
    _cnt += 1;
    NSLog(@"%f", _cnt / (currentTime - _startTime));
    
    if (currentTime - _startTime > 5) {
        _startTime = currentTime;
        _cnt = 0;
    }
}

- (TileInfo)getPosInfo {
    float posXZ[] = { _currentPos[0], _currentPos[2] };
    TileInfo info = [_scene getPosInfo:posXZ :_currentLane];
    if (info.beforeOrAfterLane) {
        ++_currentLane;
        info = [_scene getPosInfo:posXZ :_currentLane];
    }
    if (!info.found) {
        float offset = 0;
        int steps = 0;
        while (!info.found) {
            posXZ[0] = _lastKnownGoodX + offset;
            info = [_scene getPosInfo:posXZ :_currentLane];
            if (!info.found) {
                posXZ[0] = _lastKnownGoodX - offset;
                info = [_scene getPosInfo:posXZ :_currentLane];
            }
            offset += 0.05;
            ++steps;
        }
        if (!info.found) {
            NSLog(@"Invalid State. No lane position found");
        }
        _currentPos[0] = posXZ[0];
    }
    if (info.found && (info.tileType == TILE_TYPE_HOLE || info.tileType == TILE_TYPE_SLOW_GLAS)) {
        info.height += _holeFieldHeightCorrection;
    }
    return info;
}

- (TileType)checkDirPosForSameField:(TileType)tileType {
    float dx = MIN(0.5, MAX(-0.5, _currentDir[0] * 0.2));
    float dz = MIN(0.5, MAX(-0.5, _currentDir[2] * 0.1));
    
    float testPosNext[] = { _currentPos[0] + dx, _currentPos[2] + dz };
    TileInfo info = [_scene getPosInfo:testPosNext :_currentLane];
    if (info.beforeOrAfterLane) {
        info = [_scene getPosInfo:testPosNext :_currentLane + 1];
    }
    if (info.found && info.tileType != tileType) {
        return info.tileType;
    }
    
    float testPosPrev[] = { _currentPos[0] - dx, _currentPos[2] - dz };
    info = [_scene getPosInfo:testPosPrev :_currentLane];
    if (info.beforeOrAfterLane) {
        info = [_scene getPosInfo:testPosPrev :_currentLane - 1];
    }
    if (info.found && info.tileType != tileType) {
        return info.tileType;
    }
    
    return tileType;
}

- (void)getPosInsideField:(TileType)tileType dx:(float *)dx dz:(float *)dz {
    *dx = 0;
    *dz = 0;

    float testPosLeft[] = { _currentPos[0] - 0.5, _currentPos[2] };
    TileInfo info = [_scene getPosInfo:testPosLeft :_currentLane];
    if (info.found && info.tileType != tileType) {
        *dx = +0.5;
        return;
    }

    float testPosRight[] = { _currentPos[0] + 0.5, _currentPos[2] };
    info = [_scene getPosInfo:testPosRight :_currentLane];
    if (info.found && info.tileType != tileType) {
        *dx = -0.5;
        return;
    }

    float testPosForward[] = { _currentPos[0], _currentPos[2] - 0.5 };
    info = [_scene getPosInfo:testPosForward :_currentLane];
    if (info.found && info.tileType != tileType) {
        *dz = 0.5;
        return;
    }

    float testPosBackward[] = { _currentPos[0], _currentPos[2] + 0.5 };
    info = [_scene getPosInfo:testPosBackward :_currentLane];
    if (info.found && info.tileType != tileType) {
        *dz = -0.5;
        return;
    }
}

- (void)checkFields:(TileInfo *)info at:(double)currentTime {
    if (info->tileType == TILE_TYPE_INVERT) {
        _invertLeftRight = YES;
    }
    
    else if (info->tileType == TILE_TYPE_NORMAL) {
        _invertLeftRight = NO;
    }
    
    if (info->tileType != TILE_TYPE_NOT_TIMED && !_started) {
        _started = YES;
        _startTime = currentTime;
    }
    
    if (info->tileType == TILE_TYPE_NOT_TIMED && _started && !_ended) {
        _ended = YES;
        _endTime = currentTime;
        [_audioRegistry play:@"leveldone"];
    }
    
    if (!_onLane) {
        if (info->tileType != TILE_TYPE_SLOW && info->tileType != TILE_TYPE_SLOW_GLAS) {
            _lastSlowSound = 0;
        }
        if (info->tileType != TILE_TYPE_SPEED) {
            _lastSpeedSound = 0;
        }
        return;
    }
    
    if (info->tileType == TILE_TYPE_HOLE || info->tileType == TILE_TYPE_BLOCK) {
        info->tileType = [self checkDirPosForSameField:info->tileType];
    }
    
    if (info->tileType == TILE_TYPE_HOLE) {
        [_audioRegistry play:@"hole"];
        float dx, dz;
        [self getPosInsideField:info->tileType dx:&dx dz:&dz];
        _targetDir[0] = 0;
        _currentDir[0] = dx * 10;
        _targetDir[1] = _currentDir[1] = -1;
        _targetDir[2] = 0;
        _currentDir[2] = dz * 10;
        _onLane = NO;
        _cannotGetBackOnLane = YES;
        _warpStart = 0;
    }
    
    if (info->tileType == TILE_TYPE_JUMP) {
        _playerWantedToJumpAt = currentTime;
        _jumpFromField = YES;
        _jumpStrength = _jumpFieldStrength;
        _numberOfBounces = 1;
    }
    
    if (info->tileType == TILE_TYPE_BLOCK) {
        [_audioRegistry play:@"block"];
        _targetDir[2] = _currentDir[2] = MAX(10, -_currentDir[2] / 2);
        _warpStart = 0;
    }
    
    float prevSpeedFactor = _speedFactor;
    if (info->tileType == TILE_TYPE_WARP) {
        [_audioRegistry play:@"warp"];
        _speedFactor = _warpFieldSpeedFactor;
        _warpStart = currentTime;
    }
    if (_warpStart == 0 || currentTime - _warpStart > 3) {
        if (info->tileType == TILE_TYPE_SLOW || info->tileType == TILE_TYPE_SLOW_GLAS)  {
            if (currentTime - _lastSlowSound > 0.5) {
                [_audioRegistry play:@"slow"];
                _lastSlowSound = currentTime;
            }
            _speedFactor = 0.3;
            _lastSpeedSound = 0;
        }
        else if (info->tileType == TILE_TYPE_SPEED) {
            if (currentTime - _lastSpeedSound > 0.5) {
                [_audioRegistry play:@"speed"];
                _lastSpeedSound = currentTime;
            }
            _playerWantedToJumpAt = currentTime;
            _jumpFromField = YES;
            _jumpStrength = _speedFieldStrength;
            _numberOfBounces = 0;
            _jumpWithoutSound = YES;
            _speedFactor = _speedFieldFactor;
            _lastSlowSound = 0;
            if (_lastJump == 0) {
                _lastJump = _currentPos[2];
            }
            NSLog(@"Jump: %f", _currentPos[2] - _lastJump);
        }
        else {
            _speedFactor = 1;
            _lastSlowSound = 0;
            _lastSpeedSound = 0;
        }
    }
    
    if (prevSpeedFactor != _speedFactor) {
        _targetDir[0] *= _speedFactor / prevSpeedFactor;
        _targetDir[2] *= _speedFactor / prevSpeedFactor;
    }
}

- (void)updateTargetDir {
    if (_ended) {
        _targetDir[0] = 0;
        _targetDir[1] = 0;
        _targetDir[2] = 0;
        return;
    }
    
    float x = _invertLeftRight ? -_currentJoystickMovement.x : _currentJoystickMovement.x;
    if (x < -0.01) {
        _targetDir[0] = -sqrt(-x - 0.01) * 16;
    }
    else if (x > 0.01) {
        _targetDir[0] = sqrt(x - 0.01) * 16; 
    }
    else {
        _targetDir[0] = 0;
    }
    
    _targetDir[2] = -(_currentJoystickMovement.y + 1.1) * (_currentJoystickMovement.y + 1.1) * 8 * _speedFactor;
}

- (void)updateCurrentDir:(double)diff {
    _currentDir[0] += (_targetDir[0] - _currentDir[0]) * 4 * diff;
    _currentDir[1] = _targetDir[1];
    _currentDir[2] += (_targetDir[2] - _currentDir[2]) * 4 * diff;
}

- (void)updateCurrentPos:(double)diff {
    if (!_underLane) {
        _currentPos[0] += _currentDir[0] * diff;
        _currentPos[2] += _currentDir[2] * diff;
    }
    _currentPos[1] += _currentDir[1] * diff;
}

- (void)updateBallTransform:(double)diff {
    float speed = sqrt(_currentDir[0] * _currentDir[0] + _currentDir[1] * _currentDir[1] + _currentDir[2] * _currentDir[2]);
    _currentRotation[0] -= speed * diff / 2;
    _currentRotation[1] = 3 * M_PI_2 - atan2f(_currentDir[2], _currentDir[0]);
    
    _ball.transform = CATransform3DMakeTranslation(_currentPos[0], _currentPos[1], _currentPos[2]);
    _ball.transform = CATransform3DScale(_ball.transform, 0.4, 0.4, 0.4);
    _ball.transform = CATransform3DRotate(_ball.transform, _currentRotation[1], 0, 1, 0);
    _ball.transform = CATransform3DRotate(_ball.transform, _currentRotation[0], 1, 0, 0);
}

- (void)updateBallShadow {
    float dist = 1.0 + fabs(_currentPos[1] - _referenceHeight);
    float scale = 4.0 / (4.0 + dist);
    float posXZ[] = { _currentPos[0] - 0.1 * dist, _currentPos[2] - 0.2 * dist };
    TileInfo info = [_scene getPosInfo:posXZ :_currentLane];
    if (!info.found) {
        info = [_scene getPosInfo:posXZ :_currentLane + 1];
    }
    _shadow.transform = CATransform3DMakeTranslation(posXZ[0], _referenceHeight - 0.39, posXZ[1]);
    _shadow.transform = CATransform3DRotate(_shadow.transform, M_PI_2, 1, 0, 0);
    _shadow.transform = CATransform3DScale(_shadow.transform, scale, scale, scale);
    _shadow.hidden = !info.found || info.tileType == TILE_TYPE_HOLE || _currentPos[1] < _referenceHeight - 0.5;
}

- (void)performJump:(double)diff {
    if (_view.arcade && _usedJumps >= _targetJumps && !_jumpFromField) {
        _playerWantedToJumpAt = 0;
        return;
    }
    
    if (!_jumpWithoutSound) {
        [_audioRegistry play:@"jump"];
    }
    if (!_jumpFromField) {
        ++_usedJumps;
    }
    _targetDir[1] = _currentDir[1] = _jumpFromField ? _jumpStrength : 4;
    _bounces = _jumpFromField ? _numberOfBounces : 0;
    _jumpFromField = NO;
    _currentPos[1] += _currentDir[1] * diff;
    _onLane = NO;
    _jumpWithoutSound = NO;
    _playerWantedToJumpAt = 0;
}

- (void)throwBallBack {
    [_audioRegistry play:@"restart"];
    _underLaneTime = 0;
    _currentPos[0] = _lastKnownGoodX;
    _currentPos[1] = _referenceHeight;
    _targetDir[0] = _currentDir[0] = -_currentDir[0] / 2;
    _targetDir[1] = _currentDir[1] = 8.5;
    _targetDir[2] = _currentDir[2] = -10;
    _onLane = NO;
    _underLane = NO;
    _cannotGetBackOnLane = NO;
    _numberOfBounces = 0;
}

- (void)updateScoreAndTime:(double)currentTime {
    if (!_ended) {
        _score = MAX(_score, (-_currentPos[2] - 80) / 4);
    }
    
    [_uiScene setDigits:_scoreDigits to:_score];
    
    double elapsedTime = (_started ? ((_ended ? _endTime : currentTime) - _startTime) : 0);
    _time = MAX(0, (_targetTime - elapsedTime) * 100);
    [_uiScene setDigits:_timeDigits to:_time];
    
    [_uiScene setDigits:_jumpDigits to:MAX(0, _targetJumps - _usedJumps)];

    if (_view.arcade && _time <= 0 && !_gameOver) {
        _gameOver = YES;
        _ended = YES;
        _endTime = currentTime;
        [_audioRegistry play:@"gameover"];
    }
}

- (BOOL)blendLabels:(NSArray *)labels by:(float)diff to:(float)target {
    for (SceneObject *obj in labels) { 
        float *color = obj.color;
        color[0] += diff;
        color[1] += diff;
        color[2] += diff;
    } 
    SceneObject *anyObj = [labels objectAtIndex:0];
    float *color = anyObj.color;
    if (diff > 0) {
        return color[0] >= target && color[1] >= target && color[2] >= target;
    }
    return color[0] <= target && color[1] <= target && color[2] <= target;
}

- (void)checkEnd:(double)diff {
    if (!_ended || _currentDir[2] < -0.1) {
        return;
    }
    
    if (!_countingTimeBonus) {
        _view.bonusJump = MAX(0, _targetJumps - _usedJumps);
        _view.bonusTime = MAX(0, (_targetTime - _endTime + _startTime));
        
        _bonusTime = _view.bonusTime * 100;
        _completed = _bonusTime > 0;
        _bonusJump = _view.arcade ? 0 : _view.bonusJump;
        _gameOver |= _view.arcade && _view.level == 9;

        SceneObject *anyObj = [_timeBonusLabels objectAtIndex:0];
        float alpha = MIN(1, anyObj.alpha + diff * 2);
        for (SceneObject *obj in _timeBonusLabels) { obj.alpha = alpha; obj.hidden = NO; } 
        for (SceneObject *obj in _timeBonusDigits) { obj.alpha = alpha; obj.hidden = NO; } 
        if (!_view.arcade) {
            for (SceneObject *obj in _jumpBonusLabels) { obj.alpha = alpha; obj.hidden = NO; } 
            for (SceneObject *obj in _jumpBonusDigits) { obj.alpha = alpha; obj.hidden = NO; } 
        }
        for (SceneObject *obj in _totalDigits) { obj.alpha = alpha; obj.hidden = NO; } 
        if (alpha >= 1) {
            _countingTimeBonus = YES;
            _lastBonusLeftOver = 0;
        }
    }
    
    if (_countingTimeBonus && !_countingJumpBonus) {
        if (_bonusTime > 0) {
            int decr = MIN(_bonusTime, (diff + _lastBonusLeftOver) * 500);
            if (decr > 0) {
                [_audioRegistry play:@"jump"];
            }
            _lastBonusLeftOver = diff + _lastBonusLeftOver - (float)decr / 500;
            _bonusTime -= decr;
            int bonus = _view.arcade ? 5 : 10;
            _score += decr * bonus;
        }
        else {
            _countingJumpBonus = YES;
            _lastBonusLeftOver = 0;            
        }
    }
    
    if (_countingJumpBonus && !_highscoreCheck) {
        if (_bonusJump > 0) {
            int decr = MIN(_bonusJump, (diff + _lastBonusLeftOver) * 2);
            if (decr > 0) {
                [_audioRegistry play:@"jump"];
            }
            _lastBonusLeftOver = diff + _lastBonusLeftOver - (float)decr / 2;
            _bonusJump -= decr;
            _score += decr * 1000;
        }
        else {
            _highscoreCheck = YES;
            _lastBonusLeftOver = 0;
            _waitTimeAfterBonus = 3;
            _waitingAfterBonus = _view.arcade && !_gameOver;
            _view.scoreFromLastLevel = _score;
        }
    }
    
    if (_highscoreCheck && !_waitingAfterBonus && !_fadeHighscoreIn) {
        int scoreWithCompleted = _completed || _view.arcade ? _score : -_score;
        int level = _view.arcade ? -1 : _view.level;
        if ([_view.highscoreRepo checkForLevel:level with:scoreWithCompleted]) {
            _fadeHighscoreIn = YES;
            [_audioRegistry play:@"highscore"];
        }
        else {
            _waitingAfterBonus = YES;
        }
    }
    
    if (_fadeHighscoreIn && !_blendHighscoreToWhite) {
        SceneObject *anyObj = [_highscoreLabels objectAtIndex:0];
        float alpha = MIN(2, anyObj.alpha + diff * 40);
        for (SceneObject *obj in _highscoreLabels) { obj.alpha = alpha; obj.hidden = NO; } 
        if (alpha >= 2) {
            _blendHighscoreToWhite = YES;
        }
    }
    
    if (_blendHighscoreToWhite && !_blendHighscoreToNormal) {
        _blendHighscoreToNormal = [self blendLabels:_highscoreLabels by:diff * 40 to:2];
    }
    
    if (_blendHighscoreToNormal && !_showMedal) {
        if ([self blendLabels:_highscoreLabels by:-diff * 40 to:1]) {
            ++_highscoreFlashCnt;
            _showMedal = _blendHighscoreToNormal = _highscoreFlashCnt == 4;
            if (_showMedal) {
                float yellow[] = { 1, 0.8, 0, 1 };
                for (SceneObject *obj in _highscoreLabels) { obj.color = yellow; } 

                if (_score > _view.bronzeScore && !_view.arcade) {
                    float bronze[] = { 1, 0.8, 0.6, 0 };
                    float silver[] = { 0.95, 0.95, 1, 0 };
                    float gold[] = { 1, 0.75, 0.3, 0 };
                    float *color = _score > _view.silverScore ? _score > _view.goldScore ? gold : silver : bronze;
                    for (SceneObject *obj in _medal) { obj.color = color; obj.hidden = NO; } 
                } 
                else {
                    _waitingAfterBonus = YES;
                }
            }
        }
    }
    
    if (_showMedal && !_waitingAfterBonus) {
        _waitingAfterBonus = [_uiScene fadeIn:_medal by:diff];
    }
    
    if (_waitingAfterBonus) {
        if (_waitTimeAfterBonus > 0) {
            _waitTimeAfterBonus -= diff;
            _backgroundMusic.volume -= diff / 3;
        }
        else {
            SceneObject *anyObj = [_timeBonusLabels objectAtIndex:0];
            if (anyObj.alpha <= 0) {
                _readyForNextLevel = YES;
            }
            else {
                float alpha = MAX(0, anyObj.alpha - diff * 2);
                for (SceneObject *obj in _timeBonusLabels) { obj.alpha = alpha; obj.hidden = NO; } 
                for (SceneObject *obj in _timeBonusDigits) { obj.alpha = alpha; obj.hidden = NO; } 
                if (!_view.arcade) {
                    for (SceneObject *obj in _jumpBonusLabels) { obj.alpha = alpha; obj.hidden = NO; } 
                    for (SceneObject *obj in _jumpBonusDigits) { obj.alpha = alpha; obj.hidden = NO; } 
                }
                for (SceneObject *obj in _totalDigits) { obj.alpha = alpha; obj.hidden = NO; } 
            }
        }
    }
    
    [_uiScene setDigits:_timeBonusDigits to:_bonusTime];
    [_uiScene setDigits:_jumpBonusDigits to:_bonusJump];
    [_uiScene setDigits:_totalDigits to:_score];
}

- (void)update:(double)currentTime {
    [self updateScoreAndTime:currentTime];

    if (!_accelCalibrated) {
        return;
    }
    
    if (_lastTime == 0 || currentTime - _lastTime > 1) {
        _lastTime = currentTime;
        return;
    }
    
//    [self frameCounting:currentTime];
    
    double diff = currentTime - _lastTime;
    
    [self updateTargetDir];
    [self updateCurrentDir:diff];
    [self updateCurrentPos:diff];
    [self checkEnd:diff];
    TileInfo info = [self getPosInfo];
    
    _referenceHeight = info.height + 0.4;
    _lastKnownGoodX = _currentPos[0];
    
    [self checkFields:&info at:currentTime];
    
    BOOL jump = currentTime - _playerWantedToJumpAt < 0.2;
    
    _underLane = _currentPos[1] < _referenceHeight - 1 && _targetDir[1] < 0;
    if (_underLane) {
        if (_underLaneTime == 0) {
            _underLaneTime = currentTime;
        }
        else if (currentTime - _underLaneTime > 2) {
            [self throwBallBack];
        }
    }
    else {
        if (_onLane) {
            if (jump) {
                [self performJump:diff];
            }
            else {
                _currentPos[1] = _referenceHeight;
            }
        }
        else {
            _targetDir[1] = MAX(-20, _targetDir[1] - 30 * diff);
            if (_currentPos[1] < _referenceHeight && _targetDir[1] < 0 && !_cannotGetBackOnLane) {
                _onLane = YES;
                [self checkFields:&info at:currentTime];
                jump = currentTime - _playerWantedToJumpAt < 0.2;
                _onLane = NO;
                if (!_cannotGetBackOnLane) {
                    if (jump) {
                        [self performJump:diff];
                    }
                    else {
                        --_bounces;
                        _targetDir[1] = -_targetDir[1] / 2;
                        if (_bounces < 0) {
                            _onLane = YES;
                        }
                    }
                }
            }
        }
    }
    
    [self updateBallTransform:diff];
    [self cullScene];
    [self updateBallShadow];
    [self updateView];
    
    _lastTime = currentTime;

    // Must be last. Because level is lost afterwards
    if (_readyForNextLevel) {
        if (_view.arcade && !_gameOver) {
            _view.level += 1;
            [_view switchMode:MODE_LEVEL];
        }
        else {
            [_view switchMode:MODE_LEVEL_SELECTION];
        }
    }
}

- (void)addLaneModel:(NSString *)modelId {
    [_modelRegistry registerModel:modelId withType:[LaneModel class]];
    [_scene addLaneModel:modelId];
}

- (void)defineTargetTime:(double)time andJumps:(int)jumps {
    _targetTime = time;
    _targetJumps = jumps;
}

- (void)defineJumpStrengthOfField:(float)strength {
    _jumpFieldStrength = strength;
}

- (void)defineWarpFieldSpeedFactor:(float)factor {
    _warpFieldSpeedFactor = factor;
}

- (void)defineHoleFieldHeightCorrection:(float)correction {
    _holeFieldHeightCorrection = correction;
}

- (void)defineSpeedFieldStrength:(float)strength factor:(float)factor {
    _speedFieldStrength = strength;
    _speedFieldFactor = factor;
}


- (void)setupScene {
    [_modelRegistry registerModel:@"sky" withType:[Model class]];

    [_modelRegistry registerModel:@"ball" withType:[Model class]];
    [_modelRegistry registerModel:@"shadow" withType:[Model class]];
    
    _scene = [[Scene alloc] initWithRegistry:_modelRegistry];

    [self addLaneModel:@"lane_none_timed"];
    
    _jumpFieldStrength = 7;
    _warpFieldSpeedFactor = 2.1;
    _holeFieldHeightCorrection = 0.3515;
    _speedFieldStrength = 3.5;
    _speedFieldFactor = 1.5;
    
    Class levelClasses[] = {
        [Level1 class], [Level2 class], [Level3 class], [Level4 class], [Level5 class], 
        [Level6 class], [Level7 class], [Level8 class], [Level9 class], [Level10 class]
    };
    
    Class level = levelClasses[_view.level];
    [level setupLevel:self arcade:_view.arcade];
    
    [self addLaneModel:@"lane_none_timed"];

    _ball = [_scene addModel:@"ball" withTransform:CATransform3DMakeTranslation(0, 1, -20)];
    _shadow = [_scene addModel:@"shadow" withTransform:CATransform3DMakeTranslation(0, 0, 0)];

    [_scene setSkyModel:@"sky"];
}

- (void)setupUi {
    _joystickViaAccel = YES;

    [_modelRegistry registerModel:@"firebutton" withType:[Model class]];
    [_modelRegistry registerModel:@"jumps" withType:[Model class]];
    
    [_modelRegistry registerModel:@"0" withType:[Model class]];
    [_modelRegistry registerModel:@"1" withType:[Model class]];
    [_modelRegistry registerModel:@"2" withType:[Model class]];
    [_modelRegistry registerModel:@"3" withType:[Model class]];
    [_modelRegistry registerModel:@"4" withType:[Model class]];
    [_modelRegistry registerModel:@"5" withType:[Model class]];
    [_modelRegistry registerModel:@"6" withType:[Model class]];
    [_modelRegistry registerModel:@"7" withType:[Model class]];
    [_modelRegistry registerModel:@"8" withType:[Model class]];
    [_modelRegistry registerModel:@"9" withType:[Model class]];
    [_modelRegistry registerModel:@"colon" withType:[Model class]];
    
    [_modelRegistry registerModel:@"score" withType:[Model class]];
    [_modelRegistry registerModel:@"time" withType:[Model class]];
    [_modelRegistry registerModel:@"timebonus" withType:[Model class]];
    [_modelRegistry registerModel:@"jumpbonus" withType:[Model class]];
    [_modelRegistry registerModel:@"highscore" withType:[Model class]];
    [_modelRegistry registerModel:@"medal" withType:[Model class]];
    
    [_modelRegistry registerModel:@"x" withType:[Model class]];
    
    _uiScene = [[UIScene alloc] initWithRegistry:_modelRegistry];

    float width = _view.frame.size.width;
    float height = _view.frame.size.height;
    float aspect = width / height;

    float dx = 24.0 / height;
    float dy = 32.0 / width;
    
    float yellow[] = { 1, 0.8, 0, 1 };
    float gold[] = { 1, 0.8, 0.5, 1 };
    float blue[] = { 0.6, 0.5, 1, 1 };
    float red[] = { 1, 0.5, 0.6, 1 };
    
    if (_joystickViaAccel) {
        _joystickPos = CGRectMake(-0.8, -0.725, 0.15, 0.15 / aspect);
        [_uiScene addWidget:@"firebutton" at:_joystickPos with:gold];        
    }
    else {
        _joystickFramePos = CGRectMake(-0.8, -0.725, 0.3, 0.3 / aspect);
        _joystickPos = CGRectMake(-0.8, -0.725, 0.1, 0.1 / aspect);
        
/*        _joystickFrame = [_uiScene addWidget:@"joystick_frame" at:_joystickFramePos];
        _joystick = [_uiScene addWidget:@"joystick" at:_joystickPos];*/
    }
    
    _fireButtonPos = CGRectMake(0.8, -0.725, 0.15, 0.15 / aspect);
    [_uiScene addWidget:@"firebutton" at:_fireButtonPos with:gold];
    
    NSMutableArray* digits = [[NSMutableArray alloc] init];
    [_uiScene addWidget:@"time" at:CGRectMake(-1 + dx * 2.5, 0.9, dx * 4, dy) with:yellow];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(-1 + dx * 10, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(-1 + dx * 9, 0.9, dx, dy) with:yellow]];
    [_uiScene addWidget:@"colon" at:CGRectMake(-1 + dx * 8, 0.9, dx, dy) with:yellow];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(-1 + dx * 7, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(-1 + dx * 6, 0.9, dx, dy) with:yellow]];
    _timeDigits = digits;
    
    digits = [[NSMutableArray alloc] init];
    [_uiScene addWidget:@"jumps" at:CGRectMake(0, 0.9, 2 * dx, dy)];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 3, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 2, 0.9, dx, dy) with:yellow]];
    _jumpDigits = digits;
    
    digits = [[NSMutableArray alloc] init];
    [_uiScene addWidget:@"score" at:CGRectMake(1 - dx * 9, 0.9, dx * 5, dy) with:yellow];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(1 - dx * 1, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(1 - dx * 2, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(1 - dx * 3, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(1 - dx * 4, 0.9, dx, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(1 - dx * 5, 0.9, dx, dy) with:yellow]];
    _scoreDigits = digits;
    
    NSMutableArray* labels = [[NSMutableArray alloc] init];
    digits = [[NSMutableArray alloc] init];
    [labels addObject:[_uiScene addWidget:@"timebonus" at:CGRectMake(-dx * 5, dy * 1.5, dx * 10, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 7, dy * 1.5, dx, dy) with:blue]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 6, dy * 1.5, dx, dy) with:blue]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 5, dy * 1.5, dx, dy) with:blue]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 4, dy * 1.5, dx, dy) with:blue]];
    [labels addObject:[_uiScene addWidget:@"x" at:CGRectMake(dx * 9.1, dy * 1.5, dx / 2, dy) with:red]];
    if (_view.arcade) {
        [labels addObject:[_uiScene addWidget:@"5" at:CGRectMake(dx * 9.5, dy * 1.5, dx / 2, dy) with:red]];
    }
    else {
        [labels addObject:[_uiScene addWidget:@"1" at:CGRectMake(dx * 9.5, dy * 1.5, dx / 2, dy) with:red]];
        [labels addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 10, dy * 1.5, dx / 2, dy) with:red]];
    }
    _timeBonusDigits = digits;
    _timeBonusLabels = labels;
    
    labels = [[NSMutableArray alloc] init];
    digits = [[NSMutableArray alloc] init];
    [labels addObject:[_uiScene addWidget:@"jumpbonus" at:CGRectMake(-dx * 5, dy / 2, dx * 10, dy) with:yellow]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 7, dy / 2, dx, dy) with:blue]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 6, dy / 2, dx, dy) with:blue]];
    [labels addObject:[_uiScene addWidget:@"x" at:CGRectMake(dx * 9.1, dy / 2, dx / 2, dy) with:red]];
    [labels addObject:[_uiScene addWidget:@"1" at:CGRectMake(dx * 9.5, dy / 2, dx / 2, dy) with:red]];
    [labels addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 10, dy / 2, dx / 2, dy) with:red]];
    [labels addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 10.5, dy / 2, dx / 2, dy) with:red]];
    [labels addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 11, dy / 2, dx / 2, dy) with:red]];
    _jumpBonusDigits = digits;
    _jumpBonusLabels = labels;
    
    digits = [[NSMutableArray alloc] init];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 7, -dy * 1.5, dx, dy) with:gold]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 6, -dy * 1.5, dx, dy) with:gold]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 5, -dy * 1.5, dx, dy) with:gold]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 4, -dy * 1.5, dx, dy) with:gold]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 3, -dy * 1.5, dx, dy) with:gold]];
    [digits addObject:[_uiScene addWidget:@"0" at:CGRectMake(dx * 2, -dy * 1.5, dx, dy) with:gold]];
    _totalDigits = digits;
    
    labels = [[NSMutableArray alloc] init];
    [labels addObject:[_uiScene addWidget:@"highscore" at:CGRectMake(0, -dy * 4, 0.85, 0.1625) with:yellow]];
    _highscoreLabels = labels;
    
    labels = [[NSMutableArray alloc] init];
    [labels addObject:[_uiScene addWidget:@"medal" at:CGRectMake(0, -dy * 6, 0.15, 0.2)]];
    _medal = labels;

    BOOL hidden = YES;
    if (hidden) {
        for (SceneObject *obj in _timeBonusLabels) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _jumpBonusLabels) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _timeBonusDigits) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _jumpBonusDigits) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _totalDigits) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _highscoreLabels) { obj.alpha = 0; obj.hidden = YES; };
        for (SceneObject *obj in _medal) { obj.alpha = 0; obj.hidden = YES; }
    }
}

- (void)setupMovement {
    _targetDir[2] = -9.68;
    _currentPos[2] = -1;
    _onLane = YES;
    _speedFactor = 1;
}

- (void)setupAudio {
    _audioRegistry = [[AudioRegistry alloc] init];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"blazeball2" ofType:@"mp4f"];
    _backgroundMusic =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    if (!_view.stopMusic) {
        [_backgroundMusic prepareToPlay];
        [_backgroundMusic play];
    }
    _backgroundMusic.numberOfLoops = 100;
}

- (void)setupArcade {
    if (_view.arcade) {
        _score = _view.scoreFromLastLevel;
        _targetJumps += _view.bonusJump;
        _targetTime += _view.bonusTime;

        [_uiScene setDigits:_scoreDigits to:_score];
        
        _time = _targetTime * 100;
        [_uiScene setDigits:_timeDigits to:_time];
        [_uiScene setDigits:_jumpDigits to:_targetJumps];
    }
}

- (id)initWithView:(BlazeBallView *)view andRegistry:(ModelRegistry *)modelRegistry {
    self = [super init];
    if (self) {
        _view = view;
        _modelRegistry = modelRegistry;
        [_modelRegistry retain];
        [self setupScene];
        [self setupUi];
        [self setupAudio];
        [self setupMovement];
        [self setupArcade];
    }
    
    return self;
}

- (void)dealloc {
    [_scene release];
    [_uiScene release];
    [_audioRegistry release];
    [_scoreDigits release];
    [_timeDigits release];
    [_jumpDigits release];
    [_jumpBonusDigits release];
    [_jumpBonusLabels release];
    [_timeBonusDigits release];
    [_timeBonusLabels release];
    [_highscoreLabels release];
    [_medal release];
    [_modelRegistry release];
    [_backgroundMusic release];
    [super dealloc];
}

- (void)onFireButtonPressed:(double)time {
    _playerWantedToJumpAt = time;
}

- (void)onSpeedButtonPressed {
    _currentJoystickMovement.y = 1;
}

- (void)onJoystickMovedTo:(CGPoint)pos {
    _currentJoystickMovement = pos;
}

- (BOOL)moveJoystickFrame:(CGPoint)touchPt {
    if (touchPt.x >= 0) {
        return NO;
    }
    
    _joystickPos = CGRectMake(touchPt.x, touchPt.y, _joystickPos.size.width, _joystickPos.size.height);
    _joystickFramePos = CGRectMake(touchPt.x, touchPt.y, _joystickFramePos.size.width, _joystickFramePos.size.height);
    
    [_uiScene moveWidget:_joystick to:_joystickPos];
    [_uiScene moveWidget:_joystickFrame to:_joystickFramePos];
    
    return YES;
}

- (BOOL)moveJoystick:(CGPoint)touchPt allowOutside:(BOOL)allowedOutside {
    float dx = touchPt.x - _joystickFramePos.origin.x;
    float dy = touchPt.y - _joystickFramePos.origin.y;
    float dist = sqrt(dx * dx + dy * dy);
    float maxDist = _joystickFramePos.size.width / 2;
    
    BOOL outside = dist > maxDist;
    if (outside) {
        if (!allowedOutside) {
            return NO;
        }
        
        dx = dx / dist * maxDist;
        dy = dy / dist * maxDist;
        touchPt.x = _joystickFramePos.origin.x + dx;
        touchPt.y = _joystickFramePos.origin.y + dy;
    }
    
    _joystickPos = CGRectMake(touchPt.x, touchPt.y, _joystickPos.size.width, _joystickPos.size.height);
    [_uiScene moveWidget:_joystick to:_joystickPos];
    
    dx /= maxDist;
    dy /= maxDist;
    [self onJoystickMovedTo:CGPointMake(dx, dy)];
    
    return !outside;
}

- (void)pressFire:(CGPoint)touchPt at:(double)time {
    float dx = touchPt.x - _fireButtonPos.origin.x;
    float dy = touchPt.y - _fireButtonPos.origin.y;
    float dist = sqrt(dx * dx + dy * dy);
    float maxDist = _fireButtonPos.size.width * 3;
    
    if (dist > maxDist) {
        return;
    }
    
    [self onFireButtonPressed:time];
}

- (BOOL)pressSpeed:(CGPoint)touchPt {
    float dx = touchPt.x - _joystickPos.origin.x;
    float dy = touchPt.y - _joystickPos.origin.y;
    float dist = sqrt(dx * dx + dy * dy);
    float maxDist = _joystickPos.size.width * 3;
    
    if (dist > maxDist) {
        return NO;
    }
    
    [self onSpeedButtonPressed];
    
    return YES;
}

- (void)resetJoystick {
    _joystickTouch = nil;
    if (_joystickViaAccel) {
        _currentJoystickMovement.y = 0;
    }
    else {
        _joystickPos = CGRectMake(_joystickFramePos.origin.x, _joystickFramePos.origin.y, _joystickPos.size.width, _joystickPos.size.height);
        [_uiScene moveWidget:_joystick to:_joystickPos];
        [self onJoystickMovedTo:CGPointMake(0, 0)];
    }
}

- (void)touchBegan:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
    if (_joystickViaAccel) {
        if ([self pressSpeed:touchPt]) {
            _joystickTouch = touch;
        }
    }
    else {
        if ([self moveJoystickFrame:touchPt]) {
            _joystickTouch = touch;
        }
    }
    [self pressFire:touchPt at:timestamp];
}

- (void)touchMove:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
    if (touch == _joystickTouch && !_joystickViaAccel) {
        [self moveJoystick:touchPt allowOutside:YES];
    }
}

- (void)touchEnd:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
    if (touch == _joystickTouch) {
        [self resetJoystick];
    }
}

- (void)touchCancelled:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
    if (touch == _joystickTouch) {
        [self resetJoystick];
    }
}

- (void)resetAccelCalib {
    NSLog(@"starting accel calib");
    _accelMax = -1000;
    _accelMin = 1000;
    _accelCalibSum = 0;
}

- (void)accelerate:(UIAcceleration *)acceleration {
    if (!_joystickViaAccel) {
        return;
    }
    
    if (!_accelCalibrated) {
        if (_accelCalibCnt == 0) {
            [self resetAccelCalib];
        }
        _accelCalibSum += acceleration.y;
        _accelMin = MIN(_accelMin, acceleration.y);
        _accelMax = MAX(_accelMax, acceleration.y);
        ++_accelCalibCnt;
        if (_accelMax - _accelMin > 0.1) {
            NSLog(@"accel calib failed due to large range");
            _accelCalibCnt = 0;
        }
        if (acceleration.y > _accelCalibExpectedDeviation) {
            NSLog(@"accel calib failed due to high deviation");
            _accelCalibExpectedDeviation += 0.05;
            _accelCalibCnt = 0;
        }
        if (_accelCalibCnt >= 10) {
            _accelCalibY = _accelCalibSum / _accelCalibCnt;
            _accelCalibrated = YES;
        }
    }
    
    float y = acceleration.y - _accelCalibY;
    if (y < -0.03) {
        _currentJoystickMovement.x = MIN(1, -(y + 0.03) * 5);
    }
    else if (y > 0.03) {
        _currentJoystickMovement.x = MAX(-1, -(y - 0.03) * 5);
    }
    else {
        _currentJoystickMovement.x = 0;
    }
}



@end
